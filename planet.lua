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

function Planet:applyNoise(seed, freq, weight)
  for x = 1, self.size[1] / 4 do
    for y = 1, self.size[2] / 4 do
      self.grid[x][y] = self.grid[x][y] + love.math.noise( freq * x + seed, freq * y + seed) * weight
    end
  end
end


function Planet:generate()
  -- Choose the type of planet
  self.type = config.planetTypes[love.math.random(1, #config.planetTypes)]

  -- Calculate planet size
  -- TODO randomize planet size
  self.sizeName = self.type.sizes[love.math.random(1, #self.type.sizes)]
  self.size = config.planetSizes[self.sizeName]

  local seed = love.math.random() * 100
  seed = seed + love.math.random()

  -- Generate the heightmap
  -- TODO many frequency
  for x = 1, self.size[1] / 4 do
    for y = 1, self.size[2] / 4 do
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = 0
    end
  end

  for _, f in pairs(self.type.frequencies) do
    self:applyNoise(seed, f[1], f[2])
  end

  self.seaLevel = love.math.random(3, 7) / 10

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

function Planet:getHeightAt(x, y)
  x = math.ceil(x / 4)
  y = math.ceil(y / 4)

  if x > #self.grid then
    x = #self.grid
  end

  if y > #self.grid[x] then
    y = #self.grid[x]
  end

  return self.grid[x][y]
end

function Planet:pickColor(colorLimits, color, value) 
  local min = color[3][1]
  local max = color[3][2]
  local vMin = colorLimits[1]
  local vMax = colorLimits[2]


  local scaledV = (value - vMin) * 1 / (vMax - vMin);
  local l =  min + (max - min) * scaledV

  return HSL(color[1], color[2], l)
end

function Planet:createCanvas()
  self.mapCanvas = love.graphics.newCanvas(self.size[1], self.size[2])
  love.graphics.setCanvas(self.mapCanvas)

  love.graphics.push()

  love.graphics.scale(4, 4)

  for x = 1, #self.grid do
    for y = 1, #self.grid[x] do
      local v = self.grid[x][y]

      local color = {0, 0, 0}
      local vMax = 1.0

      for _, p in pairs(self.type.palette) do
        if v > p[1] then
          color = self:pickColor(
            {p[1], vMax},
            p[2],
            v
          )
          break
        end
      vMax = p[1]
      end

      love.graphics.setColor(color)
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
  love.graphics.stencil(self:sphereStencil(), "replace", 1)
  love.graphics.setStencilTest("greater", 0)

  love.graphics.push()
  love.graphics.translate(-config.miniPlanetRadius[self.sizeName], -config.miniPlanetRadius[self.sizeName])
  local scale = config.miniPlanetRadius[self.sizeName] * 2 / self.size[2]
  love.graphics.scale(scale, scale)

  love.graphics.draw(self.mapCanvas)

  love.graphics.pop()

  love.graphics.setStencilTest()
end

function Planet:sphereStencil()
  local size = config.miniPlanetRadius[self.sizeName]
  return function() 
    love.graphics.circle("fill", 0, 0, size)

  end
end

-- Converts HSL to RGB
function HSL(h, s, l, a)
	if s<=0 then return {l,l,l,a} end
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
	end return {(r+m),(g+m),(b+m),a}
end

return Planet