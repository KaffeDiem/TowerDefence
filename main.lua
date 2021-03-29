-- Importing modules
Class = require "modules.classic"

-- Import A* algorithm
require "modules/luafinding/vector"
require "modules/luafinding/heap"
require "modules/luafinding/luafinding"

require "Map"
require "entities/Dragon"

-- Keep images pixelated as the are scaled in size
love.graphics.setDefaultFilter('nearest')


function love.load()

  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1)

  lvl1 = {
    {6, 6, 1, 6, 6},
    {1, 6, 6, 6, 6},
    {6, 1, 1, 1, 6},
    {6, 6, 6, 6, 6},
    {6, 6, 1, 6, 1},
    {1, 6, 6, 6, 6},
    {1, 1, 1, 6, 6},
    {6, 6, 6, 6, 6},
  }


  lvl1_height = {
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
  }

  lvl2 = {
    {39, 39, 38, 38, 38, 38},
    {39, 38, 38, 38, 38, 38},
    {39, 38, 38, 38, 38, 38},
    {37, 38, 38, 37, 37, 37},
    {37, 37, 37, 37, 37, 37},
    {14, 14, 14, 14, 14, 14},
    {14, 14, 14, 14, 14, 14},
    {1, 1, 1, 1, 1, 1},
    {2, 2, 1, 1, 1, 1},
    {2, 2, 2, 1, 1, 1}
  }

  lvl2_height = {
    {3, 3, 2, 2, 1, 0},
    {2, 2, 2, 1, 0, 0},
    {2, 1, 1, 1, 0, 0},
    {1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
  }

  keyboardOnly = true
  SCALE = 2

  MAP = Map("images/tile_sheet.png", lvl1, lvl1_height, 32, 32)
end


function love.keypressed(key)
  if key == 'space' then
    if MAP.tileSelectionMode == 'height' then
      MAP.tileSelectionMode = 'changetile'
    else MAP.tileSelectionMode = 'height'
    end
  end

  if key == 'enter' then
    love.load()
  end
end


function love.update(dt)
  MAP:update(dt)
end


function love.draw()
  love.graphics.setFont(
    love.graphics.newFont("fonts/fira.ttf", 10)
  )

  love.graphics.print(
    "FPS: " .. love.timer.getFPS(), 10, 10
  )
  local tileSelected = "None"

  if MAP.tileSelected ~= nil then
    tileSelected = MAP.tileSelected[1] .. " x " .. MAP.tileSelected[2]
  end
  love.graphics.print(
    "TILE: " .. tileSelected,
    10, 25
  )
  love.graphics.print(
    "MODE: " .. MAP.tileSelectionMode,
    10, 40
  )

  MAP:draw()
end
