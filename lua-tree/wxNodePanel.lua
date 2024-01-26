local wxGUI = require "stab.scripts.init.wxGUI"
local wxNodePanel = class("wxNodePanel")

local DEFAULT_TEXT_WIDTH = 150
local DEFAULT_FUNCTION_WIDTH = 110
local DEFAULT_FUNCTION_HEIGHT = 30
local DEFAULT_CAMERA_FLAG = 1

local TITLE = 
{
    {
        type = wxGUI.ComponentType.CHECKBOX,
        text = UTF8TowxString("打开选择功能"),
        getValue = function(self)
            if self.touchPanel and not tolua.isnull(self.touchPanel) then 
                self.touchPanel:setSwallowTouches(self.touthEnable)
            end
            return self.touthEnable
        end,
        callBack = function(self,value)
            self.touthEnable =  value
            self.preTouchNode = nil 
            self.touchNode = nil 
        end,
        transDataFromWx = function(b)
            return b and true or false
        end,
        transDataFromCocos = function(b)
            return b and true or false
        end,
        force = true ,
        space = {x = 20, y = 0}
    },
    {
        type = wxGUI.ComponentType.CHECKBOX,
        text = UTF8TowxString("场景摄像机"),
        getValue = function(self)  
            local count = 0           
            for i , v in pairs(self.cameras)do
                count = count + 1
                if count > 1 then 
                    return true
                end
            end    
            return false        
        end,
        callBack = function(self,value)
            if value then 
                self:openCamera()
            else
                self:clearCamera()
            end
        end,
        transDataFromWx = function(b)
            return b and true or false
        end,
        transDataFromCocos = function(b)
            return b and true or false
        end,
        force = true ,
        space = {x = 100, y = 0}
    },
    {
        type = wxGUI.ComponentType.EDITBOX,
        text = UTF8TowxString("游戏速度"),
        title = UTF8TowxString("游戏速度"),
        getValue = function(self)     
            local director = cc.Director:getInstance()       
            return director:getScheduler():getTimeScale()
        end,
        callBack = function(self,value)
            local director = cc.Director:getInstance() 
            value = value or 1 --容错
            value = (value < 0 ) and 0 or value--防止小于0     
            director:getScheduler():setTimeScale(value)          
        end,
        transDataFromWx = function(value)
            return  wxTonumber(value) 
        end,
        transDataFromCocos = function(scale)
            local roundedNum = string.format("%.3f", scale)
            return tostring(tonumber(roundedNum))
        end,
        nospace = true,
        force = true ,
        space = {x = 100, y = 0}
    },

}
local layoutTable = {
    children = {
        {
            type = wxGUI.ComponentType.CHECKBOX,
            get = "isVisible",
            set = "setVisible",
            text = "Node",
            transDataFromWx = function(b)
                return b and true or false
            end,
            transDataFromCocos = function(b)
                return b and true or false
            end,           
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getName",
            set = "setName",
            transDataFromWx = function(str)
                return str
            end,
            transDataFromCocos = function(str)
                return str
            end,
            space = {x = 70, y = 0}
        },
        {
            type = wxGUI.ComponentType.BUTTON,
            callBack = function(self)
                self:drawRect(self.chooseInfo.chooseNode,3)
            end,
            text = "draw",
            force = true,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
        },
        {
            type = wxGUI.ComponentType.BUTTON,
            callBack = function(self)
                self:outPut()
            end,
            text = "output",
            force = true,
            space = {x = 120, y = 0}
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getString",
            set = "setString",
            title = "string",
            transDataFromWx = function(str)
                return str
            end,
            transDataFromCocos = function(str)
                return str
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getTitleText",
            set = "setTitleText",
            title = "string",
            transDataFromWx = function(str)
                return str
            end,
            transDataFromCocos = function(str)
                return str
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.COLORPICK,
            get = "getTitleColor",
            set = "setTitleColor",
            width = 50,
            height = 25,        
            transDataFromWx = function(newColor)
                local r, g, b, a = newColor:Red(), newColor:Green(), newColor:Blue(), newColor:Alpha()
                return cc.c3b(r, g, b)
            end,
            transDataFromCocos = function(color)
                return wxGUI:getWXColor(color.r, color.g, color.b, 255)
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getPositionX",
            set = "setPositionX",
            title = "X",
            transDataFromWx = function(x)
                return wxTonumber(x)
            end,
            transDataFromCocos = function(x)
                return tostring(math.ceil(x))
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getPositionY",
            set = "setPositionY",
            title = "Y",
            transDataFromWx = function(y)
                return wxTonumber(y)
            end,
            transDataFromCocos = function(y)
                return tostring(math.ceil(y))
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
            --changeLine = true
        },        
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getContentSize",
            set = "setContentSize",
            title = "width",
            transDataFromWx = function(width, node)
                width = wxTonumber(width)
                if width then
                    local size = node:getContentSize()
                    size.width = width
                    return size
                end
                return nil
            end,
            transDataFromCocos = function(size)
                local roundedNum = string.format("%.3f", size.width)
                return tostring(tonumber(roundedNum))
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getContentSize",
            set = "setContentSize",
            title = "height",
            transDataFromWx = function(height, node)
                height = wxTonumber(height)
                if height then
                    local size = node:getContentSize()
                    size.height = height
                    return size
                end
                return nil
            end,
            transDataFromCocos = function(size)
                local roundedNum = string.format("%.3f", size.height)
                return tostring(tonumber(roundedNum))
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}       
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getAnchorPoint",
            set = "setAnchorPoint",
            title = "AnchorPoint_X",
            transDataFromWx = function(x, node)
                x = wxTonumber(x)
                if x then
                    local pt = node:getAnchorPoint()
                    pt.x = x
                    return pt
                end
                return nil
            end,
            transDataFromCocos = function(anchorPoint)
                local roundedNum = string.format("%.3f", anchorPoint.x)
                return tostring(tonumber(roundedNum))
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getAnchorPoint",
            set = "setAnchorPoint",
            title = "AnchorPoint_Y",
            transDataFromWx = function(y, node)
                y = wxTonumber(y)
                if y then
                    local pt = node:getAnchorPoint()
                    pt.y = y
                    return pt
                end
                return nil
            end,
            transDataFromCocos = function(anchorPoint)
                local roundedNum = string.format("%.3f", anchorPoint.y)
                return tostring(tonumber(roundedNum))
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
        },      
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getScaleX",
            set = "setScaleX",
            title = "Scale_X",
            transDataFromWx = function(x)
                return wxTonumber(x)
            end,
            transDataFromCocos = function(x)
                local roundedNum = string.format("%.3f", x)
                return tostring(tonumber(roundedNum))
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getScaleY",
            set = "setScaleY",
            title = "Scale_Y",
            transDataFromWx = function(y)
                return wxTonumber(y)
            end,
            transDataFromCocos = function(y)
                local roundedNum = string.format("%.3f", y)
                return tostring(tonumber(roundedNum))
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getRotation",
            set = "setRotation",
            title = "Rotation",
            transDataFromWx = function(y)
                return wxTonumber(y)
            end,
            transDataFromCocos = function(y)
                local roundedNum = string.format("%.3f", y)
                return tostring(tonumber(roundedNum))
            end,
            changeLine = true
        },
        {
            type = wxGUI.ComponentType.COLORPICK,
            get = "getColor",
            set = "setColor",
            title = "Color",
            width = 50,
            height = 25,
            transDataFromWx = function(newColor)
                local r, g, b, a = newColor:Red(), newColor:Green(), newColor:Blue(), newColor:Alpha()
                return cc.c3b(r, g, b)
            end,
            transDataFromCocos = function(color)
                return wxGUI:getWXColor(color.r, color.g, color.b, 255)
            end,   
            changeLine = true,         
        },
        {
            type = wxGUI.ComponentType.EDITBOX,
            get = "getOpacity",
            set = "setOpacity",
            title = UTF8TowxString("透明度(0~255)"),
            width = 50,
            height = 25,
            transDataFromWx = function(opa)
                opa = wxTonumber(opa)
                if opa then
                    if opa<0 then opa = 0 end
                    if opa>255 then opa = 255 end
                end
                return opa
            end,
            transDataFromCocos = function(opa)
                local roundedNum = string.format("%.3f", opa)
                return tostring(tonumber(roundedNum))
            end,
            space = {x = DEFAULT_FUNCTION_WIDTH, y = 0}
        }
    }
}

