local lovebird = require "lovebird"
Notification = Class:extend()
local lg = love.graphics


function Notification:new(time, message)
  self.timer = Timer(time)
  self.msg = message
  self.msgW = lg.getFont():getWidth(self.msg)

  self.isDone = false
end

function Notification:update(dt)
  self.timer:update(dt)

  if self.timer:hasFinished() then
    self.isDone = true
  end
end

function Notification:draw()
  love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
  lg.rectangle("fill",
    0.05*lg:getWidth(), 0.75*lg:getHeight(),
    lg:getWidth()*0.9, lg:getHeight()*0.2, 10, 10
  )

  love.graphics.setColor(1, 1, 1, 1)
  lg.print(self.msg, lg:getWidth()/2 - self.msgW/2, lg:getHeight()*0.8)
end