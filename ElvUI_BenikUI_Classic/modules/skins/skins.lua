local BUI, E, L, V, P, G = unpack(select(2, ...))
local mod = BUI:NewModule("Skins", "AceHook-3.0", "AceEvent-3.0")
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn
local InCombatLockdown = InCombatLockdown
local GetQuestLogTitle = GetQuestLogTitle

local C_TimerAfter = C_Timer.After

-- GLOBALS: hooksecurefunc

local MAX_STATIC_POPUPS = 4
local SPACING = (E.PixelMode and 1 or 3)

local tooltips = {
	EmbeddedItemTooltip,
	FriendsTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
}

-- Blizzard Styles
local function styleFreeBlizzardFrames()
	if E.db.benikui.general.benikuiStyle ~= true then return end

	if E.private.skins.blizzard.enable ~= true then
		return
	end

	local db = E.private.skins.blizzard

	if db.addonManager then
		AddonList:BuiStyle("Outside")
	end

	if db.bgscore then
		if WorldStateScoreFrame.backdrop then
			WorldStateScoreFrame.backdrop:BuiStyle("Outside")
		end
	end

	if db.character then
		CharacterFrame.backdrop:BuiStyle("Outside")
		ReputationDetailFrame:BuiStyle("Outside")
	end

	if db.friends then
		AddFriendEntryFrame:BuiStyle("Outside")
		FriendsFrame.backdrop:BuiStyle("Outside")
		FriendsFriendsFrame:BuiStyle("Outside")
	end

	if db.gossip then
		GossipFrame.backdrop:BuiStyle("Outside")
		ItemTextFrame.backdrop:BuiStyle("Outside")
	end

	if db.guildregistrar then
		GuildRegistrarFrame.backdrop:BuiStyle("Outside")
	end

	if db.help then
		HelpFrame.backdrop:BuiStyle("Outside")
	end

	if db.loot then
		LootFrame:BuiStyle("Outside")
		MasterLooterFrame:BuiStyle("Outside")
	end

	if db.mail then
		MailFrame.backdrop:BuiStyle("Outside")
		OpenMailFrame.backdrop:BuiStyle("Outside")
	end

	if db.merchant then
		if MerchantFrame.backdrop then
			MerchantFrame.backdrop:BuiStyle("Outside")
		end
	end

	if db.misc then
		AudioOptionsFrame:BuiStyle("Outside")
		BNToastFrame:BuiStyle("Outside")
		ChatConfigFrame:BuiStyle("Outside")
		ChatMenu:BuiStyle("Outside")
		CinematicFrameCloseDialog:BuiStyle("Outside")
		DropDownList1MenuBackdrop:BuiStyle("Outside")
		DropDownList2MenuBackdrop:BuiStyle("Outside")
		EmoteMenu:BuiStyle("Outside")
		GameMenuFrame:BuiStyle("Outside")
		InterfaceOptionsFrame:BuiStyle("Outside")
		LanguageMenu:BuiStyle("Outside")
		ReadyCheckFrame:BuiStyle("Outside")
		ReadyCheckListenerFrame:BuiStyle("Outside")
		StackSplitFrame:BuiStyle("Outside")
		StaticPopup1:BuiStyle("Outside")
		StaticPopup2:BuiStyle("Outside")
		StaticPopup3:BuiStyle("Outside")
		StaticPopup4:BuiStyle("Outside")
		TicketStatusFrameButton:BuiStyle("Outside")
		VideoOptionsFrame:BuiStyle("Outside")
		VoiceMacroMenu:BuiStyle("Outside")

		local function StylePopups()
			for i = 1, MAX_STATIC_POPUPS do
				local frame = _G['ElvUI_StaticPopup'..i]
				if frame and not frame.style then
					frame:BuiStyle("Outside")
				end
			end
		end
		C_TimerAfter(1, StylePopups)
	end

	if db.nonraid then
		RaidInfoFrame:BuiStyle("Outside")
	end

	if db.petition then
		PetitionFrame:BuiStyle("Outside")
	end

	if db.quest then
		QuestFrame.backdrop:BuiStyle("Outside")
		QuestNPCModel:BuiStyle("Outside")
		QuestLogFrame.backdrop:BuiStyle("Outside")

		if BUI.AS then
			QuestDetailScrollFrame:SetTemplate("Transparent")
			QuestProgressScrollFrame:SetTemplate("Transparent")
			QuestRewardScrollFrame:HookScript(
				"OnUpdate",
				function(self)
					self:SetTemplate("Transparent")
				end
			)
			GossipGreetingScrollFrame:SetTemplate("Transparent")
		end
	end

	if db.questtimers then
		QuestTimerFrame:BuiStyle("Outside")
	end

	if db.stable then
		PetStableFrame.backdrop:BuiStyle("Outside")
	end

	if db.spellbook then
		SpellBookFrame.backdrop:BuiStyle("Outside")
	end

	if db.tabard then
		TabardFrame:BuiStyle("Outside")
	end

	if db.taxi then
		TaxiFrame.backdrop:BuiStyle("Outside")
	end

	if db.tooltip then
		for _, frame in pairs(tooltips) do
			if frame and not frame.style then
				frame:BuiStyle("Outside")
			end
		end
	end

	if db.trade then
		TradeFrame:BuiStyle("Outside")
	end

	ColorPickerFrame:BuiStyle("Outside")
