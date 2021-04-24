local Camera = require("Camera")

local config = require("config")
local Planet = require("planet")
local Player = require("player")

local game = {
  translate = {0, 0},
  scaling = 1,
}

function game:init()
  -- Window setup
  love.window.setMode(800, 600)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setFullscreen(config.fullscreen)

  game:calculateScaling()
end

function game:enter()
  self.planet = Planet()

  -- Create the player
  self.player = Player(self, self.planet.world, 100, 100)

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle('TOPDOWN_TIGHT')
  self.camera:setBounds(0, 0, self.planet.size[1], self.planet.size[2])

end

function game:update(dt)
  self.planet:update(dt)
  self.player:update(dt)

  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())
end

function game:draw()
  love.graphics.push()
  love.graphics.translate(game.translate[1], game.translate[2])
  love.graphics.scale(game.scaling)

  love.graphics.setColor(1, 1, 1)

  self.camera:attach()

  -- Draw game
  self.planet:draw()
  self.player:draw()
  
  self.camera:detach()
  love.graphics.pop()

  -- Draw borders
  love.graphics.setColor(config.borderColor[1], config.borderColor[2], config.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - game.translate[1], 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - game.translate[2], love.graphics.getWidth(), game.translate[2])
end

function game:getMousePosition()
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  local cx, cy = self.camera:toWorldCoords(mx, my)

  return mx, my, cx, cy
end

function game:resize()
  love.window.setMode(800, 600)
  game:calculateScaling()
end

function game:calculateScaling()
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    game.scaling = minEdge / 600
     game.translate = {(love.graphics.getWidth() - (800 * game.scaling)) / 2, 0}
  else
    game.scaling = love.graphics.getWidth() / 800
  end
end

function game:keypressed(key)
  if key == "escape" then 
    love.event.quit()
  end
end

return game