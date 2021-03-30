Dragon = Mob:extend()


function Dragon:new(spawn, target, worldMap, worldPos)
  self.super:new(spawn, target, worldMap, worldPos) -- //BUG same function called for multiple objects
  -- Dragon.super.movSpeed = 80 -- Overwrite default movSpeed
end


function Dragon:update(dt)
  self.super:update(dt)
end


function Dragon:draw()
  self.super:draw(dt)
end