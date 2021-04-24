local Gamestate = require("hump.gamestate")

local System = require("system")
local game = require("game")

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(System)

  love.window.setTitle("Ludum Dare 48")
end

function setupWindow()
  love.window.setMode(800, 600)
end