end
S:AddCallback("BenikUI_styleFreeBlizzardFrames", styleFreeBlizzardFrames)

-- SpellBook tabs
local function styleSpellbook()
	if E.private.skins.blizzard.enable ~= true or E.db.benikui.general.benikuiStyle ~= true or
		E.private.skins.blizzard.spellbook ~= true
	then
		return
	end

	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", function()
		for i = 1, MAX_SKILLLINE_TABS do
			local tab = _G["SpellBookSkillLineTab" .. i]
			if not tab.style then
				tab:BuiStyle("Inside")
				tab.style:SetFrameLevel(5)
				if tab:GetNormalTexture() then
					tab:GetNormalTexture():SetTexCoord(unpack(BUI.TexCoords))
					tab:GetNormalTexture():SetInside()
				end
			end
		end
	end)
end
S:AddCallback("BenikUI_Spellbook", styleSpellbook)

-- WorldMap
local function styleWorldMap()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true or E.global.general.smallerWorldMap ~= true then
		return
	end

	local mapFrame = _G["WorldMapFrame"]
	if not mapFrame.style then
		mapFrame:BuiStyle("Outside")
	end
end

local function styleAddons()
	-- LocationPlus
	if BUI.LP and E.db.benikuiSkins.elvuiAddons.locplus then
		local framestoskin = {
			_G["LocPlusLeftDT"],
			_G["LocPlusRightDT"],
			_G["LocationPlusPanel"],
			_G["XCoordsPanel"],
			_G["YCoordsPanel"]
		}
		for _, frame in pairs(framestoskin) do
			if frame then
				frame:BuiStyle("Outside")
			end
		end
	end

	-- Shadow & Light
	if BUI.SLE and E.db.benikuiSkins.elvuiAddons.sle then
		local sleFrames = {
			_G["SLE_BG_1"],
			_G["SLE_BG_2"],
			_G["SLE_BG_3"],
			_G["SLE_BG_4"],
			_G["SLE_RaidMarkerBar"].backdrop,
			_G["SLE_SquareMinimapButtonBar"],
			_G["SLE_LocationPanel"],
			_G["SLE_LocationPanel_X"],
			_G["SLE_LocationPanel_Y"],
			_G["SLE_LocationPanel_RightClickMenu1"],
			_G["SLE_LocationPanel_RightClickMenu2"],
			_G["InspectArmory"]
		}
		for _, frame in pairs(sleFrames) do
			if frame then
				frame:BuiStyle("Outside")
			end
		end
	end

	-- SquareMinimapButtons
	if BUI.PA and E.db.benikuiSkins.elvuiAddons.pa then
		local smbFrame = _G["SquareMinimapButtonBar"]
		if smbFrame then
			smbFrame:BuiStyle("Outside")
		end
	end

	-- ElvUI_Enhanced
	if IsAddOnLoaded("ElvUI_Enhanced") and E.db.benikuiSkins.elvuiAddons.enh then
		if _G["MinimapButtonBar"] then
			_G["MinimapButtonBar"].backdrop:BuiStyle("Outside")
		end

		if _G["RaidMarkerBar"].backdrop then
			_G["RaidMarkerBar"].backdrop:BuiStyle("Outside")
		end
	end

	-- stAddonManager
	if BUI.PA and E.db.benikuiSkins.elvuiAddons.pa then
		local stFrame = _G["stAMFrame"]
		if stFrame then
			stFrame:BuiStyle("Outside")
			stAMAddOns:SetTemplate("Transparent")
		end
	end
end

