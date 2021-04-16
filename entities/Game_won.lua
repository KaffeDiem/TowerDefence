Game_won = Class:extend()
local lg = love.graphics


function Game_won:new()
  self.background = lg.newImage("images/background.png")
  self.nextLevel = Timer(3)
end


function Game_won:update(dt)
  self.nextLevel:update(dt)

  if self.nextLevel:hasFinished() then

    -- Take care of global difficulty level
    if DIFFICULTY == 'easy' then
      local randommap = Map.createRandomMap()
      MAP = Map(randommap[1], randommap[2], randommap[3], randommap[4])
      MAP:generateMobs(WAVES.easy)
      GAMESTATE = "running"
    end

  end
end


function Game_won:draw()
  lg.draw(self.background, 0, 0, 0,
    lg:getWidth() / self.background:getWidth(),
    lg:getHeight() / self.background:getHeight()
  )

  lg.setFont(iflash_big)
  local string = "Prepare for next level!"
  local stringWidth = lg.getFont():getWidth(string) -- Get width of font
  lg.print("Prepare for next level",
    lg:getWidth()/2 - stringWidth/2, lg:getHeight()/2
  )
end