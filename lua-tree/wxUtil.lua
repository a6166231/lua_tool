local print = release_print

function GetNodeTypeName(node)
    if node and not tolua.isnull(node) then
        return tolua.type(node)
    end
    return "error_type"
end

function GetNodeName(node)
    local name = node:getName()
    if not name or name == "" or name == nil then
        name = GetNodeTypeName(node)
        if not name then
            name = "error_name"
        end
    end
    return name
end

function GetNodeHashName(node)
    if node and not tolua.isnull(node) then
        return tostring(node)
    end
    return nil
end

function GetNodePanentCount(node)
    if not node.parentCount then
        if node:getParent() then
            node.parentCount = GetNodePanentCount(node:getParent()) + 1
        else
            node.parentCount = 0
        end
    end
    return node.parentCount
end

function CheckNodeVaild(node)
    if not node then
        return false
    end
    if tolua.isnull(node) then
        return false
    end
    if not node.convertToWorldSpace then
        return false
    end
    if not node.getPosition then
        return false
    end
    if not node.getAnchorPoint then
        return false
    end
    if not node.getScaleX then
        return false
    end
    if not node.getContentSize then
        return false
    end
    if not node.getParent or not node:getParent() then
        return false
    end
    return true
end

function wxFindAllChildrenWithType(parent, type)
    local deepFind  = nil 
    local find = {}
    deepFind = function(children , type)
        for i = 1, #children do
            local child = children[i]
            if child and tolua.iskindof(child, type) then
                table.insert(find, child)
            end            
            deepFind(child:getChildren(), type)            
        end    
    end
    deepFind(parent:getChildren(),type)
    return find
end

function wxCheckDrawEnable(node) 
    if not CheckNodeVaild(node) then 
        return false
    end

    local contentSize = node : getContentSize()
    if contentSize.width > 0 and contentSize.height > 0 then
        if tolua.iskindof(node, "ccui.Layout") then 
            return false 
        end
        if tolua.iskindof(node, "cc.Sprite") then 
            return true 
        end
        if tolua.iskindof(node, "cc.Label") then 
            return true 
        end
        if tolua.iskindof(node, "ccui.Button") then 
            return true 
        end
        if tolua.iskindof(node, "ccui.ImageView") then 
            return true 
        end
        if tolua.iskindof(node, "ccui.Text") then 
            return true 
        end
    end 
    return false     
end

function wxOr(num1, num2)
    local tmp1 = num1
    local tmp2 = num2
    local str = ""
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 == s2 then
            if s1 == 0 then
                str = "0" .. str
            else
                str = "1" .. str
            end
        else
            str = "1" .. str
        end
        tmp1 = math.modf(tmp1 / 2)
        tmp2 = math.modf(tmp2 / 2)
    until (tmp1 == 0 and tmp2 == 0)
    return tonumber(str, 2)
end

function wxAnd(num1, num2)
    local tmp1 = num1
    local tmp2 = num2
    local str = ""
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 == s2 then
            if s1 == 1 then
                str = "1" .. str
            else
                str = "0" .. str
            end
        else
            str = "0" .. str
        end
        tmp1 = math.modf(tmp1 / 2)
        tmp2 = math.modf(tmp2 / 2)
    until (tmp1 == 0 and tmp2 == 0)
    return tonumber(str, 2)
end

function wxTonumber(num)
    local _ts = string.split(num, ".")
    if _ts and #_ts ~= 1 then
        if _ts and #_ts ~= 2 then
            return nil
        end
        if #_ts == 2 and _ts[2] == "" then
            return nil
        end
    end
    return tonumber(num)
end

function wxStringToUTF8(str)
     return wx.wxString(str):ToUTF8()
end

function UTF8TowxString(str)
    return wx.wxString.FromUTF8(str)
end
local nodePos
local anchorPoint
local anx , any

function HitTest(node, pos)
    local contentSize = node : getContentSize()
    if contentSize.width > 0 and contentSize.height > 0 then
        nodePos = node : convertToNodeSpace(pos)
        anchorPoint = node:getAnchorPoint()
        if nodePos.x>=0 and nodePos.x<=contentSize.width and nodePos.y>=0 and nodePos.y<=contentSize.height then
            return true
        end
        -- anx = nodePos.x / contentSize.width
        -- if -anchorPoint.x <= anx and anx<= (1- anchorPoint.x) then
        --     any = nodePos.y / contentSize.height
        --     if -anchorPoint.y <= any and any <= (1- anchorPoint.y) then
        --         return true
        --     end
        -- end
    end
    return false
end

function wxDelayCall(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end

function wxCalcCameraZoom( camera )
    local winSize = cc.Director:getInstance():getWinSize()
    local rtPos = cc.p( winSize.width, winSize.height ) -- right-top
    local lbPos = cc.p( 0, 0 )                          -- left-bottom
    local rtPosGL = camera:projectGL( rtPos )
    local lbPosGL = camera:projectGL( lbPos )

    local zoomWidth = rtPosGL.x - lbPosGL.x
    local zoomHeight = rtPosGL.y - lbPosGL.y

    local scaleX = winSize.width / zoomWidth
    local scaleY = winSize.height / zoomHeight

    return scaleX, scaleY
end

function wxTouchPanel2World( srcPos, camera )
    local scaleX, scaleY = wxCalcCameraZoom( camera )
    local p = cc.p( srcPos.x * scaleX, srcPos.y * scaleY )
    local cameraPos = cc.p(camera:getPosition())
    local winSize = cc.Director:getInstance(): getWinSize()
    local centerOfView = cc.p( winSize.width * 0.5 * scaleX, winSize.height * 0.5 * scaleY )
    return cc.pSub(cc.pAdd( cameraPos, p ), centerOfView )
end

function wxWorld2TouchPanel( srcPos,camera )
    local scaleX, scaleY = wxCalcCameraZoom( camera )
    local cameraPos = cc.p(camera:getPosition())
    local winSize = cc.Director:getInstance():getWinSize()
    local centerOfView = cc.p( winSize.width * 0.5*scaleX, winSize.height * 0.5 *scaleY )
    local p = cc.pAdd( cc.pSub( srcPos, cameraPos ), centerOfView )
    p.x = p.x / scaleX
    p.y = p.y / scaleY
    return p
end

function wxGetNodeWorldContentSize(rectNode)
    -- 获取节点自身的内容大小
    local contentSize = rectNode:getBoundingBox()
    local scaleX = 1
    local scaleY = 1
    local parent = rectNode:getParent()
    while parent do 
        scaleX = scaleX * parent:getScaleX()
        scaleY = scaleY * parent:getScaleY()       
        parent = parent:getParent()
    end 
    return {width = contentSize.width * scaleX, height = contentSize.height * scaleY}
end

cc = cc or {}
cc.p =
    cc.p or
    function(x, y)
        return {
            x = x,
            y = y
        }
    end
cc.c4f =
    cc.c4f or
    function(r, g, b, a)
        return {
            r = r,
            g = g,
            b = b,
            a = a
        }
    end
