local Class = require("hump.class")
local wf = require("windfield")

local config = require("config")

local Planet = Class{
  init = function(self, p, difficulty)
    self.p = p
    self.difficulty = difficulty

    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass('Bullet')
    self.world:addCollisionClass('Enemy', {ignores={'Bullet'}})
    self.world:addCollisionClass('Player', {ignores={'Bullet'}})
    self.world:addCollisionClass('Solid')

    self.size = {0,0}
    self.grid = {}
    self.minimapScale = 1
    self.enemyLocations = {}

    self:generate()
  end
}

function Planet:generate()
  -- Calculate planet size
  -- TODO randomize planet size
  self.size = config.planetSize

  local seed = love.math.random()

  -- Generate the heightmap
  -- TODO many frequency
  local freq = 0.008
  for x = 1, self.size[1] / 4 do
    for y = 1, self.size[2] / 4 do
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = love.math.noise( freq * x, freq * y,seed)
    end
  end

  -- Add bounding box
  local b1 = self.world:newRectangleCollider(0, 0, 50, self.size[2])
  b1:setCollisionClass('Solid')
  b1:setType('static')
  local b2 = self.world:newRectangleCollider(0, 0, self.size[1], 50)
  b2:setType('static')
  b2:setCollisionClass('Solid')
  local b3 = self.world:newRectangleCollider(0, self.size[2] - 50, self.size[1], 50)
  b3:setType('static')
  b3:setCollisionClass('Solid')
  local b4 = self.world:newRectangleCollider(self.size[1] - 50, 0, 50, self.size[2])
  b4:setType('static')
  b4:setCollisionClass('Solid')

  self:createCanvas()
  self:createMinimap()

  -- Create some enemy spawns
  for e = 1, 5 * self.difficulty do
    local x = love.math.random(200, self.size[1] - 200)
    local y = love.math.random(200, self.size[2] - 200)

    table.insert(self.enemyLocations, {
      x = x,
      y = y,
    })
  end
end

function Planet:createCanvas()
  self.mapCanvas = love.graphics.newCanvas(self.size[1], self.size[2])
  love.graphics.setCanvas(self.mapCanvas)

  love.graphics.push()

  love.graphics.scale(4, 4)

  local hue = 126
  if self.p == 2 then
    hue = 9
  elseif self.p == 3 then
    hue = 256
  end

  for x = 1, #self.grid do
    for y = 1, #self.grid[x] do
      local min = 0
      local max = 100

      local l = min + (max - min) * self.grid[x][y]



      love.graphics.setColor(HSL(hue, 26, l, 1))
      love.graphics.rectangle("fill", x, y, 1, 1)
    end
  end

  love.graphics.pop()

  love.graphics.setCanvas()
end

function Planet:createMinimap()
  -- This is the scale used for adding entities 
  self.minimapScale = config.minimapSize[1] / self.size[1]

  self.minimapCanvas = love.graphics.newCanvas(config.minimapSize[1], config.minimapSize[2])
  love.graphics.setCanvas(self.minimapCanvas)

  love.graphics.push()

  local drawScale = config.minimapSize[1] / #self.grid
  love.graphics.scale(drawScale, drawScale)

  for x = 1, #self.grid do
    for y = 1, #self.grid[x] do
      local brightness = math.ceil(self.grid[x][y] * 8) / 8
      love.graphics.setColor(brightness, brightness, brightness)
      love.graphics.rectangle("fill", x, y, 1, 1)
    end
  end

  love.graphics.pop()

  love.graphics.setCanvas()
end


function Planet:update(dt)
  self.world:update(dt)
end

function Planet:draw()
  love.graphics.draw(self.mapCanvas)

  if config.physicsDebug then
    self.world:draw()
  end
end

function Planet:drawMinimap()
  love.graphics.draw(self.minimapCanvas)
end

function Planet:drawMini(current)
  local alpha = 0.25
  if current then
    alpha = 1
  end

  love.graphics.setColor(1, 1, 1, alpha)
  love.graphics.stencil(sphereStencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)

  love.graphics.push()
  love.graphics.translate(-config.miniPlanetRadius, -config.miniPlanetRadius)
  local scale = config.miniPlanetRadius * 2 / self.size[2]
  love.graphics.scale(scale, scale)

  love.graphics.draw(self.mapCanvas)

  love.graphics.pop()

  love.graphics.setStencilTest()
end

function sphereStencil()
  love.graphics.circle("fill", 0, 0, 60)
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