local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private
local extends = classy.extends
local import = classy.import


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
			print("Override hello")
		end;
    };
}

local Greeter = import("Greeter")
local greeter = Greeter:new()

greeter.say_hello("World")


local Person = import("Person")
local slim = Person:new("Slim Shady")

slim.introduce()
slim.say_hello("World")

