# lua-pie

## Table of contents

- [lua-pie](#lua-pie)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Writing classes](#writing-classes)
    - [Instantiating objects](#instantiating-objects)
    - [Inheritance](#inheritance)
    - [Interfaces](#interfaces)
    - [Polymorphism](#polymorphism)
    - [Operators](#operators)
    - [Utilities](#utilities)
  - [Important Notes](#important-notes)

## Overview

lua-pie (polymorphism, ineritance and encapsulation) is a class library for Lua.
Currently lua-pie supports interfaces with abstract methods and classes with private, public and static methods as well as inheritance with polymorphism via the respective keywords. Private member variables can be declared with the `self` keyword in the constructor. Classes may also contain metamethods using the operator keyword.

## Installation

You can download lua-pie from luarocks with

```
luarocks install lua-pie
```

Or you can just clone or download this repository from github and use `lua-pie.lua` in your project.

## Usage

### Writing classes

Classes are created with the `class` keyword followed by the name of the class and a table containing method definitions. Method definitions are wrappend in a public, private or static block.
Currently the static block is the only one allowed to contain non-function values.

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

Classes are imported via the `import` function. After that they can be called to create a new instance. If a `constructor` function is defined in the `public` block it will be called when creating the object.

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

lua-pie allows single inheritance. A class can extend another class by using the `extends` function within the class definition.

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

lua-pie also provides support for interfaces. Interfaces may only contain abstract functions. All functions are public by default.
A class can implement an interface by using the `implements` function within the class definition. The argument to the `implements` function can either be a single class name as string or a table of class names.
If a class does not implement all functions defined by an interface an error will be thrown.

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

Methods can be overriden in subclasses, thus enabling polymorphism. Moreover every derived class has a field `self.super` which is an instance of the super class.
The super class instance will be created using the same arguments passed into the derived class constructor.

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

Operators (metamethods) are defined within the `operators` block. Currently the following operators are supported:

- __add
- __sub
- __mul
- __div
- __pow
- __concat
- __unm
- __tostring
- __call


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

### Utilities

lua-pie also provides a few simple utility functions, the first being the function `is`.
`is` takes an object and a class or type name as string and will return true if the given object is an instance of the specified type or class.

```lua
local slim = Person("Slim Shady")

print(is(slim, "Person"))
-- true
print(is("string", "string"))
-- true
```

In general lua-pie does not allow writing new indices to object. However this behavior can be turned off to enable working with test frameworks like `busted`.

```lua
require 'busted.runner'()
require "examples"

local pie = require("lua-pie")
local import = pie.import


describe("When testing busted spies", function()
	it("should work", function()
		pie.allow_writing_to_objects(true)
		pie.show_warnings(false) -- if not turned off, lue-pie will warn the user about writing to objects

		local Person = import("Person")

		local slim = Person("Slim Shady")

		local s = spy.on(slim, "introduce")
		slim:introduce()

		assert.spy(s).was.called()
	end)
end)
```

## Important Notes

Due to the way the module is written, class methods can not be passed around like usual functions. In lua-pie when functions are called they are wrapped in a special wrapper function to pass in the private object table that is hidden from the user. When simply retrieving a function from an object it will always return the wrapper function. Below is a simple example:

```lua
local Greeter = import "Greeter"
local Person = import "Person"

greeter = Greeter()

person = Person("A")

local func = greeter.say_hello
local func2 = person.introduce

print(func == func2)
-- true
```

Therefore if you want to pass functions around, always wrap them in another function first:

```lua
local Greeter = import "Greeter"

greeter = Greeter()

local func = function(name) greeter:say_hello(name) end

func("World")
```
