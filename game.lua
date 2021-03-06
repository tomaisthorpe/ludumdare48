local Camera = require("Camera")
local Gamestate = require "hump.gamestate"

local config = require("config")
local Planet = require("planet")
local Player = require("player")
local Enemy = require("enemy")

local Game = {
  translate = {0, 0},
  scaling = 1,
}

function Game:init()
  -- Window setup
  Game:calculateScaling()

  self.font = love.graphics.newFont("assets/sharetech.ttf", 16)
  self.fontLarge = love.graphics.newFont("assets/sharetech.ttf", 32)

  self.sounds = {
    shoot = love.audio.newSource('assets/shoot.wav', 'static'),
    hit = love.audio.newSource('assets/hit.wav', 'static'),
    death = love.audio.newSource('assets/death.wav', 'static'),
  }
end

function Game:playSound(name)
  self.sounds[name]:play()
end

function Game:enter(prev, planet)
  self.planet = planet

  self.killed = false
  self.cleared = false

  -- Create the player
  self.player = Player(self, self.planet.world, 100, 100)

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle('TOPDOWN_TIGHT')
  self.camera:setBounds(0, 0, self.planet.size[1], self.planet.size[2])

  self.entities = {}
  self.enemies = {}

  -- Spawn all the enemies
  for e = 1, #self.planet.enemyLocations do
    local loc = self.planet.enemyLocations[e]
    table.insert(self.enemies, Enemy(
      self,
      self.planet.world,
      loc.x,
      loc.y
    ))
  end
end

function Game:leave()
  for e = 1, #self.enemies do
    self.enemies[e]:destroy()
  end

  for e = 1, #self.entities do
    self.entities[e]:destroy()
  end

  self.player:destroy()
end

function Game:update(dt)
  if self.killed or self.cleared then
    return
  end

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

  for i, e in ipairs(self.enemies) do
    if e.dead then
      table.remove(self.enemies, i)
    else
      e:update(dt)
    end
  end

  if #self.enemies == 0 then
    self.state = "complete"
    self.cleared = true
  end
end

function Game:gameOver()
  self.state = "killed"
  self.killed = true
end

function Game:enemyKilled()
end

function Game:draw()
  love.graphics.push()
  love.graphics.translate(Game.translate[1], Game.translate[2])
  love.graphics.scale(Game.scaling)

  love.graphics.setColor(1, 1, 1)

  self.camera:attach()

  -- Draw game
  self.planet:draw()
 
  self.player:drawShadow(self.planet)

  for e = 1, #self.enemies do
    if not self.enemies[e].dead then
      self.enemies[e]:drawShadow(self.planet)
    end
  end

  for e = 1, #self.entities do
    if not self.entities[e].dead then
      self.entities[e]:draw()
    end
  end

  self.player:draw()

  for e = 1, #self.enemies do
    if not self.enemies[e].dead then
      self.enemies[e]:draw()
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
  self:drawMinimap()

  -- Health bar
  love.graphics.push()
  love.graphics.translate(800 - config.healthWidth - 16, 16)
  love.graphics.setColor(config.healthBorderColor)
  love.graphics.setLineWidth(config.healthBorderWidth)
  love.graphics.rectangle("line", 0, 0, config.healthWidth, config.healthHeight)

  love.graphics.setColor(config.healthColor)
  love.graphics.rectangle("fill", config.healthBorderWidth * 2, config.healthBorderWidth * 2, (config.healthWidth - config.healthBorderWidth * 4) * (self.player.health / 100), config.healthHeight - config.healthBorderWidth * 4)
  love.graphics.pop()

  -- Health text
  love.graphics.setFont(self.font)
  love.graphics.setColor(config.healthColor)
  love.graphics.printf("Health", 800 - config.healthWidth - 128, 16, 100, "right")

  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.printf("Enemies remaining: " .. #self.enemies, 16, 17, 200)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Enemies remaining: " .. #self.enemies, 16, 16, 200)

  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.printf("WASD / Arrow keys to move", 16, 523, 800)
  love.graphics.printf("Click to shoot", 16, 545, 800)
  love.graphics.printf("ESC to quit", 16, 569, 800)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("WASD / Arrow keys to move", 16, 522, 800)
  love.graphics.printf("Click to shoot", 16, 544, 800)
  love.graphics.printf("ESC to quit", 16, 568, 800)

  if self.killed then
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.printf("You've been killed!", 0, 202, 800, "center")
    love.graphics.printf("Press space to continue.", 0, 232 , 800, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("You've been killed!", 0, 200, 800, "center")
    love.graphics.printf("Press space to continue.", 0, 230 , 800, "center")
  end

  if self.cleared then
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.printf("You cleared this planet!", 0, 202, 800, "center")
    love.graphics.printf("Press space to continue.", 0, 232 , 800, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("You cleared this planet!", 0, 200, 800, "center")
    love.graphics.printf("Press space to continue.", 0, 230 , 800, "center")
  end
end

function Game:drawMinimap()
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

  -- Draw enemies
  for e=1, #self.enemies do
    if not self.enemies[e].dead then
      local x = self.enemies[e]:getX() * ms
      local y = self.enemies[e]:getY() * ms

      love.graphics.setColor(1, 0, 0)
      love.graphics.rectangle("fill", x - 2, y - 2, 4, 4)
    end
  end

  -- Draw bullets?
  for e=1, #self.entities do
    if not self.entities[e].dead then
      local x = self.entities[e]:getX() * ms
      local y = self.entities[e]:getY() * ms

      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", x - 2, y - 2, 1, 1)
    end
  end

  -- Camera box
  local c = self.camera
  local x = c.x - c.w / 2
  local y = c.y- c.h / 2
  love.graphics.setColor(1, 1, 1, 0.04)
  love.graphics.rectangle("fill", x * ms, y * ms, c.w * ms, c.h * ms)
  love.graphics.setColor(1, 1, 1, 0.1)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x * ms, y * ms, c.w * ms, c.h * ms)
  

  -- Border
  love.graphics.setColor(config.minimapBorderColor)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", 0, 0, config.minimapSize[1], config.minimapSize[2])

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
  if key == "space" and (self.killed or self.cleared) then
    Gamestate.pop(self.state)
  end
  if key == "escape" then 
    love.event.quit()
  end
end

return Game