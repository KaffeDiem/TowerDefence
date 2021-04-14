Bullet = Class:extend()


-- Bullets take a spawn and destination to go to
function Bullet:new(spawn, goal, dimensions)

  self.dims = dimensions
  self.currPos = spawn + (dimensions * SCALE / 2)
  self.goal = goal + (dimensions * SCALE / 2)

  self.speed = 150

  local dist = Vector.dist(spawn, goal)
  self.dir = (goal - spawn) / dist -- Direction which the bullet travels

  self.hasHit = false
end


function Bullet:update(dt)
  -- Update the position of the bullet each tick
  self.currPos = self.currPos + (self.dir * self.speed * dt)

  if Vector.dist(self.currPos, self.goal) < 5 then
    self.hasHit = true
  end

end


function Bullet:draw()
  love.graphics.circle('fill',
    self.currPos.x, self.currPos.y, 2 * SCALE
  )
end