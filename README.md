# classy

Classy is class library prototype for Lua.

## Overview

Currently classy supports private, public and static methods as well as inheritance with polymorphism via the respective keywords. Private member variables can be declared with the `self` keyword in the constructor.

## Usage

### Writing classes

```
local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private


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

```
local classy = require "classy"
local import = classy.import

local Greeter = import("Greeter")
local greeter = Greeter()

greeter:say_hello("World")
-- Output: Hello World

greeter:private_hello("World")
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

### Polymorphism

```
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

```
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
