
local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_CoolLine_Wrapper = E:NewModule('ElvUI_CoolLine_Wrapper', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

P["ElvUI_CoolLine_Wrapper"] = {
    ["FrameMoverToggleOption"] = false,
}

local nbCreated = 0
local WrapperCreatedMovers = {}

local IsAddOnLoaded = IsAddOnLoaded

-- preparation of a more Generic version of this addon to create movers for "any" addon ... to be continued/confirmed
local wrappedAddonName = "CoolLine"

local wrappedAddons = {
    "AddonName" = "FrameName"
    -- todo: think of way to store list of frames and wrap them
    "CoolLine" = "CoolLine"
}

-----------------------------------------
local function MyLogger(methodName, text)
    -----------------------------------------
    print ("|cff00b3ff" .. addonName .. " - " .. methodName .. "()|r - " .. text)
end

-----------------------------------------
local function Create_ElvUI_Mover(frame, stringName)
    -----------------------------------------
    local MoverUniqueName = wrappedAddonName .. "__" .. stringName .. "__Mover"
    local MoverDisplayName = "E_WrapMover_"..wrappedAddonName

    if not E.CreatedMovers[MoverUniqueName] then

        MyLogger("Create_ElvUI_Mover", "Mover for " .. stringName .. " not yet created")

        if frame then

            MyLogger("Create_ElvUI_Mover", "Frame " .. stringName .. " found. Create mover")

            nbCreated = nbCreated + 1
            MoverDisplayName = MoverDisplayName .. "_" .. nbCreated

            E:CreateMover(frame, MoverUniqueName, MoverDisplayName, nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')

            MyLogger("Create_ElvUI_Mover", MoverDisplayName .. " mover created")

            WrapperCreatedMovers [nbCreated] = MoverDisplayName
        else
            MyLogger("Create_ElvUI_Mover", "Frame " .. stringName .. " not found")
        end
    else
        MyLogger("Create_ElvUI_Mover", MoverDisplayName .. " already exists")
    end
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:CreateMovers()
    -----------------------------------------
    Create_ElvUI_Mover(CoolLine, "CoolLine")
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:Update()
    -----------------------------------------
    -- call when config has changed ?!
    MyLogger("Update", "Start")
    local enabled = E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption

    --MyLogger("Update", "Try to create Mover")

    --self:CreateMovers()

    for k, v in pairs(WrapperCreatedMovers) do
        if E.CreatedMovers[v] then

            MyLogger("Update", "Mover " .. v .. " exists")

            if enabled then

                MyLogger("Update", "Enable " .. v)
                E:EnableMover(v)

            else

                MyLogger("Update", "Disable " .. v)
                E:DisableMover(v)

            end
        else
            MyLogger("Update", "Mover " .. v .. " supposed to already be created but does not exist yet ?!")
        end
    end

end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:InsertOptions()
    -----------------------------------------
    MyLogger("InsertOptions", "Start")

    E.Options.args.ElvUI_CoolLine_Wrapper = {
        order = 5,
        type = "group",
        name = "> " .. wrappedAddonName .. " <",
        args = {
            FrameMoverToggleOption = {
                order = 1,
                type = "toggle",
                name = wrappedAddonName .. " Frames Movers",
                get = function(info)
                    return E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption
                end,
                set = function(info, value)
                    MyLogger("ToggleOptionChanged", "FrameMoverToggleOption")
                    E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption = value
                    ElvUI_CoolLine_Wrapper:Update()
                end,
            },
        },
    }
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:Initialize()
    -----------------------------------------
    MyLogger("Initialize", "Start")

    MyLogger("Initialize", "called from ElvUI because of previous register")

    EP:RegisterPlugin(addonName, ElvUI_CoolLine_Wrapper.InsertOptions)

    if IsAddOnLoaded(wrappedAddonName) then
        MyLogger("Initialize", wrappedAddonName .. " is loaded, create the mover")
        self:CreateMovers()
    else
        MyLogger("Initialize", wrappedAddonName .. " not yet loaded ?! Addon probably absent.")
    end
end

--------------------------------
function ElvUI_CoolLine_Wrapper:doRegister()
    --------------------------------
    MyLogger("doRegister", "Register module to ELVUI. This will later trigger the Initialize method")
    E:RegisterModule(ElvUI_CoolLine_Wrapper:GetName())
end

--------------------------------
function ElvUI_CoolLine_Wrapper:PLAYER_ALIVE()
    --------------------------------
    MyLogger("PLAYER_ALIVE", "Start")
    self:doRegister()
end

--------------------------------
function ElvUI_CoolLine_Wrapper:PLAYER_DEAD()
    --------------------------------
    MyLogger("PLAYER_DEAD", "Start")
    self:doRegister()
end

-- addon reacts only to these events
ElvUI_CoolLine_Wrapper:RegisterEvent("PLAYER_ALIVE")
ElvUI_CoolLine_Wrapper:RegisterEvent("PLAYER_DEAD")
