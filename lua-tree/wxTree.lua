local  wxGUI = require"stab.scripts.init.wxGUI"
local  wxTree = class("wxTree")
local  DEFAULT_WIDTH = 400
local  DEFAULT_HEIGHT = 400
local  DEFAULT_TITLE = "TREE_TITLE"
local  DEFAULT_ROOT = "ROOT"
local socket = require"socket"
function wxTree.create(data)
    local tree = wxTree.new(data)
    if tree:initializeTree() then 
        return tree
    end
    return nil 
end

function wxTree:ctor(data)
    self.virtualMap = {}
    self.virSortMap = {}
    self.frame = data.frame
    self.cameras = data.cameras
    self.width = data.width or DEFAULT_WIDTH
    self.height = data.height or DEFAULT_HEIGHT
    self.title  = data.title or DEFAULT_TITLE
    self.callBack = data.callBack
    self.chooseInfo = data.chooseInfo
end

function wxTree:initializeTree()    
    self:CreateTree()    
    self:createRoot()  
    if self.tree and self.root then         
        return true
    end
    return false
end

function wxTree:CreateTree(callback)    
    self.tree = wxGUI:wxCreateTree(self.frame,self.width,self.height)   
    --选中
    self.tree:Connect(
        wx.wxEVT_COMMAND_TREE_SEL_CHANGED,
        function(e)
            local itemData = self.tree:GetItemData(e:GetItem())
            if itemData then
                local data  = itemData:GetData()
                self.chooseNode = data.itemData.node               
                self.callBack(data)
            else
                self.callBack(nil)
            end         
        end
    )
    --收起
    self.tree:Connect(
        wx.wxEVT_COMMAND_TREE_ITEM_COLLAPSED,
        function(e)          
            local itemData = self.tree:GetItemData(e:GetItem())
            if itemData then
                local data  = itemData:GetData()          
                self.openMap[data.itemData.node] = nil
            end         
        end
    )
    --展开
    self.tree:Connect(
        wx.wxEVT_COMMAND_TREE_ITEM_EXPANDED,
        function(e)
            local itemData = self.tree:GetItemData(e:GetItem())
            if itemData then
                local data  = itemData:GetData()
                self.openMap[data.itemData.node] = true
            end
        end
    )
end

function wxTree:createRoot()
    if self.tree then 
        self.root = wxGUI:AddRoot(self.tree,DEFAULT_ROOT)
        self:initMapData()
    end    
end

function wxTree:initMapData()
    self.openMap = {}
    self.realMap = {}
    self.nodeMap= {}
    self.drawMap = {}
    self.drawMap.children = {}
end

function wxTree:setFrameSize(width , height) 
    width = width or self.width 
    height = height or self.height
    self.frame:SetSize(wx.wxSize(width, height))
end

function wxTree:wxRefreshTree(scenes)
    self.virtualMap = {}
   
    for i, scene in ipairs(scenes) do 
        scene.childIndex = i 
        self.virtualMap[scene] = {        
            node = scene ,
            name = GetNodeName(scene),
            children = {}
        }
    end
    self:wxCalculateVirMap()    
    self:wxCalculateSortMap()
    self:wxRefreshTrunk()
end

function wxTree:wxCalculateOpenState()
    local chooseNode = self.chooseInfo.chooseNode
    self.openstate = {}    
    if CheckNodeVaild(chooseNode) then      
        local parent =  chooseNode:getParent()  
        while parent do
            self.openstate[parent] = true
            self.openMap[parent] = true
            parent = parent:getParent()
        end
    end 
end

function wxTree:wxCalculateSortMap()
    self.virSortMap = {}    
    local sortTree = nil     
    sortTree = function(virMap,sortMap)        
        if virMap then 
            for node , _data in pairs(virMap)do
                local data = {
                    node = node, 
                    name = _data.name,
                    children = {}
                }
                table.insert(sortMap,data)
                sortTree(_data.children,data.children)
            end
            table.sort(sortMap,function(dataA, dataB)
                return dataA.node.childIndex < dataB.node.childIndex
            end)
        end
    end
    sortTree(self.virtualMap,self.virSortMap)
