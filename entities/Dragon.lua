Dragon = Class:extend()


function Dragon:new(spawn, target, worldMap, worldPos)
  self.super = Mob(spawn, target, worldMap, worldPos) -- //BUG when same function called for multiple objects
end


function Dragon:update(dt)
  self.super:update(dt)
end


function Dragon:draw()
  self.super:draw()
end