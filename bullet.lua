local Class = require 'hump.class'

local Bullet =  Class{
  init = function(self, game, world, x, y, theta, targetClass)
    self.game = game
    self.object = world:newCircleCollider(x, y, 3)
    self.object:setLinearVelocity(math.cos(theta) * 1000, math.sin(theta) * 1000)
    self.object:setAngle(theta)
    self.object:setBullet(true)

    self.targetClass = targetClass
    self.object:setCollisionClass('Bullet')
  end,
  dead = false,
  damage = 100
}

function Bullet:getX()
  return self.object:getX()
end

function Bullet:getY()
  return self.object:getY()
end

function Bullet:update(dt)
  if self.object:enter('Solid') then
    self:destroy()
  end

  if self.object:enter(self.targetClass) then
    local collision = self.object:getEnterCollisionData(self.targetClass)
    local object = collision.collider:getObject()

    if object then
      object:damage(self.damage)
    end

    self:destroy()
  end
end

function Bullet:destroy()
  self.object:destroy()
  self.dead = true
end

function Bullet:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 3)
end

return Bullet