local function skinZygor()
	if not BUI.ZG or not E.db.benikuiSkins.variousSkins.zygor then
		return
	end

	local zygorFrame = _G["ZygorGuidesViewerFrame"]
	if not zygorFrame then return end

	zygorFrame:StripTextures()
	zygorFrame:CreateBackdrop("Transparent")
	zygorFrame.backdrop:BuiStyle("Outside")

	local function SkinGuideMenu()
		local frame = ZGV.GuideMenu.MainFrame
		if not frame then return end

		if not frame.isStyled then
			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:BuiStyle("Outside")
			frame.isStyled = true
		end
	end
	hooksecurefunc(ZGV.GuideMenu, "Show", SkinGuideMenu)

	local function SkinFindNearest()
		local frame = ZGV.WhoWhere.NPCFrame
		if not frame then return end

		if not frame.isStyled then
			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:BuiStyle("Outside")
			frame.isStyled = true
		end
	end
	--hooksecurefunc(ZGV.WhoWhere, "CreateMenuFrame", SkinFindNearest)

	local function SkinActionbar()
		local frame = ZGV.ActionBar.Frame
		if not frame then return end

		if not frame.isStyled then
			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:BuiStyle("Outside")
			frame.isStyled = true
		end
	end
	hooksecurefunc(ZGV.ActionBar, "ApplySkin", SkinActionbar)

	local function SkinPopup()
		local frame = ZGV.ItemScore.Upgrades.EquipPopup
		if not frame then return end

		if not frame.isStyled then
			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:BuiStyle("Outside")
			frame.isStyled = true
		end
	end
	hooksecurefunc(ZGV.PopupHandler, "ShowPopup", SkinPopup)
end

local function skinDecursive()
	if not IsAddOnLoaded("Decursive") or not E.db.benikuiSkins.variousSkins.decursive then
		return
	end

	-- Main Buttons
	_G["DecursiveMainBar"]:StripTextures()
	_G["DecursiveMainBar"]:SetTemplate("Default", true)
	_G["DecursiveMainBar"]:Height(20)

	local mainButtons = {_G["DecursiveMainBarPriority"], _G["DecursiveMainBarSkip"], _G["DecursiveMainBarHide"]}
	for i, button in pairs(mainButtons) do
		S:HandleButton(button)
		button:SetTemplate("Default", true)
		button:ClearAllPoints()
		if (i == 1) then
			button:Point("LEFT", _G["DecursiveMainBar"], "RIGHT", SPACING, 0)
		else
			button:Point("LEFT", mainButtons[i - 1], "RIGHT", SPACING, 0)
		end
	end

	-- Priority List Frame
	_G["DecursivePriorityListFrame"]:StripTextures()
	_G["DecursivePriorityListFrame"]:CreateBackdrop("Transparent")
	_G["DecursivePriorityListFrame"].backdrop:BuiStyle("Outside")

	local priorityButton = {
		_G["DecursivePriorityListFrameAdd"],
		_G["DecursivePriorityListFramePopulate"],
		_G["DecursivePriorityListFrameClear"],
		_G["DecursivePriorityListFrameClose"]
	}
	for i, button in pairs(priorityButton) do
		S:HandleButton(button)
		button:ClearAllPoints()
		if (i == 1) then
			button:Point("TOP", _G["DecursivePriorityListFrame"], "TOPLEFT", 54, -20)
		else
			button:Point("LEFT", priorityButton[i - 1], "RIGHT", SPACING, 0)
		end
	end

	_G["DecursivePopulateListFrame"]:StripTextures()
	_G["DecursivePopulateListFrame"]:CreateBackdrop("Transparent")
	_G["DecursivePopulateListFrame"].backdrop:BuiStyle("Outside")

	for i = 1, 8 do
		local groupButton = _G["DecursivePopulateListFrameGroup" .. i]
		S:HandleButton(groupButton)
	end

	local classPop = {
		"Warrior",
		"Priest",
		"Mage",
		"Warlock",
		"Hunter",
		"Rogue",
		"Druid",
		"Shaman",
		"Monk",
		"Paladin",
		"Deathknight",
		"Close"
	}
	for _, classBtn in pairs(classPop) do
		local btnName = _G["DecursivePopulateListFrame" .. classBtn]
		S:HandleButton(btnName)
	end

	-- Skip List Frame
	_G["DecursiveSkipListFrame"]:StripTextures()
	_G["DecursiveSkipListFrame"]:CreateBackdrop("Transparent")
	_G["DecursiveSkipListFrame"].backdrop:BuiStyle("Outside")

	local skipButton = {
		_G["DecursiveSkipListFrameAdd"],
		_G["DecursiveSkipListFramePopulate"],
		_G["DecursiveSkipListFrameClear"],
		_G["DecursiveSkipListFrameClose"]
	}
	for i, button in pairs(skipButton) do
		S:HandleButton(button)
		button:ClearAllPoints()
		if (i == 1) then
			button:Point("TOP", _G["DecursiveSkipListFrame"], "TOPLEFT", 54, -20)
		else
			button:Point("LEFT", skipButton[i - 1], "RIGHT", SPACING, 0)
		end
	end

	-- Tooltip
	if E.private.skins.blizzard.tooltip then
		_G["DcrDisplay_Tooltip"]:StripTextures()
		_G["DcrDisplay_Tooltip"]:CreateBackdrop("Transparent")
		_G["DcrDisplay_Tooltip"].backdrop:BuiStyle("Outside")
	end
