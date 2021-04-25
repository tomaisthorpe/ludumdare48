local Gamestate = require("hump.gamestate")
local Class = require("hump.class")

local config = require("config")
local Game = require("game")
local Planet = require("planet")

local System = Class{
  init = function(self)
    self.planets = {}
    self.planetIcons = {}
    self.nextPlanet = 1
    self.lives = 3
    self.canRestart = false
    self.isGameOver = false
    self.isGameComplete = false

    self:calculateScaling()
    self.font = love.graphics.newFont("assets/sharetech.ttf", 16)
    self.fontLarge = love.graphics.newFont("assets/sharetech.ttf", 32)

    self.stars = love.graphics.newCanvas(800, 600)

    love.graphics.setCanvas(self.stars)
    love.graphics.setColor(12 / 255, 20 / 255, 26 / 255)
    love.graphics.rectangle("fill", 0, 0, 800, 600)


    for s = 1, 100 do
      local x = love.math.random(800)
      local y = love.math.random(600)
      local alpha = love.math.random() / 2

      love.graphics.setColor(1, 252 / 255, 168 / 255, alpha)
      love.graphics.points(x, y)
    end

    love.graphics.setCanvas()
  end,
  translate = {0, 0},
  scaling = 1,
}

function System:enter()
  -- Create starfield

  self:generate()
end

function System:resume(prev, status)
  -- If status complete, then unlock next planet
  if status == "complete" then
    if self.nextPlanet == #self.planets then
      -- GAME COMPLETE!
      self.canRestart = true
      self.isGameComplete = true
      self.nextPlanet = self.nextPlanet + 1
    else
      self.nextPlanet = self.nextPlanet + 1
    end
  end

  if status == "killed" then

    self.lives = self.lives - 1
    if self.lives == 0 then
      self.canRestart = true
      self.isGameOver = true
    else
      love.window.showMessageBox("You were killed.", "Try again. You have ".. self.lives .. " more lives.")
    end
  end
end

function System:draw()

  print(#self.planets)
  love.graphics.push()
  love.graphics.translate(System.translate[1], System.translate[2])
  love.graphics.scale(System.scaling)


  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.stars)

  love.graphics.setColor(1, 212 / 255, 71 / 255)
  love.graphics.circle("fill", -550, 300, 600)

  love.graphics.setColor(1, 1, 1)

  for p = 1, #self.planetIcons do
    local icon = self.planetIcons[p]
    love.graphics.push()
    love.graphics.translate(icon.x, icon.y)

    self.planets[p]:drawMini(self.nextPlanet == p)

    if self.nextPlanet > p then
      love.graphics.push()
      love.graphics.setFont(self.font)
      love.graphics.setColor(1, 1, 1)
      love.graphics.rotate(-0.1)
      love.graphics.printf("Cleared!", -60, -8, 120, "center")
      love.graphics.pop()
    end

    love.graphics.pop()
  end

  self:drawUI()

  love.graphics.pop()

  -- Draw borders
  love.graphics.setColor(config.borderColor[1], config.borderColor[2], config.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, System.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), System.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - System.translate[1], 0, System.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - System.translate[2], love.graphics.getWidth(), System.translate[2])
end

function System:drawUI()
  -- Lives
  love.graphics.setFont(self.font)
  love.graphics.setColor(1, 1, 1)

  if not self.canRestart then
    love.graphics.printf("Lives remaining:" .. self.lives, 10, 500, 800, "center")
  end
  love.graphics.printf("ESC to quit", 16, 568, 800, "center")

  love.graphics.printf("The system has been taken over! Clear each planet to complete the game.", 10, 120, 800, "center")
  love.graphics.printf("You need to clear one planet at a time. Click on the highlighted planet to start.", 10, 150, 800, "center")

  love.graphics.setFont(self.fontLarge)
  love.graphics.setColor(config.titleShadowColor)
  love.graphics.printf("Clear the system!", 0, 34, 800, "center")

  love.graphics.setColor(config.titleColor)
  love.graphics.printf("Clear the system!", 0, 32, 800, "center")


  if self.isGameComplete then
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(config.titleShadowColor)
    love.graphics.printf("System cleared!", 0, 380, 800, "center")

    love.graphics.setColor(config.titleColor)
    love.graphics.printf("System cleared!", 0, 378, 800, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("You've cleared the system! Thanks for playing!", 10, 420, 800, "center")
    love.graphics.printf("Press space to play again in a newly generated system.", 10, 442, 800, "center")
  end

  if self.isGameOver then
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(config.titleShadowColor)
    love.graphics.printf("Game over!", 0, 380, 800, "center")

    love.graphics.setColor(config.titleColor)
    love.graphics.printf("Game over!", 0, 378, 800, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("You lost all your lives.", 10, 420, 800, "center")
    love.graphics.printf("Press space to play again in a newly generated system.", 10, 442, 800, "center")
  end

end

function System:generate()
  local xInterval = 800 / (config.planetsPerSystem + 1)

  -- Shuffle the planet types
  local types = config.planetTypes
  shuffle(types)
  local count = 1

  for _, type in pairs(types) do
    local difficulty = count / config.planetsPerSystem
    local planet = Planet(difficulty, type)
    table.insert(self.planets, planet)

    table.insert(self.planetIcons, {
      x = count * xInterval,
      y = 300,
    })

    count = count + 1
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

  if self.canRestart and key == "space" then
    Gamestate.switch(System())
  end
end

function System:mousereleased(x, y, button)
  if button ~= 1 then
    return
  end

  local mx, my = self:getMousePosition()
  -- Check if any planets are in the correct place
  for p = 1, #self.planetIcons do
    local icon = self.planetIcons[p]
    local dx = math.abs(mx - icon.x)
    local dy = math.abs(my - icon.y)
    local d = math.sqrt(dx * dx + dy * dy)

    -- User must have clicked on the planet!
    if d <= config.miniPlanetRadius[self.planets[p].sizeName] then
      if self.nextPlanet == p and self.canRestart == false then
        Gamestate.push(Game, self.planets[p])
      end
    end
  end
end

function System:getMousePosition()
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  return mx, my
end

function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function shuffle(array)
    local counter = #array
    while counter > 1 do
        local index = love.math.random(counter)
        swap(array, index, counter)
        counter = counter - 1
    end
  end

return System

