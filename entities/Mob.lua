Mob = Class:extend()
require 'entities.Mobhelper'


function Mob:new(spawn, goal, map, worldPos)
  self.dimensions = Vector( 32, 32 ) -- Default texture is 32x32
  -- self.walkable = {6, 11} -- All mobs can walk on wood
  -- self.worldMap = worldMap
  self.worldPos = worldPos -- The position which the world starts rendering
  self.map = map
  self.spawn = spawn
  self.goal = goal
  self.walkable = {6}
  self.hasReachedEnd = false
  self.health = 100

  self.movSpeed = 20 -- Default movementSpeed of 50

  self:createwalkableMap() -- Create the tfmap
  self.path = Luafinding.FindPath(self.spawn, self.goal, self.tfMap)

  if self.path then
    self.currPos = table.remove(self.path, 1) -- Get current position
    self.nextPos = table.remove(self.path, 1) -- Get next position
    self.moving = true
  else
    self.currPos = self.spawn
    self.nextPos = self.spawn
    self.moving = false
  end

  self.spawnPixelPos = -- Position on pixel coordinates
    Mob.posToPixel(self.currPos, self.dimensions, self.worldPos)
  self.startPixelPos = self.spawnPixelPos
  self.currPixelPos = self.spawnPixelPos -- First pos is same as spawn
  self.nextPixelPos =
    Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)

  self.distNextPos = Vector.dist(self.currPixelPos, self.nextPixelPos)

  self.direction = (self.nextPixelPos - self.currPixelPos) / self.distNextPos

  self.imageDirection = "north"
  self.images = {
    love.graphics.newImage("images/Mob/north.png"),
    love.graphics.newImage("images/Mob/east.png")
  }
  self:updateImageDirection()
end


-- Updates the position of the mob
function Mob:update(dt)
  -- If the entity should be moving
  if self.moving and self.path ~= nil then
    -- Take care of the movement
    self.currPixelPos = self.currPixelPos + self.direction *  self.movSpeed * dt
    -- Check if we have reached our next position
    if Vector.dist(self.startPixelPos, self.currPixelPos) > self.distNextPos then
      if #self.path > 0 then -- If there are still new tiles to visit
        -- If there are still moves to be made then calculate new path
        self:calculateNewPath()
      else
        -- Stop moving once we get to final tile
        self.moving = false
      end
    end
  end
end


-- Draw the mob, default is just a placeholder image and function should
-- be replaced in each mob
function Mob:draw()
  if self.imageDirection == "north" then
    love.graphics.draw(
      self.images[1], self.currPixelPos.x, 
      self.currPixelPos.y - (self.dimensions.y / 2) * SCALE, 0, SCALE, SCALE
    )
  elseif self.imageDirection == "east" then
    love.graphics.draw(
      self.images[2], self.currPixelPos.x, 
      self.currPixelPos.y - (self.dimensions.y / 2) * SCALE, 0, SCALE, SCALE
    )
  elseif self.imageDirection == "west" then
    love.graphics.draw(
      self.images[1], self.currPixelPos.x + self.dimensions.x * SCALE,
      self.currPixelPos.y - (self.dimensions.y / 4) * SCALE, 0, -SCALE, SCALE
    )
  elseif self.imageDirection == "south" then
    love.graphics.draw(
      self.images[2], self.currPixelPos.x + self.dimensions.x * SCALE,
      self.currPixelPos.y - (self.dimensions.y / 4) * SCALE, 0, -SCALE, SCALE
    )
  end

  -- Draw the health bar
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.rectangle('fill',
    self.currPixelPos.x, self.currPixelPos.y - self.dimensions.y * SCALE / 2,
    self.dimensions.x * SCALE, 2 * SCALE)
  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.rectangle('fill',
    self.currPixelPos.x, self.currPixelPos.y - self.dimensions.y * SCALE / 2,
    self.dimensions.x * SCALE * self.health * 0.01, 2 * SCALE)
  love.graphics.setColor(1, 1, 1, 1)

  if debug then
  -- Draw the path which the enemies will follow
    if self.path ~= nil and self.moving then
      for _, vec in ipairs(self.path) do
        local pos = Mob.posToPixel(vec, self.dimensions, self.worldPos)
        love.graphics.circle('fill', pos.x + self.dimensions.x / 2 * SCALE,
          pos.y + self.dimensions.y / 2 * SCALE, 3
        )
      end
    end
  end
end