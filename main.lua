local Gamestate = require("hump.gamestate")

local config = require("config")
local System = require("system")
local Game = require("game")
local Planet = require("planet")

function love.load()
  Gamestate.registerEvents()
  love.window.setMode(800, 600)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setFullscreen(config.fullscreen)


  if config.skipSystem then
    Gamestate.switch(Game, Planet(1, 1))
  else
    Gamestate.switch(System)
  end

  love.window.setTitle("Ludum Dare 48")
end

function setupWindow()
  love.window.setMode(800, 600)
end
