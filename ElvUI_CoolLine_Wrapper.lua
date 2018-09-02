
local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_CoolLine_Wrapper = E:NewModule('ElvUI_CoolLine_Wrapper', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2
--local E_Conf = P[addonName]
--P["ElvUI_CoolLine_Wrapper"] = {
--    ["FrameMoverToggleOption"] = false,
--}
P[addonName] = {}

--local nbCreated = 0
--local WrapperCreatedMovers = {}

local IsAddOnLoaded = IsAddOnLoaded

-- association Addon <=> Frame
local wrappedAddons = {
    ["CoolLine"] = {{frame = CoolLine, description = "The CoolLine cooldowns frame"}, },
    ["TomTom"] = {{frame = TomTomCrazyArrow, description = "The TomTom arrow frame"}, },
}

---- association Addon <=> Framewdescription (in case several frames to manage)
--local wrappedAddonsFramesDesriptions = {
--    --"AddonName" = "FrameObject",
--    ["CoolLine"] = "CoolLine",
--    ["TomTom"] = "TomTomCrazyArrow",
--}

-----------------------------------------
local function MyLogger(methodName, text)
    -----------------------------------------
    print ("|cff00b3ff" .. addonName .. " - " .. methodName .. "()|r - " .. text)
end
local function buildMoverName(wrappedAddonName, frameDescription)
    return wrappedAddonName .. "__" .. frameDescription .. "__Mover"
end
-----------------------------------------
local function Create_ElvUI_Mover(wrappedAddonName, frame, frameDescription)
    -----------------------------------------
    local MoverUniqueName = buildMoverName(wrappedAddonName, frameDescription)
    if not E.CreatedMovers[MoverUniqueName] then
        --MyLogger("Create_ElvUI_Mover", "Mover for " .. frameDescription .. " not yet created")
        if frame then
            --MyLogger("Create_ElvUI_Mover", "Frame " .. frameDescription .. " found. Create mover")
            E:CreateMover(frame, MoverUniqueName, MoverUniqueName, nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')

        else
            -- TODO : put some code to perform a retry ?
            MyLogger("Create_ElvUI_Mover", "Frame " .. frameDescription .. " not found")
        end
    else
        --MyLogger("Create_ElvUI_Mover", MoverDisplayName .. " already exists")
    end
end

local function buildOptionKey(wrappedAddonName, frameDescription)
    return wrappedAddonName .. "_" .. frameDescription .. "_ToggleOption"
end

local function addOptionKey(wrappedAddonName, frameDescription, value)
    --if E_Conf then
    if P then
        if P[addonName] then
            P[addonName][buildOptionKey(wrappedAddonName, frameDescription)] = value
        else
            MyLogger("addOptionKey", "ElvUI profileDB has no value for key " .. addonName .. " ?")
        end
    else
        MyLogger("addOptionKey", "ElvUI profileDB does not exist ?")
    end
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:CreateMovers()
    -----------------------------------------
    for wrappedAddonName, wrappedAddonFramesData in pairs(wrappedAddons) do
        for k1, frameData in pairs(wrappedAddonFramesData) do
            local frame = frameData.frame
            local frameDescription = frameData.description

            --MyLogger("CreateMovers", "processing ".. wrappedAddonName .." conf")
            --MyLogger("CreateMovers", wrappedAddonName .." - " .. frame .. " - " .. frameDescription)

            if IsAddOnLoaded(wrappedAddonName) then
                --MyLogger("CreateMovers", wrappedAddonName .. " is loaded, create the mover")
                Create_ElvUI_Mover(wrappedAddonName, frame, frameDescription)
                addOptionKey(wrappedAddonName, frameDescription, true)
            else
                MyLogger("CreateMovers", wrappedAddonName .. " not yet loaded ?! Addon probably absent.")
            end
        end
    end
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:Update()
    -----------------------------------------
    MyLogger("Update", "Start")

    for wrappedAddonName, wrappedAddonFramesData in pairs(wrappedAddons) do
        for k1, frameData in pairs(wrappedAddonFramesData) do
            local frame = frameData.frame
            local frameDescription = frameData.description
            local optionKey = buildOptionKey(wrappedAddonName, frameDescription)
            local MoverUniqueName = buildMoverName(wrappedAddonName, frameDescription)
            local enabled = E.db.ElvUI_CoolLine_Wrapper[optionKey]
            if E.CreatedMovers[MoverUniqueName] then
                if enabled then
                    MyLogger("Update", "Enable " .. optionKey)
                    E:EnableMover(MoverUniqueName)
                else
                    MyLogger("Update", "Disable " .. optionKey)
                    E:DisableMover(MoverUniqueName)
                end
            else
                MyLogger("Update", "Mover "..MoverUniqueName.." supposed to exist but not found")
            end
        end
    end
end

local function addToggleConfigOption(wrappedAddonName, frame, frameDescription, optionKey, frameOptionOrder)
    E.Options.args[addonName].args[wrappedAddonName].args[frameDescription] = {
        order = frameOptionOrder,
        type = "toggle",
        name = frameDescription,
        get = function(info)
            return E.db.ElvUI_CoolLine_Wrapper[optionKey]
        end,
        set = function(info, value)
            MyLogger(wrappedAddonName .. " ToggleOptionChanged", frameDescription .. " ToggleOption ")
            E.db.ElvUI_CoolLine_Wrapper[optionKey] = value
            ElvUI_CoolLine_Wrapper:Update()
        end,
        --frame = frame
    }
end
local function addWrapperAddonOptions(wrappedAddonName, wrappedAddonFramesData)
    -- fill addon wrapping options
    local frameOptionOrder = 1
    for k1, frameData in pairs(wrappedAddonFramesData) do
        local frame = frameData.frame
        local frameDescription = frameData.description
        local optionKey = buildOptionKey(wrappedAddonName, frameDescription)

        --MyLogger("addWrapperAddonOptions", "Treating " .. wrappedAddonName .. " frame " .. frameDescription)
        --MyLogger("addWrapperAddonOptions", "Add correspongind toggle option")

        addToggleConfigOption(wrappedAddonName, frame, frameDescription, optionKey, frameOptionOrder)
        frameOptionOrder = frameOptionOrder + 1
    end
end
-----------------------------------------
function ElvUI_CoolLine_Wrapper:InsertOptions()
    -----------------------------------------
    ----MyLogger("InsertOptions", "Start")
    ----MyLogger("InsertOptions", "Add " .. addonName .. "group")
    --E.Options.args[addonName] = {
    --    order = 5,
    --    type = "group",
    --    name = "|cFF00FFFFAddonFrames|ralpha",
    --    args = {
    --        generalHeader = {
    --            order = 1,
    --            type = "header",
    --            name = addonName,
    --        },
    --    },
    --}

    ----MyLogger("InsertOptions", "Start loop over all wrapped addons")
    --for wrappedAddonName, wrappedAddonFramesData in pairs(wrappedAddons) do
    --    local optionsOrder = 1
    --    --MyLogger("InsertOptions", "Treating " .. wrappedAddonName)
    --    --MyLogger("InsertOptions", "Add generalHeader")
    --    E.Options.args[addonName].args[wrappedAddonName] = {
    --        order = optionsOrder,
    --        type = "group",
    --        name = "|cff1784d1" .. wrappedAddonName,
    --        args = {},
    --        --toggleOptions = {},
    --    }

    --    --MyLogger("InsertOptions", "Start loop over " .. wrappedAddonName .." managed frames")
    --    addWrapperAddonOptions(wrappedAddonName, wrappedAddonFramesData)

    --    optionsOrder = optionsOrder + 1
    --end
    --MyLogger("InsertOptions", "End !")
end

-----------------------------------------
function ElvUI_CoolLine_Wrapper:Initialize()
    -----------------------------------------
    --MyLogger("Initialize", "Start")
    --MyLogger("Initialize", "called from ElvUI because of previous register")
    EP:RegisterPlugin(addonName, ElvUI_CoolLine_Wrapper.InsertOptions)
    self:CreateMovers()
    --self:InsertOptions()
end

--------------------------------
function ElvUI_CoolLine_Wrapper:doRegister()
    --------------------------------
    --MyLogger("doRegister", "Register module to ELVUI. This will later trigger the Initialize method")
    E:RegisterModule(ElvUI_CoolLine_Wrapper:GetName())
end

--------------------------------
function ElvUI_CoolLine_Wrapper:PLAYER_ALIVE()
    --------------------------------
    --MyLogger("PLAYER_ALIVE", "Start")
    self:doRegister()
end

--------------------------------
function ElvUI_CoolLine_Wrapper:PLAYER_DEAD()
    --------------------------------
    --MyLogger("PLAYER_DEAD", "Start")
    self:doRegister()
end

-- addon reacts only to these events
ElvUI_CoolLine_Wrapper:RegisterEvent("PLAYER_ALIVE")
ElvUI_CoolLine_Wrapper:RegisterEvent("PLAYER_DEAD")