function wxNodePanel.create(data)
    local panel = wxNodePanel.new(data)
    if panel:init(data) then
        return panel
    end
    return nil
end

function wxNodePanel:init(data)
    self.sx = 0 
    self.sy = 0
    self.callBack = data.callBack
    self.chooseInfo = data.chooseInfo
    self.cameras = data.cameras
    self.mapFunctions = {}
    self.mapLastValue = {}
    self.frame = data.frame   
    self.touthEnable = false
    self.nodePanel = wxGUI:wxScrolledWindow(self.frame, data.width, data.height)
    self.title = wxGUI:wxScrolledWindow(self.nodePanel,data.width, data.height)
    self.panel = wxGUI:wxScrolledWindow(self.nodePanel,data.width, data.height)
    self.layout = wxGUI:createGridLayout(2,1,10,0)
    for i, title in pairs(TITLE) do 
        self:createCommponent(title,self.title)  
    end
    self.nodePanel:SetSizer(self.layout)   
    self.layout:Add(self.title)
    self.layout:Add(self.panel,0, wxOr(wx.wxEXPAND, wx.wxALL))
    self.layout:AddGrowableRow(1, 1)
    self.layout:AddGrowableCol(0, 0)    
    return true
end

function wxNodePanel:checkTouchPanel()
    if not self.touchPanel or tolua.isnull(self.touchPanel) then
        self:createTouchPanel()
        self:initTouchEvent()
        self:initMouseEvent()
    end
    self.touchPanel:setLocalZOrder(999999)
