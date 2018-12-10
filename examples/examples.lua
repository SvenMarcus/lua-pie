local pie = require "lua_pie"
local class = pie.class
local static = pie.static
local public = pie.public
local private = pie.private
local operators = pie.operators
local extends = pie.extends
local interface = pie.interface
local abstract_function = pie.abstract_function
local implements = pie.implements

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

class "Person" {

	extends "Greeter";

	static {
		count = 0
	};

    public {

		constructor = function(self, name)
			self.name = name
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