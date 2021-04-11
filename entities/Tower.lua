Tower = Class:extend()


function Tower:new(position, worldMap, worldPos)
  self.worldMap = worldMap
  self.worldPos = worldPos
  self.dimensions = Vector(32, 32) -- Default texture is 32x32

  self.image = love.graphics.newImage("images/placeholderTower.png")

  self.pos = position -- Vector containing x and y coordinates
  self.posPixel = Tower.posToPixel(self.pos, self.dimensions, self.worldPos)

  self.bullets = {}
end


function Tower:update(dt)

  -- This is where the bullets get updated each tick
  for _, bullet in ipairs(self.bullets) do

  end

end


function Tower:draw()
  love.graphics.draw(self.image, self.posPixel.x, self.posPixel.y, 0, SCALE, SCALE)
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

end
