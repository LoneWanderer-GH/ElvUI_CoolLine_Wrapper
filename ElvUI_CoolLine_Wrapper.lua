
local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_CoolLine_Wrapper = E:NewModule('ElvUI_CoolLine_Wrapper', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

local MoverName = "ElvUI_CoolLine_Mover"

local IS_WOW_8 = GetBuildInfo():match("^8")
local IS_WOW_CLASSIC = GetBuildInfo():match("^1")

local dependancy = "CoolLine"

P["ElvUI_CoolLine_Wrapper"] = {
    ["DebugMode"] = false,
}

-- for debug (yeah ugly)
------------------------------------------------
function ElvUI_CoolLine_Wrapper:logger(message)
    ------------------------------------------------
    if E.db.ElvUI_CoolLine_Wrapper and E.db.ElvUI_CoolLine_Wrapper.DebugMode then
        print("|cff1784d1ElvUI|r |cff00b3ffCoolLine |cffff7d0aWrapper|r " .. message)
    end
end

------------------------------------------------
function ElvUI_CoolLine_Wrapper:PLAYER_ENTERING_WORLD()
------------------------------------------------
    -- ElvUI_CoolLine_Wrapper:logger("PLAYER_ENTERING_WORLD")
    --self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self.CreateMover()
end

E:RegisterModule(ElvUI_CoolLine_Wrapper:GetName())

ElvUI_CoolLine_Wrapper:RegisterEvent("PLAYER_ENTERING_WORLD")

----------------------------------------
function ElvUI_CoolLine_Wrapper:CreateMover()
    ----------------------------------------
    if not E.CreatedMovers[MoverName] then
        if CoolLine.MainFrame then
            CoolLine.MainFrame:SetMovable(false)
            --ElvUI_CoolLine_Wrapper:logger('Making CoolLine frame NOT movable (for ElvUI movers to work !)')
            E:CreateMover(CoolLine.MainFrame, MoverName, L[MoverName], nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')
            ElvUI_CoolLine_Wrapper:logger('CreateMover-Mover created !')
        else
            -- find a way to postpone creation later ?
            ElvUI_CoolLine_Wrapper:logger('CreateMover- CoolLine frame not found/valid ... Find a way to postpone creation later ?')
        end
    end
end

----------------------------------------
function ElvUI_CoolLine_Wrapper:Update()
    ----------------------------------------
    --self.CreateMover()

    ElvUI_CoolLine_Wrapper:logger('Update-Set CoolLine config')
    self.SetConfig()
end

-----------------------------------------------
function ElvUI_CoolLine_Wrapper:InsertOptions()
    -----------------------------------------------
    ElvUI_CoolLine_Wrapper:logger("InsertOptions")
    E.Options.args.ElvUI_CoolLine_Wrapper = {
        order = 1000,
        type = "group",
        name = "|cff00b3ffCoolLine|r |cff00ffdaWrapper",
        childGroups = "tab",
        args = {
            name = {
                order = 1,
                type = "header",
                name = "CoolLine options ( ElvUI wrapper)",
            },
            desc = {
                order = 2,
                type = "description",
                name = "",
            },
            credits = {
                order = 3,
                type = "group",
                name = "Credits",
                guiInline = true,
                args = {
                    tukui = {
                        order = 1,
                        type = "description",
                        fontSize = "medium",
                        name = format("|cff9482c9LoneWanderer-GH|r"),
                    },
                },
            },
            fontConfig = {
                type = "group",
                name = "Fonts",
                order = 4,
                guiInline = true,
                args = {
                    font = {
                        type = "select",
                        dialogControl = "LSM30_Font",
                        order = 1,
                        name = L["Font"],
                        values = AceGUIWidgetLSMlists.font,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.fontConfig.font
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.fontConfig.font = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                    size = {
                        order = 2,
                        name = L["Font Size"],
                        type = "range",
                        min = 6, max = 48, step = 1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.fontConfig.fontSize
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.fontConfig.fontSize = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                },
            },
            sizing = {
                type = "group",
                name = "Size",
                order = 5,
                guiInline = true,
                args = {
                    width = {
                        order = 1,
                        type = "range",
                        name = "Width",
                        min = 5,
                        max = 500,
                        step = 1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.sizing.width
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.sizing.width = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                    height = {
                        order = 2,
                        type = "range",
                        name = "Height",
                        min = 5,
                        max = 500,
                        step = 1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.sizing.height
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.sizing.height = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                },
            },
            visibility = {
                type = "group",
                name = "Visibility",
                order = 6,
                guiInline = true,
                args = {
                    active = {
                        order = 1,
                        type = "range",
                        name = "Active alpha",
                        min = 0, max = 1, step = 0.1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.visibility.active
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.visibility.active = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                    inactive = {
                        order = 1,
                        type = "range",
                        name = "Inactive alpha",
                        min = 0, max = 1, step = 0.1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.visibility.inactive
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.visibility.inactive = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                },
            },
            DebugMode = {
                order = 1,
                type = "toggle",
                name = "Debug Mode (mostly logging to console)",
                get = function(info)
                    return E.db.ElvUI_CoolLine_Wrapper.DebugMode
                end,
                set = function(info, value)
                    E.db.ElvUI_CoolLine_Wrapper.DebugMode = value
                    ElvUI_CoolLine_Wrapper:Update()
                end,
            },
        },
    }
end

--------------------------------------------
function ElvUI_CoolLine_Wrapper:Initialize()
    --------------------------------------------
    ElvUI_CoolLine_Wrapper:logger('Initialize')

    local w, h, x, y, font, fontsize, inactivealpha, activealpha, statusbar = CoolLine:getConfig()
    -- force CoolLine config if it exists
    ElvUI_CoolLine_Wrapper:logger("Updating ElvUI wrapper config data with CoolLine config data")

    if not E.db.ElvUI_CoolLine_Wrapper then
        E.db.ElvUI_CoolLine_Wrapper = {}
    end

    E.db.ElvUI_CoolLine_Wrapper["fontConfig"] = {
        ["font"] = font,
        ["fontSize"] = fontsize,
    }
    E.db.ElvUI_CoolLine_Wrapper["sizing"] = {
        ["width"] = w,
        ["height"] = h,
    }
    E.db.ElvUI_CoolLine_Wrapper["visibility"] = {
        ["active"] = activealpha,
        ["inactive"] = inactivealpha,
    }

    ElvUI_CoolLine_Wrapper:logger('Initialize-Register ElvUI plugin')
    EP:RegisterPlugin(addonName, ElvUI_CoolLine_Wrapper.InsertOptions)

    ElvUI_CoolLine_Wrapper:logger('Initialize-Call update')
    --ElvUI_CoolLine_Wrapper:CreateMover()
    ElvUI_CoolLine_Wrapper:Update()
end

-------------------------------------------
function ElvUI_CoolLine_Wrapper:SetConfig()
    -------------------------------------------
    if E.db and E.db.ElvUI_CoolLine_Wrapper then
        if CoolLine.MainFrame then
            w = E.db.ElvUI_CoolLine_Wrapper.sizing.width or nil
            h = E.db.ElvUI_CoolLine_Wrapper.sizing.height or nil
            x = nil -- E.db.ElvUI_CoolLine_Wrapper.placing.horizontal or nil
            y = nil -- E.db.ElvUI_CoolLine_Wrapper.placing.vertical or nil
            font = E.db.ElvUI_CoolLine_Wrapper.fontConfig.font or nil
            fontSize = E.db.ElvUI_CoolLine_Wrapper.fontConfig.fontSize or nil
            inactivealpha = E.db.ElvUI_CoolLine_Wrapper.visibility.inactive or nil
            activealpha = E.db.ElvUI_CoolLine_Wrapper.visibility.active or nil
            statusbar = nil or nil
            ElvUI_CoolLine_Wrapper:logger('SetConfig-Call CoolLine SetConfig')
            CoolLine.MainFrame:SetConfig(w, h, x, y, font, fontSize, inactivealpha, activealpha, statusbar, CoolLine.NO_RELOCATE)
        else
            ElvUI_CoolLine_Wrapper:logger('SetConfig-CoolLine Mainframe could not be found ?!')
        end
    else
        ElvUI_CoolLine_Wrapper:logger('SetConfig- No ElvUI_CoolLine_Wrapper config elements')
    end
end

