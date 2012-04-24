should = require('should')
HOME_DIR        = "#{__dirname}/.."
IS_COFFEE        = process.argv[0].indexOf('coffee') >= 0
IS_INSTRUMENTED  = (require('path')).existsSync("#{HOME_DIR}/lib-cov")
LIB_DIR          = if IS_INSTRUMENTED then "#{HOME_DIR}/lib-cov" else "#{HOME_DIR}/lib"
FILE_SUFFIX      = if IS_COFFEE then '.coffee' else '.js'
NAMED_PARAMETERS = "#{LIB_DIR}/named-parameters#{FILE_SUFFIX}"

describe "named-parameters", ->
  beforeEach (done)->
    @np = require(NAMED_PARAMETERS)
    done()

  it "can be chained directly to the require() function", (done)->
    args = { a:1, b:2, d:true, e:{name:"value"}, f:[1,2,3,4] }
    params = require(NAMED_PARAMETERS).parse(args).values()
    params.should.be.instanceof Object
    for name,value in args
      params[name].should.equal value
    done()

  it "can be used over and over again", (done)->
    args = { a:1, b:2, d:true, e:{name:"value"}, f:[1,2,3,4] }
    params = @np.parse(args).values()
    params.should.be.instanceof Object
    for name,value in args
      params[name].should.equal value
    done()

  it "creates a clone of the given arguments", (done)->
    args = { a:1, b:2, d:true, e:{name:"value"}, f:[1,2,3,4] }
    params = @np.parse(args).values()
    params.a.should.equal 1
    args.a.should.equal 1
    params.a = 2
    params.a.should.equal 2
    args.a.should.equal 1
    done()

  it "supports default values for when a parameter is null", (done)->
    args = { a: null, b: "a string" }
    params = @np.parse( args ).default('a',11).values()
    params.a.should.equal 11
    done()

  it "supports default values for when a parameter is missing", (done)->
    args = { a: null, b: "a string" }
    params = @np.parse( args ).default('c','13').values()
    params.c.should.equal '13'
    done()

  it "doesn't change pre-existing values when specifying defaults", (done)->
    args = { a: null, b: "a string" }
    params = @np.parse( args ).default('b',12).values()
    params.b.should.equal "a string"
    params = @np.parse( args ).default('b',null).values()
    params.b.should.equal "a string"
    done()

  it "allows defaults to be chained together", (done)->
    args = { a: null, b: "a string" }
    params = @np.parse( args ).default('a',11).default('b',12).default('c','13').values()
    params.a.should.equal 11
    params.b.should.equal "a string"
    params.c.should.equal '13'
    done()

  it "allows defaults to passed all at once", (done)->
    args = { a: null, b: "a string" }
    params = @np.parse( args ).defaults(a:11,b:12,c:'13').values()
    params.a.should.equal 11
    params.b.should.equal "a string"
    params.c.should.equal '13'

    params = @np.parse( args ).default(a:11,b:12,c:'13').values()
    params.a.should.equal 11
    params.b.should.equal "a string"
    params.c.should.equal '13'
    done()

  it "allows defaults to be set from an arbitrary object", (done)->
    args = { a: null, b: "a string" }
    class Animal
      constructor:(type,name,sound)->
        @type = type
        @name = name
        @sound = sound

      talk:()->"#{@name} says \"#{@sound}\"."

    obj = new Animal('cat','Fluffy','meow')
    params = @np.parse( args ).defaults(obj).values()
    params.name.should.equal 'Fluffy'
    params.type.should.equal 'cat'
    params.sound.should.equal 'meow'

    (typeof params.talk).should.equal 'function'
    params.talk().should.equal 'Fluffy says "meow".'

    done()

  describe "validation", ()->

    it "ensures non-null values with 'require(name)'", (done)->
      params = @np.parse( {a:"foo"} ).require("a").values()
      params.a.should.equal "foo"
      (=>@np.parse( {} ).require("a").values()).should.throw()
      (=>@np.parse( {a:null} ).require("a").values()).should.throw()
      done()

    it "ensures non-null values with 'require(name,'not null')'", (done)->
      (=>@np.parse( {} ).require('a','not null').values()).should.throw()
      done()

    it "allows 'demand' as an alias for 'require'", (done)->
      (=>@np.parse( {a:"foo"} ).demand("a").values()).should.not.throw()
      (=>@np.parse( {} ).demand("a").values()).should.throw()
      (=>@np.parse( {a:null} ).demand("a").values()).should.throw()
      done()


    it "ensures non-null strings", (done)->
      (=>@np.parse( {a:"foo"} ).require('a','string').values()).should.not.throw()
      (=>@np.parse( {a:null} ).require('a','string').values()).should.throw()
      (=>@np.parse( {} ).require('a','string').values()).should.throw()
      (=>@np.parse( {a:7} ).require('a','string').values()).should.throw()
      (=>@np.parse( {a:["foo"]} ).require('a','string').values()).should.throw()
      done()

    it "ensures non-empty strings", (done)->
      (=>@np.parse( {a:"foo"} ).require('a','non-empty string').values()).should.not.throw()
      (=>@np.parse( {a:""} ).require('a','non-empty string').values()).should.throw()
      (=>@np.parse( {a:null} ).require('a','non-empty string').values()).should.throw()
      (=>@np.parse( {} ).require('a','non-empty string').values()).should.throw()
      (=>@np.parse( {a:7} ).require('a','non-empty string').values()).should.throw()
      (=>@np.parse( {a:["foo"]} ).require('a','non-empty string').values()).should.throw()
      done()

    it "ensures non-blank strings", (done)->
      (=>@np.parse( {a:"foo"} ).require('a','non-blank string').values()).should.not.throw()
      (=>@np.parse( {a:""} ).require('a','non-blank string').values()).should.throw()
      (=>@np.parse( {a:null} ).require('a','non-blank string').values()).should.throw()
      (=>@np.parse( {} ).require('a','non-blank string').values()).should.throw()
      (=>@np.parse( {a:7} ).require('a','non-blank string').values()).should.throw()
      (=>@np.parse( {a:["foo"]} ).require('a','non-blank string').values()).should.throw()
      done()

    it "ensures numeric values", (done)->
      (=>@np.parse( a:16 ).require('a','number').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','number').values()).should.not.throw()
      (=>@np.parse( a:16.345 ).require('a','number').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','number').values()).should.throw()
      (=>@np.parse( a:"sixteen" ).require('a','number').values()).should.throw()
      (=>@np.parse( a:"16" ).require('a','number').values()).should.throw()
      (=>@np.parse( a:"16" ).coerce(true).require('a','number').values()).should.not.throw()
      done()

    it "ensures positive values", (done)->
      (=>@np.parse( a:16 ).require('a','positive number').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','positive number').values()).should.throw()
      (=>@np.parse( a:null ).require('a','positive number').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','positive number').values()).should.throw()
      (=>@np.parse( a:16 ).require('a','positive').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','positive').values()).should.throw()
      (=>@np.parse( a:null ).require('a','positive').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','positive').values()).should.throw()
      done()

    it "ensures negative values", (done)->
      (=>@np.parse( a:16 ).require('a','negative number').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','negative number').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','negative number').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','negative number').values()).should.throw()
      (=>@np.parse( a:16 ).require('a','negative').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','negative').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','negative').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','negative').values()).should.throw()
      done()

    it "ensures non-negative values", (done)->
      (=>@np.parse( a:16 ).require('a','non-negative number').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','non-negative number').values()).should.throw()
      (=>@np.parse( a:null ).require('a','non-negative number').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-negative number').values()).should.not.throw()
      (=>@np.parse( a:16 ).require('a','non-negative').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','non-negative').values()).should.throw()
      (=>@np.parse( a:null ).require('a','non-negative').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-negative').values()).should.not.throw()
      done()

    it "ensures non-positive values", (done)->
      (=>@np.parse( a:16 ).require('a','non-positive number').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','non-positive number').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','non-positive number').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-positive number').values()).should.not.throw()
      (=>@np.parse( a:16 ).require('a','non-positive').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','non-positive').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','non-positive').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-positive').values()).should.not.throw()
      done()

    it "ensures non-zero values", (done)->
      (=>@np.parse( a:16 ).require('a','non-zero number').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','non-zero number').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','non-zero number').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-zero number').values()).should.throw()
      (=>@np.parse( a:16 ).require('a','non-zero').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','non-zero').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','non-zero').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-zero').values()).should.throw()
      done()

    it "ensures integer values", (done)->
      (=>@np.parse( a:16 ).require('a','integer').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','integer').values()).should.not.throw()
      (=>@np.parse( a:16.345 ).require('a','integer').values()).should.throw()
      (=>@np.parse( a:null ).require('a','integer').values()).should.throw()
      (=>@np.parse( a:"sixteen" ).require('a','integer').values()).should.throw()
      (=>@np.parse( a:"16" ).require('a','integer').values()).should.throw()
      (=>@np.parse( a:"16" ).coerce(true).require('a','integer').values()).should.not.throw()
      (=>@np.parse( a:"16.345" ).coerce(true).require('a','integer').values()).should.not.throw()
      done()

    it "ensures positive integer values", (done)->
      (=>@np.parse( a:16 ).require('a','positive integer').values()).should.not.throw()
      (=>@np.parse( a:16.123 ).require('a','positive integer').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','positive integer').values()).should.throw()
      (=>@np.parse( a:null ).require('a','positive integer').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','positive integer').values()).should.throw()
      done()

    it "ensures negative integer values", (done)->
      (=>@np.parse( a:16 ).require('a','negative integer').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','negative integer').values()).should.not.throw()
      (=>@np.parse( a:-16.123 ).require('a','negative integer').values()).should.throw()
      (=>@np.parse( a:null ).require('a','negative integer').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','negative integer').values()).should.throw()
      done()

    it "ensures non-negative integer values", (done)->
      (=>@np.parse( a:16 ).require('a','non-negative integer').values()).should.not.throw()
      (=>@np.parse( a:16.123 ).require('a','non-negative integer').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','non-negative integer').values()).should.throw()
      (=>@np.parse( a:null ).require('a','non-negative integer').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-negative integer').values()).should.not.throw()
      done()

    it "ensures non-positive integer values", (done)->
      (=>@np.parse( a:16 ).require('a','non-positive integer').values()).should.throw()
      (=>@np.parse( a:-16 ).require('a','non-positive integer').values()).should.not.throw()
      (=>@np.parse( a:-16.123 ).require('a','non-positive integer').values()).should.throw()
      (=>@np.parse( a:null ).require('a','non-positive integer').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-positive integer').values()).should.not.throw()
      done()

    it "ensures non-zero integer values", (done)->
      (=>@np.parse( a:16 ).require('a','non-zero integer').values()).should.not.throw()
      (=>@np.parse( a:-16 ).require('a','non-zero integer').values()).should.not.throw()
      (=>@np.parse( a:null ).require('a','non-zero integer').values()).should.throw()
      (=>@np.parse( a:0 ).require('a','non-zero integer').values()).should.throw()
      (=>@np.parse( a:0.12345 ).require('a','non-zero integer').values()).should.throw()
      done()
