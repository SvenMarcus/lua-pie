local os = require "os"
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
			self.private_intro()
		end;

		-- say_hello = function(name)
		-- 	super.say_hello(name)
		-- 	print("Override hello")
		-- end;
    };

    private {
		private_intro = function()
			print("Hi! My name is "..self.name)
		end;
	};
}

-- local Greeter = import("Greeter")
-- local greeter = Greeter()

-- greeter.say_hello("World")


local Person = import("Person")
local slim = Person("Slim Shady")
local jimmy = Person("Jimmy")

slim.introduce()
slim.say_hello("World")

jimmy.introduce()



-- person = {}
-- person_mt = {__index = person}

-- function person.new(name)
-- 	local self = setmetatable({},  person_mt)
-- 	self.name = name
-- 	return self
-- end

-- function person:introduce()
-- 	print("Hi! My name is "..self.name)
-- end

-- function person:say_hello(name)
-- 	print("Override hello")
-- end

-- local p = person.new("Test")
-- print(p.name)
-- p:introduce()
-- local start = os.clock()

-- for i=1, 100000000 do
-- 	Person("Test")
-- end

-- local stop = os.clock()
-- print(stop - start)