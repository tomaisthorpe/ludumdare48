local config = require("config")
local Game = require("game")
local Planet = require("planet")

local System = {
  translate = {0, 0},
  scaling = 1,
  planets = {},
}

function System:init()
  -- Window setup
  love.window.setMode(800, 600)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setFullscreen(config.fullscreen)

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

  -- Work out location of planets
  local xInterval = 800 / (#self.planets + 1)

  for p = 1, #self.planets do
    love.graphics.push()
    love.graphics.translate( p * xInterval, 300)

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
  for p = 1, config.planetsPerSystem do
    table.insert(self.planets, Planet())
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


return System
