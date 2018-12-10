local math = require("math")

local OneDimGrid = {}

function OneDimGrid.constructor()
		local self = setmetatable({}, {__index = OneDimGrid})
		self.numNodes = 0
		self.length = 0.0
		self.gridDelta = 0.0
		self.coordinates = {}
		self.nodeValues = {}

		return self
end;

function OneDimGrid:setNumNodes(num)
	self.numNodes = num

	for _=1, num do
		table.insert(self.coordinates, 0)
		table.insert(self.nodeValues, 0)
	end

	self:calcGridDelta()
	self:calcCoordinates()
end;

function OneDimGrid:setLength(l)
	self.length = l
end;

function OneDimGrid:setNodeValues(values)
	self.nodeValues = values
end;

function OneDimGrid:setLeftBC(bc)
	self.nodeValues[1] = bc
end;

function OneDimGrid:setRightBC(bc)
	self.nodeValues[#self.nodeValues] = bc
end;

function OneDimGrid:setGridNodeValue(index, value)
	self.nodeValues[index] = value
end;

function OneDimGrid:getNumNodes()
	return self.numNodes
end;

function OneDimGrid:getLength()
	return self.length
end;

function OneDimGrid:getGridDelta()
	return self.gridDelta
end;

function OneDimGrid:getCoordinateOf(node)
	return self.coordinates[node]
end;

function OneDimGrid:getLeftBC()
	return self.nodeValues[1]
end;

function OneDimGrid:getRightBC()
	return self.nodeValues[#self.nodeValues]
end;

function OneDimGrid:getNodeValues()
	return self.nodeValues
end

function OneDimGrid:calcGridDelta()
	self.gridDelta = self.length / (self.numNodes - 1)
end;

function OneDimGrid:calcCoordinates()
	for i=1, self.numNodes do
		self.coordinates[i] = (i - 1) * self.gridDelta
	end
end;


local GridSolver = {}

function GridSolver.constructor(grid, func)
	local self = setmetatable({}, {__index = GridSolver})
	self.func = func
	self.grid = grid
	self.gridDelta = self.grid:getGridDelta()
	self.lastStepValues = nil
	self.newStepValues = nil
	self:initArrays()

	return self
end;

function GridSolver:solve()
	local delta
	self.gridDelta = self.grid:getGridDelta()

	repeat
		delta = 0.0

		for i=2, (self.grid:getNumNodes() - 1) do
			self:calculateNewData(i)
			delta = self:calculateDelta(delta, i)
		end

		self:swap()
	until (delta < self.exitCondition)

	self.grid:setNodeValues(self.newStepValues)
end;

function GridSolver:setExitCondition(ec)
	self.exitCondition = ec
end;

function GridSolver:setGrid(grid)
	self.grid = grid
	self:initArrays()
end;

function GridSolver:setFunction(func)
	self.func = func
end;

function GridSolver:initArrays()
	local numNodes = self.grid:getNumNodes()
	self.lastStepValues = self:zeros(numNodes)
	self.newStepValues = self:zeros(numNodes)
	self.lastStepValues[1] = self.grid:getLeftBC()
	self.lastStepValues[#self.lastStepValues] = self.grid:getRightBC()
	self.newStepValues[1] = self.grid:getLeftBC()
	self.newStepValues[#self.newStepValues] = self.grid:getRightBC()
end;

function GridSolver:calculateNewData(index)
	local coord = self.grid:getCoordinateOf(index)
	local data = 0.5 * (self.lastStepValues[index + 1] +self.lastStepValues[index - 1] - self.gridDelta * self.gridDelta * self.func(coord))
	self.newStepValues[index] = data
end;

function GridSolver:calculateDelta(lastDelta, index)
	return math.max(math.abs(self.newStepValues[index] - self.lastStepValues[index]), lastDelta)
end;

function GridSolver:swap()
	local tmp = self.lastStepValues
	self.lastStepValues = self.newStepValues
	self.newStepValues = tmp
end;

function GridSolver:zeros(num)
	local t = {}
	for _=1, num do
		table.insert(t, 0)
	end
	return t
end;


local nMax = 9
local length = 0.1
local numNodes = 2
local rightBC = 1
local leftBC = 0

local func = function(x)
	return math.sin(2 * x * math.pi / length)
end

local grid = OneDimGrid.constructor()
grid:setLength(length)
grid:setLeftBC(leftBC)
grid:setRightBC(rightBC)

local solver = GridSolver.constructor(grid, func)
solver:setExitCondition(1e-15)
solver:setFunction(func)

local start = os.clock()

for i=1, nMax do
	numNodes = numNodes * 2
	grid:setNumNodes(numNodes)

	solver:setGrid(grid)
	solver:solve()
	local values = grid:getNodeValues()
	print("Num nodes: "..numNodes)
	-- print(unpack(values))
	print("=========================")
end

local stop = os.clock()

print(stop - start)