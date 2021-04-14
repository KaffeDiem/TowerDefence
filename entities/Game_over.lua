local lovebird = require "lovebird"
Game_over = Class:extend()
local lg = love.graphics


function Game_over:new()
  self.background = lg.newImage("images/background.png")
end


function Game_over:update(dt)
  local buttonSize = 100 * SCALE

  suit.layout:reset(lg:getWidth()/2 - buttonSize / 2, lg:getHeight()*0.4,
    10 * SCALE, 10 * SCALE
  )

  local again = suit.Button("Try again!", suit.layout:row(buttonSize, 30))
  local main_menu = suit.Button("Exit to main menu", suit.layout:row(buttonSize, 30))

  if again.hit then
    -- Generate a new map
    local randommap = Map.createRandomMap()
    MAP = Map(randommap[1], randommap[2], randommap[3], randommap[4])
    GAMESTATE = "running"
  end

  if main_menu.hit then
    local randommap = Map.createRandomMap()
    MAP = Map(randommap[1], randommap[2], randommap[3], randommap[4])
    GAMESTATE = "menu"
  end
end


function Game_over:draw()
  lg.draw(self.background, 0, 0, 0,
    lg:getWidth() / self.background:getWidth(),
    lg:getHeight() / self.background:getHeight()
  )

  suit:draw()
end