end

function wxNodePanel:createTouchPanel()
    if not self.touchPanel or tolua.isnull(self.touchPanel) then
        local scene = cc.Director:getInstance():getRunningScene()
        self.touchPanel = ccui.Layout:create()
        self.touchPanel.ignore = true
        local layout = ccui.LayoutComponent:bindLayoutComponent(self.touchPanel)
        layout:setSize({width = 1136.0000, height = 640.0000})
        scene:addChild(self.touchPanel)
    end
end

function wxNodePanel:initTouchEvent()
    local function ontouch(sender, event)
        if self.touthEnable then
            if event == ccui.TouchEventType.began then
                if CheckNodeVaild(self.touchNode) then 
                    self.touthEnable = false
                    self.callBack(self.touchNode)           
                    return true
                end
            end
        end        
    end
    self.touchPanel:setTouchEnabled(true)
    self.touchPanel:setSwallowTouches(self.touthEnable)
    self.touchPanel:addTouchEventListener(ontouch)
end

function wxNodePanel:initMouseEvent()
    local listener = cc.EventListenerMouse:create()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    local function onMouseMoved(sender)
        local mousePosX = sender:getCursorX()
        local mousePosY = sender:getCursorY()
        self:touchMove(
            {
                x = mousePosX,
                y = mousePosY
            }
        )
    end
    listener:registerScriptHandler(onMouseMoved, cc.Handler.EVENT_MOUSE_MOVE)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.touchPanel)
end

function wxNodePanel:touchMove(pos)
    self.touchPos =  pos
    if not self.moveInterval and self.touthEnable then
        self.moveInterval = true        
        wxDelayCall(self.touchPanel,
            function()
                self:calculateChooseNode()
                self.moveInterval = false
            end,
            0.1
        )
    end
end

function wxNodePanel:calculateChooseNode()
    self.preTouchNode = self:calculateTouchNode()
end

function wxNodePanel:CheckCameraEnable(node)
    local mask = node:getCameraMask()   
    if mask~= DEFAULT_CAMERA_FLAG then      
        local camera = self.cameras[mask]
        if camera then
            return true
        end
    else
        return true 
    end 
    return false
end

