require 'busted.runner'()
require "examples"

local pie = require("lua-pie")
local import = pie.import


describe("When testing busted spies", function()
	it("should work", function()
		pie.allow_writing_to_objects(true)
		pie.show_warnings(false)

		local Person = import("Person")

		local slim = Person("Slim Shady")

		local s = spy.on(slim, "introduce")
		slim:introduce()

		assert.spy(s).was.called()
	end)
end)