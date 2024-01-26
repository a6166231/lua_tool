local wxGUI  = require"stab.scripts.init.wxGUI"
local wxFrame = class("wxFrame")

local  DEFAULT_WIDTH = 400
local  DEFAULT_HEIGHT = 400
local  DEFAULT_FRAME = "FRAME_TITLE"

function wxFrame.create(data)
    local wxFrame = wxFrame.new(data)
    if wxFrame:initializeFrame(data) then 
        return wxFrame
    end
    return nil
end


function wxFrame:ctor(data)
    self.frame = nil 
    self.width = data.width or DEFAULT_WIDTH
    self.height = data.height or DEFAULT_HEIGHT
    self.title = data.title or DEFAULT_FRAME
end

function wxFrame:initializeFrame()
    self.frame =  wxGUI:wxCreateFrame(self.title,self.width,self.height)
    return true
end

function wxFrame:getFrame()
    return self.frame
end

function wxFrame:Open()    
    self.state = not self.state 
    self.frame:Show(self.state)    
end 

function wxFrame:getState()
    return self.state
end

function wxFrame:setFrameSize(width , height) 
    self.width = width or self.width 
    self.height = height or self.height
    self.frame:SetSize(wx.wxSize(self.width, self.height))
end

return wxFrame