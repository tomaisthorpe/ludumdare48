local Camera = require("Camera")
local gamestate = require "hump.gamestate"

local config = require("config")
local Planet = require("planet")
local Player = require("player")

local Game = {
  translate = {0, 0},
  scaling = 1,
}

function Game:init()
  -- Window setup
  Game:calculateScaling()
end

function Game:enter(prev, planet)
  self.planet = planet

  -- Create the player
  self.player = Player(self, self.planet.world, 100, 100)

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle('TOPDOWN_TIGHT')
  self.camera:setBounds(0, 0, self.planet.size[1], self.planet.size[2])

  self.entities = {}
end

function Game:update(dt)
  self.planet:update(dt)
  self.player:update(dt)

  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())

  for i, e in ipairs(self.entities) do
    if e.dead then
      table.remove(self.entities, i)
    else
      e:update(dt)
    end
  end
end

function Game:draw()
  love.graphics.push()
  love.graphics.translate(Game.translate[1], Game.translate[2])
  love.graphics.scale(Game.scaling)

  love.graphics.setColor(1, 1, 1)

  self.camera:attach()

  -- Draw game
  self.planet:draw()
  self.player:draw()

  for e = 1, #self.entities do
    if not self.entities[e].dead then
      self.entities[e]:draw()
    end
  end
  
  self.camera:detach()

  self:drawUI()
  love.graphics.pop()

  -- Draw borders
  love.graphics.setColor(config.borderColor[1], config.borderColor[2], config.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, Game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - Game.translate[1], 0, Game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - Game.translate[2], love.graphics.getWidth(), Game.translate[2])
end

function Game:drawUI()
  -- Minimap
  love.graphics.push()
  love.graphics.translate(800 - config.minimapSize[1], 600 - config.minimapSize[2])

  love.graphics.setColor(config.minimapColor)
  love.graphics.rectangle("fill", 0, 0, config.minimapSize[1], config.minimapSize[2])

  self.planet:drawMinimap()


  -- Draw player on minimap
  local ms = self.planet.minimapScale
  local px = self.player:getX() * ms
  local py = self.player:getY() * ms

  love.graphics.setColor(1, 1, 0)
  love.graphics.rectangle("fill", px - 2, py - 2, 4, 4)

  -- Draw bullets?
  for e=1, #self.entities do
    if not self.entities[e].dead then
      local x = self.entities[e]:getX() * ms
      local y = self.entities[e]:getY() * ms

      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", x - 2, y - 2, 1, 1)
    end
   end

  -- Border
  love.graphics.setColor(config.minimapBorderColor)
  love.graphics.rectangle("line", -1, -1, config.minimapSize[1], config.minimapSize[2])

  love.graphics.pop()
end

function Game:addEntity(entity)
  table.insert(self.entities, entity)
end

function Game:getMousePosition()
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  local cx, cy = self.camera:toWorldCoords(mx, my)

  return mx, my, cx, cy
end

function Game:resize()
  love.window.setMode(800, 600)
  Game:calculateScaling()
end

function Game:calculateScaling()
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    Game.scaling = minEdge / 600
     Game.translate = {(love.graphics.getWidth() - (800 * Game.scaling)) / 2, 0}
  else
    Game.scaling = love.graphics.getWidth() / 800
  end
end

function Game:keypressed(key)
  if key == "escape" then 
    love.event.quit()
  end
  if key == "q" then
  gamestate.pop()
  end
end

return Game