local wxGUI = class("wxGUI")

wxGUI.ComponentType = {
    BUTTON = 1,
    LABEL = 2,
    COLORPICK = 3,
    CHECKBOX = 4,
    EDITBOX = 5,
    BUTTONBOX = 6,
    TEXTBOX = 7,
    SPINBOX = 8,
    SLIDER = 9,
    LISTBOX = 10,
    LISTBOXMULTIPLE = 11,
    LISTBOXMULTIPLECOMBO = 12
}

--创建窗口
function wxGUI:wxCreateFrame(title, width, height)
    local frame = wx.wxFrame(
        wx.NULL,
        wx.wxID_ANY,
        title,
        wx.wxDefaultPosition,
        wx.wxSize(width, height),
        wx.wxDEFAULT_FRAME_STYLE
    )
    local dialog = wxGUI:wxCreateDialog(frame, 'test')
    wxGUI:setSize(dialog,0,0)
    dialog:Show(true)
    frame:Connect(wx.wxEVT_CLOSE_WINDOW, function(e)
        frame:Destroy()
        dialog:Destroy()
    end)
    return frame
end


--创建竖向带滚动窗口
function wxGUI:wxScrolledWindow(frame, width, height)
    return wx.wxPanel(frame, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize(width, height))
end
function wxGUI:wxCreatePanel(parent, width, height)
    return wx.wxPanel(parent, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize(width, height))
end

function wxGUI:wxCreateDialog(parent, title, width, height)
    width = width or 400
    height = height or 300
    return wx.wxDialog(parent, wx.wxID_ANY, title, wx.wxDefaultPosition, wx.wxSize(width, height))
end

--创建树结构
function wxGUI:wxCreateTree(frame, width, height)
    return wx.wxTreeCtrl(frame, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize(width, height))
end

--树节点创建根节点
function wxGUI:AddRoot(tree, rootName)
    return tree:AddRoot(rootName)
end

function wxGUI:wxCreateURL(url)
    return wx.wxURL(url)
end
-- 输入框
function wxGUI:wxCreateEditBox(parent, width, height, editable, changeCall)
    local editBox = wx.wxTextCtrl(parent, wx.wxID_ANY)
    editBox:SetEditable(editable)
    if changeCall then
        editBox:Connect(
            wx.wxEVT_COMMAND_TEXT_UPDATED,
            function(e)
                changeCall(wxStringToUTF8(editBox:GetValue()))
            end
        )
    end
    return editBox
end

--复选框
function wxGUI:wxCreateCheckBox(parent, lb, width, height, clickCall)
    lb = lb or ""
    width = width or 50
    height = height or 50
    local checkBox = wx.wxCheckBox(parent, wx.wxID_ANY, lb)

    if clickCall then
        checkBox:Connect(
            wx.wxEVT_COMMAND_CHECKBOX_CLICKED,
            function(e)
                release_print(checkBox:IsChecked())
                clickCall(checkBox:IsChecked())
            end
        )
    end
    return checkBox
end

function wxGUI:wxCreateLabel(parent, lb)
    local text = wx.wxStaticText(parent, wx.wxID_ANY, lb)
    return text
end

function wxGUI:wxCreateButton(parent, lb, width, height, clickCall)
    lb = lb or "button"
    width = width or 100
    height = height or 30

    local btn = wx.wxButton(parent, wx.wxID_ANY, lb, wx.wxDefaultPosition, wx.wxSize(width, height))
    if clickCall then
        btn:Connect(
            wx.wxEVT_COMMAND_BUTTON_CLICKED,
            function(e)
                clickCall(btn)
            end
        )
    end
    return btn
end

function wxGUI:wxCreateMenuBar()
    return wx.wxMenuBar()
end
function wxGUI:wxCreateMenu(str, id)
    local fileMenu = wx.wxMenu()
    id = id or wx.wxID_ANY
    str = str or ""
    fileMenu:Append(id, str)
    return fileMenu
end
function wxGUI:wxCreateHyperLink(parent, show, url)
    local item = wx.wxHyperlinkCtrl(parent, wx.wxID_ANY, show, url)
    return item
end

-- 颜色选择器方块
function wxGUI:wxCreateColorPick(parent, width, height, color, changeCall)
    width = width or 100
    height = height or 30
    color = color or wxGUI:getWXColor(255, 255, 255, 255)

    local pick
    pick =
        wxGUI:wxCreateButton(
        parent,
        "",
        width,
        height,
        function()
            wxGUI:wxPopColorPick(
                parent,
                color,
                function(bChange, newColor)
                    if bChange then
                        release_print(bChange, newColor:Red(), newColor:Green(), newColor:Blue(), newColor:Alpha())
                        pick:SetBackgroundColour(
                            wxGUI:getWXColor(newColor:Red(), newColor:Green(), newColor:Blue(), newColor:Alpha())
                        )
                        changeCall(newColor)
                    end
                end
            )
        end
    )
    pick:SetBackgroundColour(wxGUI:getWXColor(color:Red(), color:Green(), color:Blue(), color:Alpha()))
    return pick
