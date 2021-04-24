local Class = require("hump.class")
local wf = require("windfield")

local config = require("config")

local Planet = Class{
  init = function(self)

    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass('Player')

    self:generate()
  end,
  size = {0,0},
  grid = {},
}

function Planet:generate()
  -- Calculate planet size
  -- TODO randomize planet size
  self.size = config.planetSize

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

  love.graphics.push()
  for x = 1, #self.grid do
    for y = 1, #self.grid[x] do
      local min = 35
      local max = 40

      local l = min + (max - min) * self.grid[x][y]

      love.graphics.setColor(HSL(126, 40, l, 1))
      love.graphics.rectangle("fill", x, y, 1, 1)
    end
  end

  love.graphics.pop()

  love.graphics.setCanvas()

  -- Add bounding box
  local b1 = self.world:newRectangleCollider(0, 0, 50, self.size[2])
  b1:setType('static')
  local b2 = self.world:newRectangleCollider(0, 0, self.size[1], 50)
  b2:setType('static')
  local b3 = self.world:newRectangleCollider(0, self.size[2] - 50, self.size[1], 50)
  b3:setType('static')
  local b4 = self.world:newRectangleCollider(self.size[1] - 50, 0, 50, self.size[2])
  b4:setType('static')
end

function Planet:update(dt)
  self.world:update(dt)
end

function Planet:draw()
  love.graphics.draw(self.mapCanvas)


  self.world:draw()
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

return Planet