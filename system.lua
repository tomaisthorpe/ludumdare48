local Gamestate = require("hump.gamestate")

local config = require("config")
local Game = require("game")
local Planet = require("planet")

local System = {
  translate = {0, 0},
  scaling = 1,
  planets = {},
  planetIcons = {},
}

function System:init()
  self:calculateScaling()
end

function System:enter()
  self:generate()
end

function System:draw()
  love.graphics.push()
  love.graphics.translate(System.translate[1], System.translate[2])
  love.graphics.scale(System.scaling)

  love.graphics.setColor(1, 1, 1)

  for p = 1, #self.planetIcons do
    local icon = self.planetIcons[p]
    love.graphics.push()
    love.graphics.translate(icon.x, icon.y)

    self.planets[p]:drawMini()

    love.graphics.pop()
  end

  love.graphics.pop()

  -- Draw borders
  love.graphics.setColor(config.borderColor[1], config.borderColor[2], config.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, System.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), System.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - System.translate[1], 0, System.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - System.translate[2], love.graphics.getWidth(), System.translate[2])
end

function System:generate()
  local xInterval = 800 / (config.planetsPerSystem + 1)

  for p = 1, config.planetsPerSystem do
    local planet = Planet(p)
    table.insert(self.planets, planet)

    table.insert(self.planetIcons, {
      x = p * xInterval,
      y = 300,
    })
  end
end

function System:calculateScaling()
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    System.scaling = minEdge / 600
    System.translate = {(love.graphics.getWidth() - (800 * System.scaling)) / 2, 0}
  else
    System.scaling = love.graphics.getWidth() / 800
  end
end

function System:keypressed(key)
  if key == "escape" then 
    love.event.quit()
  end
end

function System:mousereleased(x, y, button)
  if button ~= 1 then
    return
  end

  local mx, my = self:getMousePosition()
  -- Check if any planets are in the correct place
  for p = 1, #self.planetIcons do
    local icon = self.planetIcons[p]
    local dx = math.abs(mx - icon.x)
    local dy = math.abs(my - icon.y)
    local d = math.sqrt(dx * dx + dy * dy)

    -- User must have clicked on the planet!
    if d <= config.miniPlanetRadius then
      print(self.planets[p].size.x)
      Gamestate.push(Game, self.planets[p])
    end
  end
end

function System:getMousePosition()
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  return mx, my
end

return System