end

function wxTree:wxCalculateVirMap()  
    local deepTree = nil
    deepTree = function(virMap,node)
        local map = virMap[node]
        local children =  node:getChildren()     
        local show = self.openMap[node]
        if show then 
            for i , child in ipairs(children) do 
                child.childIndex = i
                map.children[child] = {
                    node = child,
                    name = GetNodeName(child),
                    children = {}
                }               
                deepTree(map.children,child,false)
            end
        else
            for i , child in pairs(children) do 
                child.childIndex = i
                map.children[child] = {
                    node = child,
                    name = GetNodeName(child),
                    children = {}
                }               
                break
            end            
        end                           
    end
    for i , data in pairs(self.virtualMap) do 
        deepTree(self.virtualMap,data.node,true)
    end
end

function wxTree:wxRefreshTrunk()
    local drawTree = nil 
    self.nodeMap = {}
    drawTree = function(root,sortMap,drawMap)         
        if sortMap then 
            for index , data in ipairs(sortMap) do
                local itemId = self:wxUpdateItem(root , data , drawMap)                
                if data.children then 
                    drawTree(itemId,data.children,drawMap.children[data.node.childIndex])
                end
            end
            local sortNums = #sortMap
            local drawNums = #drawMap.children
            if sortNums<drawNums then
                for i = sortNums + 1,drawNums do                     
                    local data  = drawMap.children[i]
                    self.tree:Delete(data.itemData.itemID)
                    drawMap.children[i] = nil 
                end
            end   
        end
    end
    drawTree(self.root,self.virSortMap,self.drawMap)
    self:updateState()   
end


function wxTree:wxUpdateItem(root , data ,drawMap)   
    local drawData = drawMap.children[data.node.childIndex]    
    local itemData = nil
    if drawData then
        itemData = drawData.itemData
        if  data.node  == itemData.node then
            if data.name ~= itemData.name then
                self.tree:SetItemText(itemData.itemID , UTF8TowxString(data.name))        
            end
        else
            local treeData = {}
            local treeItemData = wx.wxLuaTreeItemData()
            treeItemData:SetData(treeData)
            treeData.itemData = itemData
            drawData.itemData =treeData.itemData
            self.tree:SetItemData(itemData.itemID,treeItemData)
            self.openMap[itemData.node] = nil 
            self.tree:Collapse(itemData.itemID)
            
            --self.openMap[data.node] = true
            -- self.tree:Delete(itemData.itemID)
            -- local treeData = {}
            -- local treeItemData = wx.wxLuaTreeItemData()
            -- treeItemData:SetData(treeData)
            -- treeData.itemData = itemData          
            -- itemData.itemID = self.tree:InsertItem(root,data.node.childIndex,UTF8TowxString(data.name),-1,-1,treeItemData)
            -- drawData.children = {}
            -- drawData.itemData =treeData.itemData
        end
    else
        local treeData = {}
        local treeItemData = wx.wxLuaTreeItemData()
        treeItemData:SetData(treeData)   
        itemData =  {           
            itemID = self.tree:AppendItem(root,data.name,-1,-1,treeItemData),
        }
        treeData.itemData = itemData
        drawData = 
        {
            itemData = itemData ,
            children = {}
        }        
        drawMap.children[data.node.childIndex]  = drawData
    end
    itemData.node = data.node
    itemData.name = data.name
    self.nodeMap[data.node] = itemData    
    return itemData.itemID
end

function wxTree:updateState()
    local itemData
    if self.openstate and next(self.openstate)then      
        for node ,  value in pairs(self.openstate) do 
            itemData = self.nodeMap[node]
            if itemData then          
                self.tree:Expand(itemData.itemID,true)
            end
        end
    end

    --if self.chooseNode ~= self.chooseInfo.chooseNode then 
        itemData = self.nodeMap[self.chooseInfo.chooseNode]
        if itemData then 
            self.tree:SelectItem(itemData.itemID,true)   
        end         
    --end       
    self.openstate = {}
end

return wxTree