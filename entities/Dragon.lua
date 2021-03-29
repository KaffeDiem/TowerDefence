Dragon = Class:extend()


function Dragon:new(source, target)

  self.tileWidth = 32
  self.tileHeight = 32

  self.map = {
    {true, false, true},
    {true, false, true},
    {true, true,  true},
  }

  self.image = love.graphics.newImage('images/placeholder.png')
  self.start = source
  self.goal = target

  self.path = Luafinding.FindPath(self.start, self.goal, self.map)
  self.currPos = table.remove(self.path, 1)
  self.nextPos = table.remove(self.path, 1)

  self.currPixelPosX = 0
  self.currPixelPosY = 0

  -- For debugging
  self:printPath()
end


function Dragon:update(mapX, mapY, dt)

  -- Get pixel position to draw the dragon
  self.currPixelPosX =
    mapX + -- Starting point
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)) -- The width on cols
  self.currPixelPosY =
    mapY +
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) -- The width on cols

  
end


function Dragon:draw()
  love.graphics.draw(
    self.image, self.currPixelPosX, self.currPixelPosY, 0, SCALE, SCALE
  )
end






function Dragon:printPath()
  io.write("__Remaing path__\n")
  print("Current and next position:")
  print(self.currPos, self.nextPos)
  print("Remaning:")
  for _, vec in ipairs(self.path) do
    print(vec)
  end
  print("________________")
end