end

local function skinStoryline()
	if not IsAddOnLoaded("Storyline") or not E.db.benikuiSkins.variousSkins.storyline then
		return
	end
	_G["Storyline_NPCFrame"]:StripTextures()
	_G["Storyline_NPCFrame"]:CreateBackdrop("Transparent")
	_G["Storyline_NPCFrame"].backdrop:BuiStyle("Outside")
	S:HandleCloseButton(_G["Storyline_NPCFrameClose"])
	_G["Storyline_NPCFrameChat"]:StripTextures()
	_G["Storyline_NPCFrameChat"]:CreateBackdrop("Transparent")
end

local function StyleDBM_Options()
	if not E.db.benikuiSkins.addonSkins.dbm or not BUI.AS then
		return
	end

	DBM_GUI_OptionsFrame:HookScript("OnShow", function()
		DBM_GUI_OptionsFrame:BuiStyle("Outside")
	end)
end

local function StyleInFlight()
	if E.db.benikuiSkins.variousSkins.inflight ~= true or E.db.benikui.misc.flightMode == true then
		return
	end

	local frame = _G["InFlightBar"]
	if frame then
		if not frame.isStyled then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:BuiStyle("Outside")
			frame.isStyled = true
		end
	end
end

local function LoadInFlight()
	local f = CreateFrame("Frame")
	f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	f:SetScript("OnEvent", function(self, event)
		if event then
			StyleInFlight()
			f:UnregisterEvent(event)
		end
	end)
end

function mod:StyleAdibagsBank()
	if not E.db.benikuiSkins.addonSkins.adibags or not BUI.AS then
		return
	end
	E:Delay(0.2, function()
		if AdiBagsContainer2 then
			AdiBagsContainer2:BuiStyle("Inside")
		end
	end)
end

local function StyleAdibags()
	if not E.db.benikuiSkins.addonSkins.adibags or not BUI.AS then
		return
	end
	E:Delay(1.1, function()
		if AdiBagsContainer1 then
			AdiBagsContainer1:BuiStyle("Outside")
		end
	end)
end

function mod:LoD_AddOns(_, addon)
	if addon == "DBM-GUI" then
		StyleDBM_Options()
	end
	if addon == "InFlight" then
		LoadInFlight()
	end
end

function mod:PLAYER_ENTERING_WORLD(...)
	--self:styleAlertFrames()
	styleAddons()
	styleWorldMap()
	--StyleAdibags()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function StyleElvUIConfig()
	if not E.private.skins.ace3Enable then return end

	local frame = E:Config_GetWindow()
	if not frame.style then
		frame:BuiStyle("Outside")
	end
end

local function StyleAceTooltip(self)
	if not self or self:IsForbidden() then return end
	if not self.style then
		self:BuiStyle('Outside')
	end
end

function mod:Initialize()
	if E.db.benikui.general.benikuiStyle ~= true then return end

	hooksecurefunc(E, "ToggleOptionsUI", StyleElvUIConfig)

	--skinDecursive()
	--skinStoryline()

	skinZygor()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ADDON_LOADED", "LoD_AddOns")
	--self:RegisterEvent("BANKFRAME_OPENED", "StyleAdibagsBank")

	if E.private.skins.blizzard.tooltip ~= true then
		return
	end
	hooksecurefunc(S, "Ace3_StyleTooltip", StyleAceTooltip)
end

BUI:RegisterModule(mod:GetName())
