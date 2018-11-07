math = require "math"
local os = require "os"

local classy = require "classy"
local class = classy.class
local static = classy.static
local public = classy.public
local private = classy.private
local extends = classy.extends
local import = classy.import

class "OneDimGrid" {
	public {
		constructor = function(self)
			self.numNodes = 0
			self.length = 0.0
			self.gridDelta = 0.0
			self.coordinates = {}
			self.nodeValues = {}
		end;

		setNumNodes = function(self, num)
			self.numNodes = num

			for _=1, num do
				table.insert(self.coordinates, 0)
				table.insert(self.nodeValues, 0)
			end

			self:calcGridDelta()
			self:calcCoordinates()
		end;

		setLength = function(self, l)
			self.length = l
		end;

		setNodeValues = function(self, values)
			self.nodeValues = values
		end;

		setLeftBC = function(self, bc)
			self.nodeValues[1] = bc
		end;

		setRightBC = function(self, bc)
			self.nodeValues[#self.nodeValues] = bc
		end;

		setGridNodeValue = function(self, index, value)
			self.nodeValues[index] = value
		end;

		getNumNodes = function(self)
			return self.numNodes
		end;

		getLength = function(self)
			return self.length
		end;

		getGridDelta = function(self)
			return self.gridDelta
		end;

		getCoordinateOf = function(self, node)
			return self.coordinates[node]
		end;

		getLeftBC = function(self)
			return self.nodeValues[1]
		end;

		getRightBC = function(self)
			return self.nodeValues[#self.nodeValues]
		end;

		getNodeValues = function(self)
			return self.nodeValues
		end
	};

	private {
		calcGridDelta = function(self)
			self.gridDelta = self.length / (self.numNodes - 1)
		end;

		calcCoordinates = function(self)
			for i=1, self.numNodes do
				self.coordinates[i] = (i - 1) * self.gridDelta
			end
		end;
	}
}

class "GridSolver" {
	public {
		constructor = function(self, grid, func)
			self.func = func
			self.grid = grid
			self.gridDelta = self.grid:getGridDelta()
			self.lastStepValues = nil
			self.newStepValues = nil
			self:initArrays()
		end;

		solve = function(self)
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

		setExitCondition = function(self, ec)
			self.exitCondition = ec
		end;

		setGrid = function(self, grid)
			self.grid = grid
			self:initArrays()
		end;

		setFunction = function(self, func)
			self.func = func
		end;
	};

	private {
		initArrays = function(self)
			local numNodes = self.grid:getNumNodes()
			self.lastStepValues = self.zeros(numNodes)
			self.newStepValues = self.zeros(numNodes)
			self.lastStepValues[1] = self.grid:getLeftBC()
			self.lastStepValues[#self.lastStepValues] = self.grid:getRightBC()
			self.newStepValues[1] = self.grid:getLeftBC()
			self.newStepValues[#self.newStepValues] = self.grid:getRightBC()
		end;

		calculateNewData = function(self, index)
			local coord = self.grid:getCoordinateOf(index)
			local data = 0.5 * (self.lastStepValues[index + 1] +self.lastStepValues[index - 1] - self.gridDelta * self.gridDelta * self.func(coord))
			self.newStepValues[index] = data
		end;

		calculateDelta = function(self, lastDelta, index)
			return math.max(math.abs(self.newStepValues[index] - self.lastStepValues[index]), lastDelta)
		end;

		swap = function(self)
			local tmp = self.lastStepValues
			self.lastStepValues = self.newStepValues
			self.newStepValues = tmp
		end;

	};

	static {
		zeros = function(num)
			local t = {}
			for _=1, num do
				table.insert(t, 0)
			end
			return t
		end;
	}
}


local nMax = 9
local length = 0.1
local numNodes = 2
local rightBC = 1
local leftBC = 0

local OneDimGrid = import("OneDimGrid")
local GridSolver = import("GridSolver")

local func = function(x)
	return math.sin(2 * x * math.pi / length)
end

local grid = OneDimGrid()
grid:setLength(length)
grid:setLeftBC(leftBC)
grid:setRightBC(rightBC)
print(tostring(grid:getNumNodes()))

local solver = GridSolver(grid, func)
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