function wxNodePanel:CheckIsTouch(node)
    if self:CheckCameraEnable(node) then 
        if  wxCheckDrawEnable(node) then 
            if  HitTest(node, self.touchPosInDifferentCamera[node:getCameraMask()]) then 
                return true
            end
        end
    end
    return false
end

function wxNodePanel:CalculateTouchPosInCameras()
    self.touchPosInDifferentCamera = {}
    self.touchPosInDifferentCamera[DEFAULT_CAMERA_FLAG] = self.touchPos
    if self.cameras and next(self.cameras) then 
        for mask , camera in pairs(self.cameras) do
            if mask ~= DEFAULT_CAMERA_FLAG then         
                self.touchPosInDifferentCamera[mask] =  wxTouchPanel2World(self.touchPos, camera)
            end
        end
    end
end

function wxNodePanel:calculateTouchNode()
    self:CalculateTouchPosInCameras()
    local scene = cc.Director:getInstance():getRunningScene()
    local searchNode    
    searchNode = function(parent)
        local touchNode = nil 
        local children = parent:getChildren()
        if children and next(children) then
            local childrenCount  = #children
            for i = 0 , childrenCount-1 do
                local child = children[childrenCount - i]
                local name = GetNodeName(child)
                if child:isVisible() and not child.ignore then     
                    if  self:CheckIsTouch(child) then                                        
                        touchNode = child                       
                    end
                    local touchNode2 = searchNode(child)
                    if touchNode2 then
                        touchNode = touchNode2
                    end
                    if touchNode then
                        return touchNode
                    end
                end
            end
        end
    end
    return searchNode(scene)   
end

function wxNodePanel:wxCalculateToworldPos(node,pos)
    local mask = node:getCameraMask()   
    if mask~= DEFAULT_CAMERA_FLAG then      
        local camera = self.cameras[mask]
        if camera then         
            return wxTouchPanel2World(pos, camera)
        end
    end
    return pos    
end

function wxNodePanel:wxCalculateTopanelPos(node,pos)
    local mask = node:getCameraMask()   
    if mask~= DEFAULT_CAMERA_FLAG then 
        local camera = self.cameras[mask]   
        if camera then         
            return wxWorld2TouchPanel(pos, camera)
        end    
    end
    return pos    
end

function wxNodePanel:AddCamera(camera)
    self.cameras = self.cameras or {} 
    if camera and not tolua.isnull(camera) then
        self.cameras[camera:getCameraFlag()] = camera
    end
end


function wxNodePanel:ctor(data)   
end

function wxNodePanel:refreshNode()    
    self:checkTouchPanel()
    self:checkDeleteItem()
    self:updateChooseNode()
    self:refreshDrawRect()
end

function wxNodePanel:updateChooseNode()  
    if self.chooseNode ~= self.chooseInfo.chooseNode then        
        self:deleteAllItem()
        self.chooseNode = self.chooseInfo.chooseNode
    end 
    if self.chooseNode and not tolua.isnull(self.chooseNode) then
        self:refreshAllItems()
    end
    self:refreshAllCommponent()
end

function wxNodePanel:checkDeleteItem()
    if tolua.isnull(self.chooseInfo.chooseNode) then    
        self.chooseNode = nil     
        self:deleteAllItem()       
    end
end

function wxNodePanel:refreshAllItems()
    self:refreshTitle()
    self:refreshAllFunction()
end

function wxNodePanel:refreshDrawRect()
    if self.preTouchNode and self.touthEnable then 
        if self.preTouchNode ~= self.touchNode then 
            self.touchNode = self.preTouchNode
            if self.touchNodeRect then 
                self.touchNodeRect:removeFromParent()
                self.touchNodeRect = nil
            end
            if self.touchNode then 
                self.touchNodeRect = self:drawRect(self.touchNode)
            end
        end
    else
        if self.touchNodeRect then 
            self.touchNodeRect:removeFromParent()
            self.touchNodeRect = nil
        end
    end
end

function wxNodePanel:refreshTitle()
    local nodeName = GetNodeName(self.chooseNode)
    if self.frameName ~= nodeName then
        self.frameName = nodeName
        self.frame:SetTitle(self.frameName)
    end
