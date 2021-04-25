local Class = require("hump.class")

local Bullet = require("bullet")

local Player = Class {
  init = function(self, game, world, x, y)
    self.game = game
    self.world = world

    self.object = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    self.object:setCollisionClass('Player')
    self.object:setObject(self)
    self.object:setFixedRotation(true)
    self.object:setLinearDamping(5)
    self.health = 100

    self.image = love.graphics.newImage("assets/player.png")
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


function Player:damage(dmg)
  self.health = self.health - dmg * 0.5
  self.game.camera:shake(2, 0.25)

  if self.health <= 0 then
    self.dead = true
    self.health = 0
    self.game:playSound('death')
    self.game:gameOver()
  else
    self.game:playSound('hit')
  end
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

  local bullet = Bullet(self.game, self.world, self:getX(), self:getY(), theta, 'Enemy')
  self.game:addEntity(bullet)
  self.game:playSound('shoot')
end

function Player:drawShadow(planet)
  love.graphics.push()

  love.graphics.setColor(0, 0, 0, 0.1)
  
  -- Translate as we need to draw at 0,0 for rotation
  love.graphics.translate(self:getX(), self:getY() + 8)

  love.graphics.rotate(self.object:getAngle() + math.pi / 2)
  local height = planet:getHeightAt(self:getX(), self:getY())
  local scale = 0.75 + (1 - height) / 3
  love.graphics.scale(scale, scale)
  love.graphics.translate(-16, -16)

  love.graphics.draw(self.image)

  love.graphics.pop()
end

function Player:draw()
  love.graphics.push()

  love.graphics.setColor(1, 1, 1)
  
  -- Translate as we need to draw at 0,0 for rotation
  love.graphics.translate(self:getX(), self:getY())
  love.graphics.rotate(self.object:getAngle() + math.pi / 2)
  love.graphics.translate(-16, -16)

  love.graphics.draw(self.image)

  love.graphics.pop()
end

return Player