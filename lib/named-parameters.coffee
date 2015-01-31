class NamedParameters
  constructor:(m)->
    @map = _clone(m)
    @coerce_all = false

  values:()->@map

  default:(name,value)->
    if typeof name == 'object' && !value?
      @defaults(name)
    else
      @map[name] = value unless @map[name]?
    return this

  defaults: (map)->
    for n,v of map
      @default n, v
    return this

  coerce:(name,type,whennull=null)->
    if typeof name == 'boolean'
      @coerce_all = name
    else if typeof name == 'object'
      for n,v of name
        @coerce n, v
    else
      value = @map[name]
      switch type
        when 'integer'
          if value?
            @map[name] = Math.floor(Number(value))
          else
            @map[name] = Math.floor(Number(whennull))
        when 'number'
          if value?
            @map[name] = Number(value)
          else
            @map[name] = Number(whennull)
        when 'string'
          if value?
            @map[name] = String(value)
          else
            @map[name] = String(whennull)
        when 'boolean'
          if typeof value == 'string'
            v = value.toLowerCase()
            @map[name] = (v == 'true' || v == 't' || v == 'yes' || v == 'y' || v == '1' || v == 'on')
          else if typeof value == 'function'
            @map[name] = value()
          else
            @map[name] = if(value) then true else false
        when 'array'
          if value?
            @map[name] = [ value ] unless value instanceof Array
          else if whennull?
            @map[name] = [ whennull ] unless whennull instanceof Array
        else
          throw(new Error("I don't know how to coerce parameter \"#{name}\" into the unrecognized type \"#{type}\"."))
    return this

  require:(name,validation=null,message=null)->
    switch typeof validation
      when 'string'
        switch validation.toLowerCase()
          when 'non empty string','non-empty string','non blank string','non-blank string'
            @coerce name, 'string' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-empty String. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'string') && value.length > 0, message
          when 'non empty array','non-empty array'
            @coerce name, 'array' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-empty Array. Found \"#{value}\"." unless message?
            _assert value? && (value instanceof Array) && value.length > 0, message
          when 'number','numeric'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a numeric value. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number'), message
          when 'positive number','positive'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a positive number. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && value > 0, message
          when 'negative number','negative'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a negative number. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && value < 0, message
          when 'non-negative number','non negative number','non negative','non-negative'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-negative number. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && value >= 0, message
          when 'non-positive number','non positive number','non-positive','non positive'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-positive number. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && value <= 0, message
          when 'non-zero number','non zero number','non-zero','non zero'
            @coerce name, 'number' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-zero number. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && value != 0, message
          when 'integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be an integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value, message
          when 'positive integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a positive integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value && value > 0, message
          when 'negative integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a negative integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value && value < 0, message
          when 'non-negative integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-negative integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value && value >= 0, message
          when 'non-positive integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-positive integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value && value <= 0, message
          when 'non-zero integer'
            @coerce name, 'integer' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-zero integer. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'number') && Math.floor(value) == value && value != 0, message
          when 'string'
            @coerce name, 'string' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-null string. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'string'), message
          when 'object'
            value = @map[name]
            message = "Expected #{name} parameter to be a non-null Object. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'object'), message
          when 'array'
            @coerce name, 'array' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-null Array. Found \"#{value}\"." unless message?
            _assert value? && (value instanceof Array), message
          when 'boolean'
            @coerce name, 'boolean' if(@coerce_all)
            value = @map[name]
            message = "Expected #{name} parameter to be a non-null boolean. Found \"#{value}\"." unless message?
            _assert value? && (typeof value == 'boolean'), message
          when 'not null'
            value = @map[name]
            message = "Expected #{name} parameter to be non-null value. Found (\"#{value}\")." unless message?
            _assert value?, message
          else
            throw(new Error("Unrecognized validator string \"#{validation}\"."))
      when 'function'
        value = @map[name]
        message = "Expected #{name} parameter (\"#{value}\") to pass validation #{validation}." unless message?
        _assert validation(name), message
      when 'object'
        if validation?
          throw(new Error("Unrecognized validator object \"#{validation}\".")
        else
          value = @map[name]
          message = "Expected #{name} parameter to be non-null value. Found (\"#{value}\")." unless message?
          _assert value?, message
      else
        throw(new Error("Unrecognized validator string \"#{validation}\"."))
    return this

  demand:(name,validation,message)->@require(name,validation,message)

  _clone = (obj)->
    clone = {}
    for n,v of obj
      clone[n] = v if obj.hasOwnProperty(n)
    return clone

  _assert = (bool,message = "Invalid parameter")-> throw(new Error(message)) if !bool

exports = exports ? this
exports.NamedParameters = NamedParameters
exports.parse = (map)->return new NamedParameters(map)