end

function wxNodePanel:refreshAllFunction()
    self.sx = 0
    self.sy = 0
    local deepTree = nil
    deepTree = function(children)
        for name, child in pairs(children) do
            self:createCommponent(child,self.panel)
            if child.children then
                deepTree(child.children)
            end
        end
    end 
    if not self.mapFunctions[self.panel] or not next(self.mapFunctions[self.panel]) then
        deepTree(layoutTable.children)
    end
end

function wxNodePanel:refreshAllCommponent()
    for panel, datas in pairs(self.mapFunctions) do
        if datas and next(datas) then 
            for comp , data in pairs(datas) do
                self:refreshCommponent(comp, data ,panel)
            end
        end
    end
end

function wxNodePanel:refreshCommponent(component, data, panel)    
    
    if not self.mapLastValue[panel] then 
        self.mapLastValue[panel] = {}
        return 
    end 
    if self.mapLastValue[panel][data] == nil then
        return
    end
    local getValue  = function()
        if data.get and self.chooseNode and not tolua.isnull(self.chooseNode) then
            return self.chooseNode[data.get] and self.chooseNode[data.get](self.chooseNode) or nil
        end   
        if data.getValue then
            return data.getValue(self,self.chooseNode)
        end         
        return nil
    end

    local value = getValue()
    if data.transDataFromCocos then 
        value = data.transDataFromCocos(value, self.chooseNode)
    end   
    if self.mapLastValue[panel][data] == value then
        return
    end
    if data.type == wxGUI.ComponentType.BUTTON then
    elseif data.type == wxGUI.ComponentType.EDITBOX then
        component:ChangeValue(UTF8TowxString(value))
    elseif data.type == wxGUI.ComponentType.COLORPICK then
        component:SetBackgroundColour(value)
    elseif data.type == wxGUI.ComponentType.CHECKBOX then
        component:SetValue(value)
    end
    self.mapLastValue[panel][data] = value
end

function wxNodePanel:createCommponent(data,panel)    
    self.mapFunctions[panel] = self.mapFunctions[panel] or {}
    self.mapLastValue[panel] = self.mapLastValue[panel] or {}
    local chooseNode = self.chooseNode
    if data.force or chooseNode[data.set] then
        if data.changeLine then
            self.sx = 0
            self.sy = self.sy + ((self.height and self.height ~= 0) and (self.height + 5) or DEFAULT_FUNCTION_HEIGHT)
        end
        if data.space then
            self.sx = self.sx + data.space.x
        end

        if data.title and data.title ~= "" then
            local text = wxGUI:wxCreateLabel(panel, data.title)
            text:Move(wx.wxPoint(self.sx, self.sy))
            if not data.nospace then 
                self.sx = self.sx + DEFAULT_TEXT_WIDTH
            else
                self.sx = self.sx + DEFAULT_TEXT_WIDTH - 100
            end
        end
        local component = nil
        local callback =
            handler(
                self,
                function(this, value)
                    if data.set then
                        local chooseNode = this.chooseNode
                        if chooseNode and not tolua.isnull(chooseNode) then
                            if data.transDataFromWx then
                                value = data.transDataFromWx(value, chooseNode)
                            end                            
                            if self.mapLastValue[panel][data] == value then
                                return
                            end
                            if value or value == false then
                                chooseNode[data.set](chooseNode, value)
                            end                           
                        end
                        self.mapLastValue[panel][data] = value
                    else 
                        if data.callBack then 
                            if data.transDataFromWx then
                                value = data.transDataFromWx(value)
                            end
                            data.callBack(this,value)
                            self.mapLastValue[panel][data] = value
                        end
                    end  
                end
            )            
        local getValue  = function()
            if data.get and self.chooseNode and not tolua.isnull(self.chooseNode) then
                return self.chooseNode[data.get] and self.chooseNode[data.get](self.chooseNode) or nil
            end   
            if data.getValue then
                return data.getValue(self,self.chooseNode)
            end         
            return nil
        end

        local value = getValue()
        if data.transDataFromCocos then
            value = data.transDataFromCocos(value, self.chooseNode)
        end
        if data.type == wxGUI.ComponentType.BUTTON then
            component = wxGUI:wxCreateButton(panel, data.text, data.width, data.height, callback)
        elseif data.type == wxGUI.ComponentType.EDITBOX then
            component = wxGUI:wxCreateEditBox(panel, data.width, data.height, true, callback)
            component:ChangeValue(UTF8TowxString(value))
        elseif data.type == wxGUI.ComponentType.COLORPICK then
            component = wxGUI:wxCreateColorPick(panel, data.width, data.height, value, callback)
        elseif data.type == wxGUI.ComponentType.CHECKBOX then
            component = wxGUI:wxCreateCheckBox(panel, data.text, data.width, data.height, callback)
            component:SetValue(value and true or false)
        end
        if component then
            component:Move(wx.wxPoint(self.sx, self.sy))    
            self.mapFunctions[panel][component] = data
            self.mapLastValue[panel][data] = value
        end
    end
