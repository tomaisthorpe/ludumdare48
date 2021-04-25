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
    self.dead = false
    self.lifetime = 1
  end,
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
    return
  end

  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 then
    self:destroy()
    return
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
  if self.object then
    self.object:destroy()
    self.dead = true
  end
end

function Bullet:draw()
  love.graphics.push()

  love.graphics.setColor(0.8, 0, 0)
  love.graphics.translate(self.object:getX(), self.object:getY())
  love.graphics.rotate(self.object:getAngle())
  love.graphics.rectangle('fill', -4, -2, 8, 4)

  love.graphics.pop()
end

return Bullet
