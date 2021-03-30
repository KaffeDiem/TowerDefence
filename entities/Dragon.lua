Dragon = Mob:extend()


function Dragon:new(spawn, target, worldMap, worldPos)
  Dragon.super:new(spawn, target, worldMap, worldPos)
  self.movSpeed = 100
end


function Dragon:update(dt)
  Dragon.super:update(dt)
end


function Dragon:draw()
  Dragon.super:draw(dt)
end