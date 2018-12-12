require "examples"

local pie = require "lua-pie"
local import = pie.import
local is = pie.is

local Greeter = import "Greeter"
local greeter = Greeter()

greeter:say_hello("World")
-- greeter:private_hello()


local Person = import "Person"
local slim = Person("Slim Shady")

-- print(slim.name)

print("Number of persons: "..Person.count)

local jimmy = Person("Jimmy")

slim:introduce()
slim:say_hello("World")

jimmy:introduce()

print("Number of persons: "..slim.count)

local Number = import("Number")

print((Number(3) + Number(4)))

print("Is slim a Person?", is(slim, "Person"))
print("Is slim a Greeter?", is(slim, "Greeter"))
print("Is slim an IShouter?", is(slim, "IShouter"))
print(is("string", "string"))

print(tostring(Number(5)))

-- local start = os.clock()

-- for i=1, 10000000 do
--     Person("Test")
-- end

-- local stop = os.clock()

-- print(stop - start)


