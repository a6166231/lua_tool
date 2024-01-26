local wxGUI = require "stab.scripts.init.wxGUI"
local print = release_print
local wxMenu = class("wxMenu")

local cid = 10000

function getCID()
    cid = cid + 1
    return cid
end

--菜单设置
local menuList = {
    {
        name = "option",
        submenu = {
            {
                name = "setting",
                call = function()
                    release_print("555555555555555")
                end
            }
        }
    },
    {
        name = "about",
        submenu = {
            {
                id = wx.wxID_ABOUT,
                name = "about us",
                call = function(e, caller)
                    caller:createHelpDialog()
                end
            }
        }
    }
}

local helpData = {
    {
        name = "wbuhui",
        urlshow = "@Github",
        url = "https://github.com/a6166231"
    },
    {
        name = "wzp",
        urlshow = "@Gitee",
        url = "https://gitee.com/eric"
    }
}

function wxMenu.create(data)
    local menu = wxMenu.new(data)
    if menu:initializeMenu() then
        return menu
    end
    return nil
end

function wxMenu:ctor(data)
    self.frame = data.frame
end

function wxMenu:initializeMenu()
    self.wxMenuBar = wxGUI:wxCreateMenuBar()
    self:initMenuList()
    self.frame:SetMenuBar(self.wxMenuBar)
end

function wxMenu:createHelpDialog()
    local dialog = wxGUI:wxCreateDialog(self.frame, "about us")

    local sizer = wxGUI:createBoxSizer(false)
    dialog:SetSizer(sizer)

    local sizer3 = wxGUI:createBoxSizer(true)
    local lb = wxGUI:wxCreateLabel(dialog, "lua-tree by ")
    local link = wxGUI:wxCreateHyperLink(dialog, "wxWidget.", "https://www.wxwidgets.org/")

    sizer3:Add(lb, 1, wx.wxALIGN_CENTER)
    sizer3:Add(link, 1, wx.wxALIGN_CENTER)

    local sizer2 = wxGUI:createBoxSizer(true)

    local inject = false
    for k, v in pairs(helpData) do
        if inject then
            local lb2 = wxGUI:wxCreateLabel(dialog, wx.wxString(" and "))
            sizer2:Add(lb2)
        end
        inject = true
        local lb = wxGUI:wxCreateLabel(dialog, v.name .. ": ")
        sizer2:Add(lb)
        local link = wxGUI:wxCreateHyperLink(dialog, v.urlshow, v.url)
        sizer2:Add(link)
    end

    sizer:Add(sizer3, 1, wxOr(wx.wxALIGN_CENTRE_VERTICAL, wx.wxALIGN_CENTER))
    sizer:Add(sizer2, 1, wxOr(wx.wxALIGN_CENTRE_VERTICAL, wx.wxALIGN_CENTER))
    dialog:Show(true)
end

function wxMenu:initMenuList()
    for k, v in pairs(menuList) do
        local menu = wxGUI:wxCreateMenu(v.name)
        self.wxMenuBar:Append(menu, v.name)
        local menuItemList = menu:GetMenuItems()
        local titleId = menu:FindItem(v.name)
        if v.submenu then
            for subk, subv in pairs(v.submenu) do
                local cid = subv.id or getCID()
                menu:Append(cid, subv.name)
                if subv.call then
                    self.frame:Connect(
                        cid,
                        wx.wxEVT_COMMAND_MENU_SELECTED,
                        function(event)
                            subv.call(event, self)
                        end
                    )
                end
            end
        end
        menu:Destroy(titleId)
    end
end

return wxMenu
