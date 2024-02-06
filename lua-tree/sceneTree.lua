
require"wx"
require("stab.scripts.init.wxUtil")
local wxGUI = require("stab.scripts.init.wxGUI")
local wxFrame = require("stab.scripts.init.wxFrame")
local wxTree = require("stab.scripts.init.wxTree")
local wxMenu = require("stab.scripts.init.wxMenu")
local wxNodePanel = require("stab.scripts.init.wxNodePanel")

local  DEFAULT_WIDTH = 550
local  DEFAULT_HEIGHT = 700
local sceneTree = class("sceneTree")
function sceneTree:ctor()
    if sceneTree.instance ~= nil then 
        return 
    end
    self:initializeFrame()
end


function sceneTree:initializeFrame()
    if (type(require('wx'))=='boolean') or not wx then
        print("重启客户端生效!")
        return
    end 
    self.chooseInfo = {        
        chooseNode = nil 
    }
    self.cameras ={

    }
    self.pause = false
    self.wxFrame = wxFrame.create({title = "wxFrame",width = DEFAULT_WIDTH ,height = DEFAULT_HEIGHT})
    self.frameLayout  = wxGUI:createGridLayout(2, 1, 0, 0)
    self.wxFrame:getFrame():SetSizer(self.frameLayout)
    self.wxTreeFrame = self.wxFrame
    self.wxNodeFrame = self.wxFrame
    self:createSceneTree()
    self:createNodePanle()
    self:createMenuBar()
    self.frameLayout:AddGrowableRow(0, 0)
    self.frameLayout:AddGrowableRow(1, 0)
    self.frameLayout:AddGrowableCol(0, 0)
    self.scheduleId =  Schedule(function()        
        self:Tick()
    end,1/20)

    --sys.taskInit(handler(self,self.TaskFunc),1/20 * 1000)
end

-- function sceneTree:TaskFunc(time) 
--     while (true) do
--         sys.wait(time)
--         self:Tick()
--     end
-- end


function sceneTree:createMenuBar()
    self.wxMenuBar = wxMenu.create({
        frame = self.wxFrame:getFrame(),
    })
end

function sceneTree:createSceneTree()
    self.wxTree = wxTree.create({
        frame = self.wxTreeFrame:getFrame(),
        width = 0 ,
        height = 0,
        cameras = self.cameras,
        chooseInfo = self.chooseInfo,
        callBack = function(data)
            if data  then                 
                self.chooseInfo.chooseNode = data.itemData.node    
            else
                self.chooseInfo.chooseNode = nil
            end              
        end})
    
    self.frameLayout:Add(self.wxTree.tree, 0, wxOr(wx.wxEXPAND, wx.wxALL))
    self.input =""
end

function sceneTree:createNodePanle()
    self.wxNodePanel = wxNodePanel.create({
        frame = self.wxNodeFrame:getFrame(),
        width = 0 ,
        height = 0,
        cameras = self.cameras,
        chooseInfo = self.chooseInfo,
        callBack = function(node)          
            self.chooseInfo.chooseNode = node
            self.wxTree:wxCalculateOpenState()
        end})     
    self.frameLayout:Add(self.wxNodePanel.nodePanel, 0, wxOr(wx.wxEXPAND, wx.wxALL))   
end

function sceneTree:getInstance()
    if sceneTree.instance == nil then 
        sceneTree.instance = sceneTree.new()
    end
    return sceneTree.instance
end

function sceneTree:destroy()
    sceneTree.instance = nil 
end

function sceneTree:Tick()
    if not self.pause then   
        if self.wxTreeFrame:getState() and self.wxTree then 
            local scenes = self:calculateTreeInfo()
            self.wxTree:wxRefreshTree(scenes) 
        end
        if self.wxNodeFrame:getState() then                      
            self.wxNodePanel:refreshNode()   
        end    
    end
end

function sceneTree:calculateTreeInfo()
    local scene = cc.Director:getInstance():getRunningScene()
    if not self.input or self.input ==  "" then 
        return {scene}
    end
    --计算同名child 
    local nodes = {}
    local deepSearch
    deepSearch = function(children, name)
        if children and next(children) then 
            for i, node in ipairs(children) do 
                if node.name == name then 
                    tbale.table.insert(nodes,node)
                end
                deepSearch(node:getchildren(),name)
            end
        end
    end
    deepSearch({scene},self.input)
    return nodes
end

function sceneTree:Open()
    self.wxFrame:Open()
end

sceneTree.instance = nil

return sceneTree