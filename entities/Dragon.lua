Dragon = Class:extend()


function Dragon:new()
  self.image = love.graphics.newImage('images/placeholder.png')
end


function Dragon:update()

end


function Dragon:draw()
  love.graphics.draw(self.image, 200, 200)
end