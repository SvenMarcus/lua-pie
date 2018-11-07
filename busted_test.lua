require 'busted.runner'()
require "examples"

local classy = require "classy"
local class = classy.class
local static = classy.static
local public = classy.public
local private = classy.private
local extends = classy.extends
local import = classy.import


describe("When testing busted spies", function()
	it("should work", function()
		classy.allow_writing_to_objects(true)
		classy.show_warnings(false)

		local Person = import("Person")

		local slim = Person("Slim Shady")

		local s = spy.on(slim, "introduce")
		slim:introduce()

		assert.spy(s).was.called()
	end)
end)