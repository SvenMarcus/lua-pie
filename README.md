# classy

Classy is class library prototype for Lua.

## Overview

Classy was intended to be used in modifications for Star Wars Empire at War - Forces of Corruption. Since the game produces corrupt save games when using multiple meta tables or upvalues, their usage was avoided wherever possible. In the end the library still cannot be used for the game in its current form due to engine limitations with `setfenv()`.

Currently classy supports private and public methods as well as inheritance with polymorphism via the respective keywords. Private member variables can be declared with the `self` keyword in the constructor.

### Experimental branch

The experimental branch explores an alternative metatable based implementation of classy (while keeping the same public API) with the goal of improving performance. The main branch implementation is rather memory inefficient and slow on object creation due to cloning of functions via `loadstring(string.dump(func))`. The metatable based implementation provides faster object creation, but loses out on performance for complex tasks.

## Usage

### Writing classes

```
local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private


class "Greeter" {

    public {
        say_hello = function(name)
            self.private_hello(name)
        end
    };

    private {
        private_hello = function(name)
            print("Hello "..name)
        end
    }
}
```

### Instantiating objects

```
local classy = require "classy"
local import = classy.import

local Greeter = import("Greeter")
local greeter = Greeter:new()

greeter.say_hello("World")
-- Output: Hello World

greeter.private_hello("World")
-- Output: Error. Trying to access private member private_hello
```

### Inheritance

```
local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private


class "Person" {

    extends "Greeter";


    public {
        constructor = function(name)
            self.name = name
        end;

        introduce = function()
            print("Hi! My name is "..self.name)
        end;
    };
}

local Person = import("Person")

local slim = Person:new("Slim Shady")

slim.introduce()
-- Output: Hi! My name is Slim Shady

slim.say_hello("World")
-- Output: Hello World
```

### Polymorphism

```
class "Person" {

    extends "Greeter";


    public {
        constructor = function(name)
            self.name = name
        end;

        introduce = function()
            print("Hi! My name is "..self.name)
        end;

        say_hello = function(name)
            super.say_hello(name)
            print("Hello Override")
        end;
    };

}

local Person = import("Person")

local slim = Person:new("Slim Shady")

slim.say_hello("World")
-- Output: 
-- Hello World
-- Hello Override

```
