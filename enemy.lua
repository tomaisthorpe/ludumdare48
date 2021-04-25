local Class = require("hump.class")
local Bullet = require('bullet')

local Enemy = Class {
  init = function(self, game, world, x, y)
    self.game = game
    self.world = world

    self.object = world:newRectangleCollider(x - 12, y - 12, 24, 24)
    self.object:setCollisionClass('Enemy')
    self.object:setObject(self)
    self.object:setFixedRotation(true)
    self.object:setLinearDamping(5)

    self.image = love.graphics.newImage("assets/enemy.png")
  end,
  speed = 5001,
  health = 100,

  dead = false,
  fireRate = 1,
  lastShot = 0,
}

function Enemy:getX() 
  return self.object:getX()
end

function Enemy:getY() 
  return self.object:getY()
end

function Enemy:damage(dmg)
  self.health = self.health - dmg

  if self.health <= 0 then
    self.dead = true
    self.health = 0
    self.game:enemyKilled()
  end
end

function Enemy:update(dt)
  -- Check how close player is, if they're close. Face them!

  local px = self.game.player:getX()
  local py = self.game.player:getY()

  local dx = px - self:getX()
  local dy = py - self:getY()

  local d = math.sqrt(dx * dx + dy * dy)
  if d < 300 then
    local theta = math.atan2(dy, dx)

    self.object:setAngle(theta)

    self:shoot()
  end
end

function Enemy:shoot()
  -- Check the user can actually shoot
  if self.lastShot >= love.timer.getTime() - self.fireRate then
    return
  end

  self.lastShot = love.timer.getTime()


  local px = self.game.player:getX()
  local py = self.game.player:getY()

  local dx = px - self:getX()
  local dy = py - self:getY()
  local theta = math.atan2(dy, dx)

  local bullet = Bullet(self.game, self.world, self:getX(), self:getY(), theta, 'Player')
  self.game:addEntity(bullet)
end

function Enemy:draw()
  if self.dead then
    return
  end

  love.graphics.push()

  love.graphics.setColor(1, 1, 1)
  
  -- Translate as we need to draw at 0,0 for rotation
  love.graphics.translate(self:getX(), self:getY())
  love.graphics.rotate(self.object:getAngle() + math.pi / 2)
  love.graphics.translate(-12, -12)

  love.graphics.draw(self.image)

  love.graphics.pop()
end

return Enemy