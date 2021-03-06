Tower = Class:extend()


function Tower:new(position, worldMap, worldPos)
  self.worldMap = worldMap
  self.worldPos = worldPos
  self.dimensions = Vector(32, 32) -- Default texture is 32x32

  self.image = love.graphics.newImage("images/tower.png")

  self.pos = position -- Vector containing x and y coordinates
  self.currPixelPos = Tower.posToPixel(self.pos, self.dimensions, self.worldPos)

  self.bullets = {}
  self.timerBullet = Timer(1)

  self.range = 60
  self.cost = 2 -- Default towers has a cost of 2

  self.currMob = nil
end


function Tower:update(dt)

  -- This is where the bullets get updated each tick
  for k, bullet in ipairs(self.bullets) do
    bullet:update(dt)

    if bullet.hasHit then
      table.remove(self.bullets, k)
      self.currMob:takeDamage(10)
    end

  end

  self.timerBullet:update()

end


function Tower:draw()
  love.graphics.draw(
    self.image, self.currPixelPos.x, self.currPixelPos.y - 10 * SCALE,
    0, SCALE, SCALE
  )

  for _, b in ipairs(self.bullets) do
    b:draw()
  end
end


-- Translates some Vector coordinate (1, 1) from the tile map
-- to a pixel coordinates for rendering to the screen.
-- Example: 
-- Pos = Vector(1,1)
-- tileW, tileH = 32
-- worldPos = Vector(200, 200)
-- Returns: Vector(300, 453)
function Tower.posToPixel(pos, dim, worldPos)
  return Vector(
    worldPos.x
    + ((pos.y * dim.x / 2) * SCALE)
    - ((pos.x * dim.x / 2) * SCALE)
    ,
    worldPos.y
    + ((pos.x * dim.y / 4) * SCALE)
    + ((pos.y * dim.y / 4) * SCALE)
  )
end


function Tower:shoot(mob)
  self.currMob = mob
  if self.timerBullet:hasFinished() then
    table.insert(self.bullets,
      Bullet(self.currPixelPos, mob.currPixelPos, self.dimensions)
    )
    self.timerBullet:reset()
  end
end
