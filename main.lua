require "examples"

local pie = require "lua-pie"
local import = pie.import

local Greeter = import "Greeter"
local greeter = Greeter()

greeter:say_hello("World")
-- greeter:private_hello()


local Person = import "Person"
local slim = Person("Slim Shady")


-- -- print("Number of persons: "..Person.count)

-- local jimmy = Person("Jimmy")

slim:introduce()
-- -- slim:say_hello("World")

-- jimmy:introduce()

local start = os.clock()
for i=1, 10000000 do
    Greeter("Test")
end

local _end = os.clock()

print(_end - start)



-- print("Number of persons: "..slim.count)

-- jimmy:introduce()

-- local Number = import("Number")

-- print((Number(3) + Number(4)))