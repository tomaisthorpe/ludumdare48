local Class = require("hump.class")

local Enemy = Class {
  init = function(self, game, world, x, y)
    self.game = game
    self.world = world

    self.object = world:newRectangleCollider(x - 10, y - 10, 20, 20)
    self.object:setCollisionClass('Enemy')
    self.object:setObject(self)
    self.object:setFixedRotation(true)
    self.object:setLinearDamping(5)
  end,
  speed = 5001,
  health = 100,

  dead = false,
  fireRate = 0.2,
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

end

function Enemy:draw()
  if self.dead then
    return
  end

  love.graphics.push()

  love.graphics.setColor(1, 0, 0)
  
  -- Translate as we need to draw at 0,0 for rotation
  love.graphics.translate(self:getX(), self:getY())
  love.graphics.rotate(self.object:getAngle())

  love.graphics.polygon("fill", -10, -10, 10, 0, -10, 10)

  love.graphics.pop()
end

return Enemy