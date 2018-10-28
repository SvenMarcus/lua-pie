math = require "math"
local os = require "os"

local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private
local extends = classy.extends
local import = classy.import

class "OneDimGrid" {
	public {
		constructor = function()
			self.numNodes = 0
			self.length = 0.0
			self.gridDelta = 0.0
			self.coordinates = {}
			self.nodeValues = {}
		end;

		setNumNodes = function(num)
			self.numNodes = num

			for _=1, num do
				table.insert(self.coordinates, 0)
				table.insert(self.nodeValues, 0)
			end

			self.calcGridDelta()
			self.calcCoordinates()
		end;

		setLength = function(l)
			self.length = l
		end;

		setNodeValues = function(values)
			self.nodeValues = values
		end;

		setLeftBC = function(bc)
			self.nodeValues[1] = bc
		end;

		setRightBC = function(bc)
			self.nodeValues[#self.nodeValues] = bc
		end;

		setGridNodeValue = function(index, value)
			self.nodeValues[index] = value
		end;

		getNumNodes = function()
			return self.numNodes
		end;

		getLength = function()
			return self.length
		end;

		getGridDelta = function()
			return self.gridDelta
		end;

		getCoordinateOf = function(node)
			return self.coordinates[node]
		end;

		getLeftBC = function()
			return self.nodeValues[1]
		end;

		getRightBC = function()
			return self.nodeValues[#self.nodeValues]
		end;

		getNodeValues = function()
			return self.nodeValues
		end
	};

	private {
		calcGridDelta = function()
			self.gridDelta = self.length / (self.numNodes - 1)
		end;

		calcCoordinates = function()
			for i=1, self.numNodes do
				self.coordinates[i] = (i - 1) * self.gridDelta
			end
		end;
	}
}

class "GridSolver" {
	public {
		constructor = function(grid, func)
			self.func = func
			self.grid = grid
			self.gridDelta = self.grid.getGridDelta()
			self.lastStepValues = nil
			self.newStepValues = nil
			self.initArrays()
		end;

		solve = function()
			local delta
			self.gridDelta = self.grid.getGridDelta()

			repeat
				delta = 0.0

				for i=2, (self.grid.getNumNodes() - 1) do
					self.calculateNewData(i)
					delta = self.calculateDelta(delta, i)
				end

				self.swap()
			until (delta < self.exitCondition)

			self.grid.setNodeValues(self.newStepValues)
		end;

		setExitCondition = function(ec)
			self.exitCondition = ec
		end;

		setGrid = function(grid)
			self.grid = grid
			self.initArrays()
		end;

		setFunction = function(func)
			self.func = func
		end;
	};

	private {
		initArrays = function()
			local numNodes = self.grid.getNumNodes()
			self.lastStepValues = self.zeros(numNodes)
			self.newStepValues = self.zeros(numNodes)
			self.lastStepValues[1] = self.grid.getLeftBC()
			self.lastStepValues[#self.lastStepValues] = self.grid.getRightBC()
			self.newStepValues[1] = self.grid.getLeftBC()
			self.newStepValues[#self.newStepValues] = self.grid.getRightBC()
		end;

		calculateNewData = function(index)
			local coord = self.grid.getCoordinateOf(index)
			local data = 0.5 * (self.lastStepValues[index + 1] +self.lastStepValues[index - 1] - self.gridDelta * self.gridDelta * self.func(coord))
			self.newStepValues[index] = data
		end;

		calculateDelta = function(lastDelta, index)
			return math.max(math.abs(self.newStepValues[index] - self.lastStepValues[index]), lastDelta)
		end;

		swap = function()
			local tmp = self.lastStepValues
			self.lastStepValues = self.newStepValues
			self.newStepValues = tmp
		end;

		zeros = function(num)
			local t = {}
			for _=1, num do
				table.insert(t, 0)
			end
			return t
		end;
	};
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
grid.setLength(length)
grid.setLeftBC(leftBC)
grid.setRightBC(rightBC)

local solver = GridSolver(grid, func)
solver.setExitCondition(1e-15)
solver.setFunction(func)

local start = os.clock()

for i=1, nMax do
	numNodes = numNodes * 2
	grid.setNumNodes(numNodes)

	solver.setGrid(grid)
	solver.solve()
	local values = grid.getNodeValues()
	print("Num nodes: "..numNodes)
	-- print(unpack(values))
	print("=========================")
end

local stop = os.clock()

print(stop - start)