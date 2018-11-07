local os = require "os"
local classy = require "classy"
local class = classy.class
local static = classy.static
local public = classy.public
local private = classy.private
local extends = classy.extends
local import = classy.import


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

class "Person" {

	extends "Greeter";

	static {
		count = 0
	};

    public {

		constructor = function(self, name)
			self.name = name
			print(self.name)
			self.count = self.count + 1
		end;

		introduce = function(self)
			self:private_intro()
		end;

		say_hello = function(self, name)
			self.super:say_hello(name)
			print("Override hello")
		end;
    };

    private {
		private_intro = function(self)
			print("Hi! My name is "..self.name)
		end;
	};
}

local Greeter = import("Greeter")
local greeter = Greeter()

greeter:say_hello("World")
-- greeter:private_hello()


local Person = import("Person")
local slim = Person("Slim Shady")

print(slim.count)

local jimmy = Person("Jimmy")

slim:introduce()
slim:say_hello("World")

jimmy:introduce()

print(slim.count)
print(jimmy.count)

