
local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_CoolLine_Wrapper = E:NewModule('ElvUI_CoolLine_Wrapper', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

local MoverName = "ElvUI_CoolLine_Mover"

local IS_WOW_8 = GetBuildInfo():match("^8")
local IS_WOW_CLASSIC = GetBuildInfo():match("^1")

local dependancy = "CoolLine"

--[[do
    if IS_WOW_CLASSIC then
        dependancy = "CoolLine - Classic compatible"
    else if IS_WOW_8 then
        -- yup, redundant !
        dependancy = "CoolLine"
    else
        print("ElvUI_CoolLine_Wrapper is either compatible with WoW (8.xxx) or Wow Classic (1.xxx)")
        print("Some code update required ... please report to github https://github.com/LoneWanderer-GH/ElvUI_CoolLine_Wrapper")
    end
end--]]


local function logger(message)
    print("|cff1784d1ElvUI|r |cff00b3ffCoolLine |cffff7d0aWrapper|r " .. message)
end

--[[if E and E.db and E.db.ElvUI_CoolLine_Wrapper then
    logger("Existing config:\n"..E.db.ElvUI_CoolLine_Wrapper)
else
    -- default config
    logger("Setting a default config")
    E.db.ElvUI_CoolLine_Wrapper = {
        ["FrameMoverToggleOption"] = false,
        ["fontConfig"] = {
            ["font"] = nil,
            ["fontSize"] = nil,
        },
        ["sizing"] = {
            ["w"] = 10,
            ["h"] = 100,
        },
        ["placing"] = {
            ["x"] = 0,
            ["y"] = 0,
        }
    }
end--]]


------------------------------------------------
function ElvUI_CoolLine_Wrapper:ADDON_LOADED(a1)
------------------------------------------------
    if a1 ~= dependancy then return end

    logger("ADDON_LOADED - CoolLine's 'ADDON_LOADED' intercepted")
    self:UnregisterEvent("ADDON_LOADED")

    self.CreateMover()

end


E:RegisterModule(ElvUI_CoolLine_Wrapper:GetName())

ElvUI_CoolLine_Wrapper:RegisterEvent("ADDON_LOADED")

----------------------------------------
function ElvUI_CoolLine_Wrapper:CreateMover()
----------------------------------------
    if not E.CreatedMovers[MoverName] then
        if CoolLine.MainFrame then
            E:CreateMover(CoolLine.MainFrame, MoverName, L[MoverName], nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')
            E:CreateMover(CoolLine.Overlay,   MoverName.."overlay", L[MoverName.."overlay"], nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')
            logger ('CreateMover-Mover created !!!!!!!!!!!!!!')
        else
            -- find a way to postpone creation later ?
            logger ('CreateMover- CoolLine frame not found/valid ... Find a way to postpone creation later ?')
        end
    end
end

----------------------------------------
function ElvUI_CoolLine_Wrapper:ToggleMover()
----------------------------------------
--[[    local enabled = E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption
    if E.CreatedMovers[MoverName] then
        logger ('ToggleMover-Mover exists')
        if enabled then
            logger ('ToggleMover-Enable it')
            E:EnableMover(MoverName)
        else
            logger ('ToggleMover-Disable it')
            E:DisableMover(MoverName)
        end
    else
        logger ('ToggleMover-Mover does not exist yet ?!')
    end--]]
end

----------------------------------------
function ElvUI_CoolLine_Wrapper:Update()
----------------------------------------
    self.CreateMover()

    logger ('Update-Set CoolLine config')
    self.SetConfig()

    logger ('Update-Toggle mover')
    self.ToggleMover()
end

-----------------------------------------------
function ElvUI_CoolLine_Wrapper:InsertOptions()
-----------------------------------------------
    logger("InsertOptions")
    E.Options.args.ElvUI_CoolLine_Wrapper = {
        order = 1000,
        type = "group",
        name = "> CoolLine <",
        childGroups = "tab",
        args = {
            name = {
                order = 1,
                type = "header",
                name = "CoolLine options ( ElvUI wrapper)",
            },
            credits = {
                order = 2,
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
--[[            placing = {
                type = "group",
                name = "Placing configuration",
                order = 6,
                --guiInline = true,
                args = {
                    horizontal = {
                        order = 1,
                        type = "range",
                        name = "CoolLine X",
                        min = 5,
                        max = 500,
                        step = 1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.placing.horizontal
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.placing.horizontal = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                    vertical = {
                        order = 2,
                        type = "range",
                        name = "CoolLine Y",
                        min = 5,
                        max = 500,
                        step = 1,
                        get = function(info)
                            return E.db.ElvUI_CoolLine_Wrapper.placing.vertical
                        end,
                        set = function(info, value)
                            E.db.ElvUI_CoolLine_Wrapper.placing.vertical = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                },
            },--]]
--[[                        FrameMoverToggleOption = {
                order = 3,
                type = "toggle",
                name = "CoolLine Frame Mover",
                get = function(info)
                    return E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption
                end,
                set = function(info, value)
                    logger ('OptionChanged-FrameMoverToggleOption')
                    E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption = value
                    ElvUI_CoolLine_Wrapper:Update()
                end,
            },--]]
            fontConfig = {
                type = "group",
                name = "Fonts configuration",
                order = 4,
                --guiInline = true,
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
                                logger ('OptionChanged-fontConfig.font')
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
                            logger ('OptionChanged-fontConfig.fontSize')
                            E.db.ElvUI_CoolLine_Wrapper.fontConfig.fontSize = value
                            ElvUI_CoolLine_Wrapper:Update()
                        end,
                    },
                },
            },
            sizing = {
                type = "group",
                name = "Sizing configuration",
                order = 5,
                --guiInline = true,
                args = {
                    width = {
                        order = 1,
                        type = "range",
                        name = "CoolLine Width",
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
                        name = "CoolLine Height",
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
        },
    }
end

--------------------------------------------
function ElvUI_CoolLine_Wrapper:Initialize()
--------------------------------------------
    logger ('Initialize')

    w, h, x, y, font, fontsize, inactivealpha, activealpha, statusbar = CoolLine:getConfig()
    -- force CoolLine config if it exists
    logger("Updating ElvUI wrapper config data with CoolLine config data")

    if E.db.ElvUI_CoolLine_Wrapper then
        --
    else
        E.db.ElvUI_CoolLine_Wrapper = {}
    end
    E.db.ElvUI_CoolLine_Wrapper["fontConfig"] = {
                ["font"]     = font,
                ["fontSize"] = fontsize,
            }
    E.db.ElvUI_CoolLine_Wrapper["sizing"] = {
            ["width"]  = w,
            ["height"] = h,
        }
--[[    E.db.ElvUI_CoolLine_Wrapper["placing"] = {
            ["horizontal"] = x,
            ["vertical"]   = y,
    }--]]
    E.db.ElvUI_CoolLine_Wrapper["visibility"] = {
            ["active"]   = activealpha,
            ["inactive"] = inactivealpha,
    }

    logger ('Initialize-Register ElvUI plugin')
    EP:RegisterPlugin(addonName, ElvUI_CoolLine_Wrapper.InsertOptions)

    logger ('Initialize-Call update')
    ElvUI_CoolLine_Wrapper:Update()
end


-------------------------------------------
function ElvUI_CoolLine_Wrapper:SetConfig()
-------------------------------------------
    if E.db and E.db.ElvUI_CoolLine_Wrapper then
        if CoolLine.MainFrame then
            w             = E.db.ElvUI_CoolLine_Wrapper.sizing.width or nil
            h             = E.db.ElvUI_CoolLine_Wrapper.sizing.height or nil
            x             = nil -- E.db.ElvUI_CoolLine_Wrapper.placing.horizontal or nil
            y             = nil -- E.db.ElvUI_CoolLine_Wrapper.placing.vertical or nil
            font          = E.db.ElvUI_CoolLine_Wrapper.fontConfig.font or nil
            fontSize      = E.db.ElvUI_CoolLine_Wrapper.fontConfig.fontSize or nil
            inactivealpha = nil or nil
            activealpha   = nil or nil
            statusbar     = nil or nil
            logger ('SetConfig-Call CoolLine SetConfig')
            CoolLine.MainFrame:SetConfig(w, h, x, y, font, fontsize, inactivealpha, activealpha, statusbar)
        else
            logger ('SetConfig-CoolLine Mainframe could not be found ?!')
        end
    else
        logger ('SetConfig- No ElvUI_CoolLine_Wrapper config elements')
    end
end