end

---------- layout\widget demo
-- 1. 首先给目标节点添加一个sizer组件 并返回sizer
--  local sizer = wxGUI:addBoxLayout(node)

-- 2. 创建多个节点插入目标节点
--   self.edit = wxGUI:wxCreateButton(node,'1', 100,100)
--   self.edit1 = wxGUI:wxCreateButton(node,'2', 100,100)
--   self.edit2 = wxGUI:wxCreateButton(node,'3', 100,100)
--   self.edit3 = wxGUI:wxCreateButton(node,'4', 100,100)

-- 3. **** sizer一定要调用Add方法前面创建过的节点传进去 否则无法自动布局  第二个参数是widget的概念 传递的是布局类型
--   布局类型包括
--      wxALIGN_CENTER
--      wxALIGN_CENTRE
--      wxALIGN_LEFT
--      wxALIGN_RIGHT
--      wxALIGN_TOP
--      wxALIGN_BOTTOM
--      wxALIGN_CENTER_VERTICAL
--      wxALIGN_CENTRE_VERTICAL
--      wxALIGN_CENTER_HORIZONTAL
--      wxALIGN_CENTRE_HORIZONTAL
--      sizer:Add(self.edit, wx.wxALIGN_RIGHT)
--      sizer:Add(self.edit1)
--      sizer:Add(self.edit2)
--      sizer:Add(self.edit3, wx.wxALIGN_RIGHT)

-- 4. 最后给目标节点设置sizer
--  node:SetSizer(sizer, wxALIGN_CENTER)

--盒子布局 只有水平和垂直布局 默认横向布局
function wxGUI:addBoxLayout(parent, bHor)
    local boxsizer = wxGUI:createBoxSizer(bHor)
    parent:SetSizer(boxsizer)
    return boxsizer
end

--网格布局
function wxGUI:addGridLayout(parent, rows, cols, vgap, hgap)
    local gridLayout = wxGUI:createGridLayout(rows, cols, vgap, hgap)
    parent:SetSizer(gridLayout)
    return gridLayout
end

function wxGUI:createBoxSizer(bHor)
    return wx.wxBoxSizer(bHor and wx.wxHORIZONTAL or wx.wxVERTICAL)
end

-- 动态尺寸网格布局示例 即所有的子节点铺满所有空间
--  1. 创建一个gridLayout 即2行1列的网格布局
--   local sizer = wxGUI:createGridLayout(2, 1)
--   node:SetSizer(sizer)
--  2. 添加按钮
--   local btn = wxGUI:wxCreateButton(node, "button", 55, 0)
--   local btn1 = wxGUI:wxCreateButton(node, "button", 55, 0)
--  3. 按钮设置按钮的布局参数
--   sizer:Add(btn, 1, wxOr(wx.wxEXPAND, wx.wxALL))
--   sizer:Add(btn1, 1, wxOr(wx.wxEXPAND, wx.wxALL))
--  4. 设置可拉伸的指定行和列  注意一定要和创建layout的时候的行列对应
--   ********* 这里的2种方法第一个参数对应 x行、x列
--   ********* 第二个参数对应的是该格的占取比例  为0 则所有人平分宽、高
--   sizer:AddGrowableRow(0, 0)
--   sizer:AddGrowableRow(1, 0)
--   sizer:AddGrowableCol(0, 0)
function wxGUI:createGridLayout(rows, cols, vgap, hgap)
    rows = rows or 1
    cols = cols or 1
    vgap = vgap or 0
    hgap = hgap or 0
    return wx.wxFlexGridSizer(rows, cols, vgap, hgap)
end
-- 调起系统的颜色选择器
-- 该方法会直接打开一个颜色选择器 所以业务里不建议直接调该方法
-- 而是去调wxGUI:wxCreateColorPick方法
function wxGUI:wxPopColorPick(parent, color, pickCall)
    local colorC =
        wx.wxColourDialog(parent, wxGUI:getWXColorData(color:Red(), color:Green(), color:Blue(), color:Alpha()))
    local result = colorC:ShowModal()
    return pickCall(result == wx.wxID_OK, colorC:GetColourData():GetColour())
end

function wxGUI:getWXColor(r, g, b, a)
    a = a or 255
    local color = wx.wxColour(r, g, b, a)
    return color
end

function wxGUI:getWXColorData(r, g, b, a)
    local color = wxGUI:getWXColor(r, g, b, a)
    local colorData = wx.wxColourData()
    colorData:SetColour(color)
    return colorData
end

function wxGUI:setPosition(node, x, y)
    node:Move(wx.wxPoint(x, y))
end
function wxGUI:setSize(node, wdith, height)
    node:SetSize(wx.wxSize(wdith, height))
end

return wxGUI
