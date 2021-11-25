local BUI, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS');
local LSM = E.LSM

local _G = _G
local pairs, print, tinsert, lower, next, wipe = pairs, print, table.insert, strlower, next, wipe
local format = string.format
local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local GetAddOnEnableState = GetAddOnEnableState

-- GLOBALS: LibStub, ElvDB

BUI["styles"] = {}
BUI["softGlow"] = {}
BUI.TexCoords = {.08, 0.92, -.08, 0.92}
BUI.Version = GetAddOnMetadata('ElvUI_BenikUI_Classic', 'Version')
BUI.ShadowMode = false;
BUI.AddonProfileKey = '';
BINDING_HEADER_BENIKUI = BUI.Title

function BUI:IsAddOnEnabled(addon) -- Credit: Azilroka
	return GetAddOnEnableState(E.myname, addon) == 2
end

-- Check other addons
BUI.SLE = BUI:IsAddOnEnabled('ElvUI_SLE')
BUI.PA = BUI:IsAddOnEnabled('ProjectAzilroka')
BUI.LP = BUI:IsAddOnEnabled('ElvUI_LocationPlus')
BUI.NB = BUI:IsAddOnEnabled('ElvUI_NutsAndBolts_Classic')
BUI.AS = BUI:IsAddOnEnabled('AddOnSkins')
BUI.IF = BUI:IsAddOnEnabled('InFlight_Load')
BUI.ZG = BUI:IsAddOnEnabled('ZygorGuidesViewerClassic')

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

local function PrintURL(url) -- Credit: Azilroka
	return format("|cFF00c0fa[|Hurl:%s|h%s|h]|r", url, url)
end

local function RegisterMedia()
	--Fonts
	E['media'].buiFont = LSM:Fetch('font', 'Bui Prototype')
	E['media'].buiVisitor = LSM:Fetch('font', 'Bui Visitor1')
	E['media'].buiVisitor2 = LSM:Fetch('font', 'Bui Visitor2')
	E['media'].buiTuk = LSM:Fetch('font', 'Bui Tukui')

	--Textures
	E['media'].BuiEmpty = LSM:Fetch('statusbar', 'BuiEmpty')
	E['media'].BuiFlat = LSM:Fetch('statusbar', 'BuiFlat')
	E['media'].BuiMelli = LSM:Fetch('statusbar', 'BuiMelli')
	E['media'].BuiMelliDark = LSM:Fetch('statusbar', 'BuiMelliDark')
	E['media'].BuiOnePixel = LSM:Fetch('statusbar', 'BuiOnePixel')
end

function BUI:cOption(name)
	local color = '|cff00c0fa%s |r'
	return (color):format(name)
end

local color = { r = 1, g = 1, b = 1, a = 1 }
function BUI:unpackColor(color)
	return color.r, color.g, color.b, color.a
end

function BUI:LuaError(msg)
	local switch = lower(msg)
	if switch == 'on' or switch == '1' then
		for i=1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if (name ~= 'ElvUI' and name ~= 'ElvUI_OptionsUI' and name ~= 'ElvUI_BenikUI_Classic') and E:IsAddOnEnabled(name) then
				DisableAddOn(name, E.myname)
				ElvDB.BuiErrorDisabledAddOns[name] = i
			end
		end

		SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			SetCVar('scriptErrors', 0)
			BUI:Print('Lua errors off.')
		end

		if next(ElvDB.BuiErrorDisabledAddOns) then
			for name in pairs(ElvDB.BuiErrorDisabledAddOns) do
				EnableAddOn(name, E.myname)
			end

			wipe(ElvDB.BuiErrorDisabledAddOns)
			ReloadUI()
		end
	else
		BUI:Print('/buierror on - /buierror off')
	end
end

local r, g, b = 0, 0, 0
function BUI:UpdateStyleColors()
	local BTT = BUI:GetModule('Tooltip')
	for frame, _ in pairs(BUI["styles"]) do
		if frame and not frame.ignoreColor then
			if E.db.benikui.colors.StyleColor == 1 then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif E.db.benikui.colors.StyleColor == 2 then
				r, g, b = BUI:unpackColor(E.db.benikui.colors.customStyleColor)
			elseif E.db.benikui.colors.StyleColor == 3 then
				r, g, b = BUI:unpackColor(E.db.general.valuecolor)
			else
				r, g, b = BUI:unpackColor(E.db.general.backdropcolor)
			end
			frame:SetBackdropColor(r, g, b, (E.db.benikui.colors.styleAlpha or 1))
		else
			BUI["styles"][frame] = nil;
		end
	end
	BTT:CheckTooltipStyleColor()
	BTT:RecolorTooltipStyle()
end

function BUI:UpdateStyleVisibility()
	for frame, _ in pairs(BUI["styles"]) do
		if frame and not frame.ignoreVisibility then
			if E.db.benikui.general.hideStyle then
				frame:Hide()
			else
				frame:Show()
			end
		end
	end
end

function BUI:UpdateSoftGlowColor()
	if BUI["softGlow"] == nil then BUI["softGlow"] = {} end

	local sr, sg, sb = BUI:unpackColor(E.db.general.valuecolor)

	for glow, _ in pairs(BUI["softGlow"]) do
		if glow then
			glow:SetBackdropBorderColor(sr, sg, sb, 0.6)
		else
			BUI["softGlow"][glow] = nil;
		end
	end
end

function BUI:DasOptions()
	E:ToggleOptionsUI(); LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "benikui")
end

function BUI:LoadCommands()
	self:RegisterChatCommand("benikui", "DasOptions")
	self:RegisterChatCommand("benikuisetup", "SetupBenikUI")
	self:RegisterChatCommand("buierror", "LuaError")
end

function BUI:Initialize()
	RegisterMedia()
	self:LoadCommands()
	self:SplashScreen()

	E:GetModule('DataTexts'):ToggleMailFrame()

	hooksecurefunc(E, "PLAYER_ENTERING_WORLD", function(self, _, initLogin)
		if initLogin or not ElvDB.BuiErrorDisabledAddOns then
			ElvDB.BuiErrorDisabledAddOns = {}
		end
	end)

	-- run install when ElvUI install finishes
	if E.private.install_complete == E.version and E.db.benikui.installed == nil then
		E:GetModule("PluginInstaller"):Queue(BUI.installTable)
	end

	-- run the setup again when a profile gets deleted.
	local profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
	if ElvDB.profileKeys and profileKey == nil then
		E:GetModule("PluginInstaller"):Queue(BUI.installTable)
	end

	if E.db.benikui.general.loginMessage then
		print(BUI.Title..format('v|cff00c0fa%s|r',BUI.Version)..L[' is loaded. For any issues or suggestions, please visit ']..PrintURL('https://github.com/Benik/BenikUI-Classic/issues'))
	end

	if E.db.benikui.general.benikuiStyle and E.db.benikui.general.shadows then
		BUI.ShadowMode = true
	end

	tinsert(E.ConfigModeLayouts, #(E.ConfigModeLayouts)+1, "BenikUI")
	E.ConfigModeLocalizedStrings["BenikUI"] = BUI.Title

	BUI.AddonProfileKey = BUI.Title..E.myname.." - "..E.myrealm

	hooksecurefunc(E, "UpdateMedia", BUI.UpdateSoftGlowColor)
	hooksecurefunc(BUI, "SetupColorThemes", BUI.UpdateStyleColors)
end