end

function wxNodePanel:deleteAllItem()
    self.panel:DestroyChildren()    
    self.mapFunctions[self.panel] = {}
    self.mapLastValue[self.panel] = {}
    if self.defaultSizer then
        self.defaultSizer:Clear()
    end
end

function wxNodePanel:outPut()
    print("output-->>",self.chooseInfo.chooseNode)
end

function wxNodePanel:openCamera()
    local scene = cc.Director:getInstance():getRunningScene()
    local carmers = wxFindAllChildrenWithType(scene,"cc.Camera")
    for i , camera in pairs(carmers) do 
        self:AddCamera(camera)
    end
end

function wxNodePanel:clearCamera()
    for k, _ in pairs(self.cameras) do
        self.cameras[k] = nil
    end
end



function wxNodePanel:drawSoloRect(drawNode,width,height,anchorPoint)
    drawNode:drawSolidRect(
        cc.p(-anchorPoint.x * width, -anchorPoint.y * height),
        cc.p(width * (1 - anchorPoint.x), height * (1 - anchorPoint.y)),
        cc.c4f(1, 0, 0, 0.5)
    )
    drawNode:drawPoint({x = 0, y = 0}, 5, cc.c4f(0, 0, 1, 0.5))
end

function wxNodePanel:drawSolidCircle(drawNode)
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))    
    drawNode:drawSolidCircle(cc.p(0, 0), 100, 0, 30, 1, 1, cc.c4f(0, 1, 0, 0.5))
    drawNode:drawPoint(cc.p(0, 0), 5, cc.c4f(0, 0, 1, 0.5))
end

function wxNodePanel:drawRect(rectNode,time)    
    local drawNode = cc.DrawNode:create()
    drawNode.ignore = true
    self.touchPanel:addChild(drawNode) 
    if CheckNodeVaild(rectNode) then   
        local camera = self.cameras[rectNode:getCameraMask()]
        local scaleX, scaleY = 1,1
        if camera then
            scaleX, scaleY = wxCalcCameraZoom( camera )
        end
        local position =  cc.p(rectNode:getPosition())     
        local worldpos =  rectNode:getParent():convertToWorldSpace(position)
        worldpos = self:wxCalculateTopanelPos(rectNode,worldpos)
        local contentSize = wxGetNodeWorldContentSize(rectNode)
        local anchorPoint = rectNode:getAnchorPoint()
        local width = contentSize.width /scaleX
        local height = contentSize.height /scaleY
        drawNode:setAnchorPoint(anchorPoint)   
        position = drawNode:getParent():convertToNodeSpace(worldpos)
        drawNode:setPosition(position)
        if width > 0 and height > 0 then
            self:drawSoloRect(drawNode,width,height,anchorPoint)
        else
            self:drawSolidCircle(drawNode)
        end
    else
        local size = self.touchPanel:getContentSize()
        drawNode:setPosition(cc.p(size.width / 2, size.height / 2))       
        self:drawSolidCircle(drawNode)
    end
    if time then 
        wxDelayCall(
            drawNode,
            function()
                drawNode:removeFromParent()
            end,
            time
        )
    end
    return drawNode
end



return wxNodePanel
