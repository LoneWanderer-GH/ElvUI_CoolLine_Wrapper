
local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_CoolLine_Wrapper = E:NewModule('ElvUI_CoolLine_Wrapper', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

local MoverName = "ElvUI_CoolLine_Mover"

P["ElvUI_CoolLine_Wrapper"] = {
	["FrameMoverToggleOption"] = false,
}

function ElvUI_CoolLine_Wrapper:Update()
	local enabled = E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption
    
    if not E.CreatedMovers[MoverName] then
        if CoolLine.MainFrame then
            E:CreateMover(CoolLine.MainFrame, MoverName, L[MoverName], nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')
            print ('Update-Mover created')
        else
            -- find a way to postpone creation later ?
            print ('Update-Find a way to postpone creation later ?')
        end
    end
    if E.CreatedMovers[MoverName] then
        print ('Update-Mover exists')
        if enabled then
            print ('Update-Enable it')
            E:EnableMover(MoverName)
        else
            print ('Update-Disable it')
            E:DisableMover(MoverName)
        end
    else
        print ('Update-Mover does not exist yet')
    end
end

function ElvUI_CoolLine_Wrapper:InsertOptions()
	E.Options.args.ElvUI_CoolLine_Wrapper = {
		order = 5,
		type = "group",
		name = "> CoolLine <",
		args = {
			FrameMoverToggleOption = {
				order = 1,
				type = "toggle",
				name = "CoolLine Frame Mover",
				get = function(info)
					return E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption
				end,
				set = function(info, value)
                    print ('OptionChanged-FrameMoverToggleOption')
					E.db.ElvUI_CoolLine_Wrapper.FrameMoverToggleOption = value
					ElvUI_CoolLine_Wrapper:Update()
				end,
			},
		},
	}
end

function ElvUI_CoolLine_Wrapper:Initialize()
    print ('Initialize')
	EP:RegisterPlugin(addonName, ElvUI_CoolLine_Wrapper.InsertOptions)
    ElvUI_CoolLine_Wrapper:Update()
end

ElvUI_CoolLine_Wrapper:RegisterEvent("ADDON_LOADED")
function ElvUI_CoolLine_Wrapper:ADDON_LOADED(a1)
	if a1 ~= "CoolLine" then return end
	self:UnregisterEvent("ADDON_LOADED")
    if not E.CreatedMovers[MoverName] then
        if CoolLine.MainFrame then
            E:CreateMover(CoolLine.MainFrame, MoverName, L[MoverName], nil, nil, nil, 'ALL,SOLO,ACTIONSBARS,PARTY,ARENA,RAID')
            print ('ADDON_LOADED-Mover created')
        else
            -- find a way to postpone creation later ?
            print ('ADDON_LOADED-Find a way to postpone creation later ?')
        end
    else
        print ('ADDON_LOADED-Mover exists')
    end
end

E:RegisterModule(ElvUI_CoolLine_Wrapper:GetName())