local Class = require("hump.class")

local Bullet = require("bullet")

local Player = Class {
  init = function(self, game, world, x, y)
    self.game = game
    self.world = world

    self.object = world:newRectangleCollider(x - 10, y - 10, 20, 20)
    self.object:setCollisionClass('Player')
    self.object:setObject(self)
    self.object:setFixedRotation(true)
    self.object:setLinearDamping(5)
  end,
  speed = 5001,

  fireRate = 0.2,
  lastShot = 0,
}

function Player:getX() 
  return self.object:getX()
end

function Player:getY() 
  return self.object:getY()
end

function Player:update(dt)
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    self.object:applyForce(-self.speed * self.object:getMass(), 0)
  end

  if love.keyboard.isDown('right') or love.keyboard.isDown('d')  then
    self.object:applyForce(self.speed * self.object:getMass(), 0)
  end

  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self.object:applyForce(0, -self.speed * self.object:getMass())
  end

  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self.object:applyForce(0, self.speed * self.object:getMass())
  end

  if love.mouse.isDown(1) then
    self:shoot()
  end

  local _, _, cx, cy =  self.game:getMousePosition()

  local dx = cx - self:getX()
  local dy = cy - self:getY()
  local theta = math.atan2(dy, dx)

  self.object:setAngle(theta)
end

function Player:shoot()
  -- Check the user can actually shoot
  if self.lastShot >= love.timer.getTime() - self.fireRate then
    return
  end

  self.lastShot = love.timer.getTime()

  local _, _, cx, cy = self.game:getMousePosition()

  local dx = cx - self:getX()
  local dy = cy - self:getY()
  local theta = math.atan2(dy, dx)

  local bullet = Bullet(self.game, self.world, self:getX(), self:getY(), theta)
  self.game:addEntity(bullet)
end

function Player:draw()
  love.graphics.push()

  love.graphics.setColor(1, 0, 1)
  
  -- Translate as we need to draw at 0,0 for rotation
  love.graphics.translate(self:getX(), self:getY())
  love.graphics.rotate(self.object:getAngle())

  love.graphics.polygon("fill", -10, -10, 10, 0, -10, 10)

  love.graphics.pop()
end

return Player