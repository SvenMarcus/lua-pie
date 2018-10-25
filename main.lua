local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private
local import = classy.import


class "Person" {
    public "constructor" { function(name)
        self.name = name
    end };

    public "introduce" { function()
        self.privatePrint()
    end };

    private "privatePrint" { function()
        print("Hi! My name is "..self.name)
    end };
}

local Person = import("Person")

local slim = Person:new("Slim Shady")
slim.introduce()

--error trying to access private member
slim.privatePrint()