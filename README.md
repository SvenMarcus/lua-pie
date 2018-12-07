# lua-pie

lua-pie (polymorphism, ineritance and encapsulation) is a class library prototype for Lua.

## Overview

Currently lua-pie supports interfaces with abstract methods and classes with private, public and static methods as well as inheritance with polymorphism via the respective keywords. Private member variables can be declared with the `self` keyword in the constructor.

## Installation

You can download lua-pie from luarocks with

```
luarocks install lua-pie
```

Or you can just clone or download this repository from github and use `lua-pie.lua` in your project.

## Usage

### Writing classes

```lua
local pie = require "lua-pie"
local class = pie.class
local public = pie.public
local private = pie.private


class "Greeter" {

    public {
        say_hello = function(self, name)
            self:private_hello(name)
        end
    };

    private {
        private_hello = function(self, name)
            print("Hello "..name)
        end
    }
}
```

### Instantiating objects

```lua
local pie = require "lua-pie"
local import = pie.import

local Greeter = import("Greeter")
local greeter = Greeter()

greeter:say_hello("World")
-- Output: Hello World

greeter:private_hello("World")
-- Output: Error. Trying to access private member private_hello
```

### Inheritance

```lua
local pie = require "lua-pie"
local class = pie.class
local public = pie.public
local private = pie.private


class "Person" {

    extends "Greeter";

    public {
        constructor = function(self, name)
            self.name = name
        end;

        introduce = function(self)
            print("Hi! My name is "..self.name)
        end;
    };
}

local Person = import("Person")

local slim = Person("Slim Shady")

slim:introduce()
-- Output: Hi! My name is Slim Shady

slim:say_hello("World")
-- Output: Hello World
```

### Interfaces

```lua
local pie = require "lua-pie"
local interface = pie.interface
local implements = pie.implements
local abstract_function = pie.abstract_function
local class = pie.class
local public = pie.public
local private = pie.private

interface "IGreeter" {

    say_hello = abstract_function("self", "name")
}

interface "IShouter" {
    shout = abstract_function()
}

class "Greeter" {

    implements {
        "IGreeter",
        "IShouter"
    };

    public {
        say_hello = function(self, name)
            self:private_hello(name)
        end;

        shout = function(self)
            print("I CAN SHOUT REALLY LOUD!")
        end
    };

    private {
        private_hello = function(self, name)
            print("Hello "..name)
        end;
    }
}
```

### Polymorphism

```lua
class "Person" {

    extends "Greeter";

    public {
        constructor = function(self, name)
            self.name = name
        end;

        introduce = function(self)
            print("Hi! My name is "..self.name)
        end;

        say_hello = function(self, name)
            self.super:say_hello(name)
            print("Hello Override")
        end;
    };

}

local Person = import("Person")

local slim = Person("Slim Shady")

slim:say_hello("World")
-- Output: 
-- Hello World
-- Hello Override

```

### Operators

```lua
-- Number has to be declared first, so we can use it within the class
local Number
Number = class "Number" {
	public {
		constructor = function(self, value)
			self.value = value
		end;

		getValue = function(self)
			return self.value
		end;
	};

	operators {
		__add = function(self, n2)
			return Number(self.value + n2:getValue())
		end;

		__tostring = function(self)
			return tostring(self.value)
		end
	}
}
```
