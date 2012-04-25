# Named Parameters

Named Parameters is a small and simple utility for working with named parameters in JavaScript/CoffeeScript.  That is, `named-parameters` is a Node.js module intended to make it easier to write functions that use map (i.e. associative arrays or, more accurately, JavaScript `Object`) parameters that use property names to define the role of each argument rather than relying on their ordinal position.

For example, using `named-parameters`, you can more easily replace a method signature like this:

```javascript
        util.inspect( myobject, null, 4, true )
```

with one like this:

```javascript
        inspect( myobject, { depth:4, colors:true } )
```

or (in CoffeeScript):

```javascript
        inspect myobject, depth:4, colors:true
```

# Installation

To install `named-parameters` with [npm](http://npmjs.org/), use:

```bash
        > npm install named-parameters
```

or add a dependency such as:

```javascript
        "dependencies" : {
          "named-parameters" : "latest"
        }
```


to your `package.json` file and run `npm install`.

# Quick Start

Named Parameters provides a simple DSL that offers utility functions for working with maps-as-arguments.

For example, given:

```javascript
        > var args = { a: 1, c: "no" }
```

and

```javascript
        > var np = require('named-parameters')
```

You can specify default values:

```javascript
        > params = np.parse(args).default('b','foo').values()
        { a: 1, c: 'no', b: 'foo' }
```
        
or convert them in a sane way:

```javascript
        > params = np.parse(args).coerce('c','boolean').values()
        { a: 1, c: false }
```
        
or valdidate them:

```javascript
        > params = np.parse(args).require('a','positive integer').values()
        { a: 1, c: 'no' }
```
        
or do all three at once:

```javascript
        > params = np.parse(args).default('b','foo').coerce('c','boolean').
        ... require('a','positive integer').values()
        { a: 1, c: false, b: 'foo' }
```

# Methods

## General

The `named-parameters` module exports a `parse` function that returns an object against which you can chain the various method calls. At the end of the chain, you invoke the `values()` method to obtain the final results.

```javascript
        args = np.parse( args ).values()
```

In the simplest case, `named-parameters` doesn't do much at all (although it does "clone" the input `Object` so that one can modify the output `Object` without changing the original).

## Specifying Default Values

To specify a default value you can add the `default` method to the chain:

```javascript
        args = np.parse( args ).default('foo','bar').values()
```

You can add multiple `default` calls to the chain to specify multiple default values:

```javascript
        args = np.parse( args ).default('foo','bar').default('height',170).values()
```

or simply pass a map to a single `default` (or `defaults`) method call:

```javascript
        args = np.parse( args ).defaults({foo:'bar',height:170}).values()
```

In CoffeeScript this yields a fairly clean and concise syntax:

```javascript
        args = np.parse( args ).defaults( foo:'bar', height:170 ).values()
```

## Validating Parameters

You can use `named-parameters` to enforce conditions on the input parameters using the `require` method.

For example:

```javascript
        args = np.parse( args ).require('bar').values()
```

Here, when the input `args['bar']` is missing (undefined) or `null`, an exception will be thrown.

There are several such validations available.

To ensure that a given input value is a non-`null` String:

```javascript
        args = np.parse( args ).require('bar','string').values()
```

To ensure that a given input value is a non-`null`, non-blank String:

```javascript
        args = np.parse( args ).require('bar','non-empty string').values()
```

...a non-`null` Array:

```javascript
        args = np.parse( args ).require('bar','array').values()
```

...a non-empty Array:

```javascript
        args = np.parse( args ).require('bar','non-empty array').values()
```

...a boolean value:

```javascript
        args = np.parse( args ).require('bar','boolean').values()
```

...a function:

```javascript
        args = np.parse( args ).require('bar','function').values()
```

...a number:

```javascript
        args = np.parse( args ).require('bar','number').values()
```

...a positive integer:

```javascript
        args = np.parse( args ).require('bar','positive integer').values()
```

...etc.

There are many more validation types available (see the detailed documentation for more examples), and if you are so inclined you can even pass in your own validation method:

```javascript
        function is_odd(num) { return num%2 == 1; }
        args = np.parse( args ).require('bar',is_odd).values()
```

(Following the example of [optimist](https://github.com/substack/node-optimist), the function `demand` can be used as an alias for `require`.)

## Coercing Types

The `coerce` function provides a mechanism for automatically converting a parameter into given type (if possible).

For instance, the chain:

```javascript
        args = np.parse( { bar: '17' } ).coerce('bar','integer').values()
```

yields:

```javascript
        { bar: 17 }
```

since the `coerce` method will convert the string `"17"` to the number `17`.

Conversely, the chain:

```javascript
        args = np.parse( { bar: 17 } ).coerce('bar','string').values()
```

yields:

```javascript
        { bar: '17' }
```

since the `coerce` method converts the number `17` into the string `"17"`.

Several `coerce` options are available.

To a numeric type:

```javascript
        > args = np.parse( { bar: 17 } ).coerce('bar','number').values()
        { bar: 17 }
        
        > args = np.parse( { bar: '17' } ).coerce('bar','number').values()
        { bar: 17 }

        > args = np.parse( { bar: 17.23 } ).coerce('bar','number').values()
        { bar: 17.23 }

        > args = np.parse( { bar: '17.23' } ).coerce('bar','number').values()
        { bar: 17.23 }
```

To an integer:

```javascript
        > args = np.parse( { bar: 17 } ).coerce('bar','number').values()
        { bar: 17 }
        
        > args = np.parse( { bar: '17' } ).coerce('bar','number').values()
        { bar: 17 }

        > args = np.parse( { bar: 17.23 } ).coerce('bar','number').values()
        { bar: 17 }

        > args = np.parse( { bar: '17.23' } ).coerce('bar','number').values()
        { bar: 17 }
```

To a boolean:

```javascript
        > args = np.parse( { bar: true } ).coerce('bar','boolean').values()
        { bar: true }
    
        > args = np.parse( { bar: "true" } ).coerce('bar','boolean').values()
        { bar: true }
            
        > args = np.parse( { bar: "yes" } ).coerce('bar','boolean').values()
        { bar: true }
            
        > args = np.parse( { bar: "on" } ).coerce('bar','boolean').values()
        { bar: true }
            
        > args = np.parse( { bar: "1" } ).coerce('bar','boolean').values()
        { bar: true }
            
        > args = np.parse( { bar: "3" } ).coerce('bar','boolean').values()
        { bar: false }
            
        > args = np.parse( { bar: "yellow" } ).coerce('bar','boolean').values()
        { bar: false }

        > args = np.parse( { bar: 6 } ).coerce('bar','boolean').values()
        { bar: true }
                
        > args = np.parse( { bar: 0 } ).coerce('bar','boolean').values()
        { bar: false }
                
        > args = np.parse( { bar: -14 } ).coerce('bar','boolean').values()
        { bar: true }
```

To an array:

```javascript
        > args = np.parse( { bar: [] } ).coerce('bar','array').values()
        { bar: [] }

        > args = np.parse( { bar: [ 7 ] } ).coerce('bar','array').values()
        { bar: [ 7 ] }

        > args = np.parse( { bar: 7 } ).coerce('bar','array').values()
        { bar: [ 7 ] }
```

etc.
        
See the detailed documentation for more examples.

# Note

This module is developed following the [git-flow](https://github.com/nvie/gitflow) workflow/branching model.

The default [master](https://github.com/rodw/named-parameters) branch only contains the released versions of the code and hence may seem relatively stagnant (or stable, depending upon your point of view).

Most of the action happens on the [develop](https://github.com/rodw/named-parameters/tree/develop) branch or in feature branches.
