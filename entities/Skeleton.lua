Skeleton = Mob:extend()


function Skeleton:new(spawn, target, worldMap, worldPos)
  Skeleton.super:new(spawn, target, worldMap, worldPos)
end


function Skeleton:update(dt)
  Skeleton.super:update(dt)
end


function Dragon:draw()
  Skeleton.super:draw(dt)
end