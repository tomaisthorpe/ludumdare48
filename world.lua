local Class = require("hump.class")

local config = require("config")

local World = Class{
  init = function(self)

    self:generate()

  end,
  size = {0,0},
  grid = {},
}

function World:generate()
  -- Calculate world size
  -- TODO randomize world size
  self.size = config.worldSize

  -- Generate the heightmap
  -- TODO many frequency
  local freq = 0.004
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = love.math.noise( freq * x, freq * y)
    end
  end

  -- Draw the canvas
  self.mapCanvas = love.graphics.newCanvas(self.size[1], self.size[2])
  love.graphics.setCanvas(self.mapCanvas)
  for x = 1, #self.grid do
    for y = 1, #self.grid[x] do
      local min = 25
      local max = 35

      local l = min + (max - min) * self.grid[x][y]

      love.graphics.setColor(HSL(126, 40, l, 1))
      love.graphics.rectangle("fill", x, y, 1, 1)
    end
  end

  love.graphics.setCanvas()
end

-- Converts HSL to RGB
function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h/360*6, s/100, l/100
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

return World