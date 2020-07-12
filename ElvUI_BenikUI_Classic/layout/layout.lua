local BUI, E, L, V, P, G = unpack(select(2, ...))
local mod = BUI:NewModule('Layout', 'AceHook-3.0', 'AceEvent-3.0');
local LO = E:GetModule('Layout');
local DT = E:GetModule('DataTexts')
local M = E:GetModule('Minimap');
local LSM = E.LSM

local _G = _G
local unpack = unpack
local tinsert = table.insert
local CreateFrame = CreateFrame
local GameTooltip = _G["GameTooltip"]
local PlaySound = PlaySound
local UIFrameFadeIn, UIFrameFadeOut = UIFrameFadeIn, UIFrameFadeOut
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local GameMenuButtonAddons = GameMenuButtonAddons
local SendChatMessage = SendChatMessage
local ReloadUI = ReloadUI

-- GLOBALS: hooksecurefunc, selectioncolor
-- GLOBALS: AddOnSkins, MAINMENU_BUTTON, LFG_TITLE, BuiLeftChatDTPanel
-- GLOBALS: BuiMiddleDTPanel, BuiRightChatDTPanel, BuiGameClickMenu
-- GLOBALS: EncounterJournal_LoadUI, EncounterJournal
-- GLOBALS: MinimapPanel, Minimap
-- GLOBALS: LeftChatPanel, RightChatPanel, CopyChatFrame

local PANEL_HEIGHT = 19;
local SPACING = (E.PixelMode and 1 or 3)
local BUTTON_NUM = 4

local Bui_dchat = CreateFrame('Frame', 'BuiDummyChat', E.UIParent)
local Bui_deb = CreateFrame('Frame', 'BuiDummyEditBoxHolder', E.UIParent)

-- GameMenu
local GameMenuFrame = CreateFrame('Frame', 'BuiGameClickMenu', E.UIParent)
GameMenuFrame:SetTemplate('Transparent', true)

function BuiGameMenu_OnMouseUp(self)
	GameTooltip:Hide()
	BUI:Dropmenu(BUI.MenuList, GameMenuFrame, self:GetName(), 'tLeft', -SPACING, SPACING, 4)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

-- StatusMenu
local StatusList = {
	{text = L["AFK"], func = function() SendChatMessage("" ,"AFK" ) end},
	{text = L["DND"], func = function() SendChatMessage("" ,"DND" ) end},
	{text = L["Reload (ShiftClick)"], func = function() if IsShiftKeyDown() then ReloadUI() end end},
}

local StatusMenuFrame = CreateFrame('Frame', 'BuiStatusMenu', E.UIParent)
StatusMenuFrame:SetTemplate('Transparent', true)

function BuiStatusMenu_OnMouseUp(self)
	GameTooltip:Hide()
	BUI:Dropmenu(StatusList, StatusMenuFrame, self:GetName(), 'tRight', SPACING, SPACING, 4)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

local function ChatButton_OnClick(self)
	_G.GameTooltip:Hide()

	if E.db[self.parent:GetName()..'Faded'] then
		E.db[self.parent:GetName()..'Faded'] = nil
		E:UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		if BUI.AS then
			local AS = unpack(AddOnSkins) or nil
			if AS.db.EmbedSystem or AS.db.EmbedSystemDual then AS:Embed_Show() end
		end
	else
		E.db[self.parent:GetName()..'Faded'] = true
		E:UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

local bbuttons = {}

function mod:ToggleBuiDts()
	local db = E.db.benikui.datatexts.chat
	local edb = E.db.datatexts

	if edb.leftChatPanel or edb.rightChatPanel then
		db.enable = false
		BuiLeftChatDTPanel:Hide()
		BuiRightChatDTPanel:Hide()
	end

	if db.enable then
		if db.showChatDt == 'SHOWBOTH' then
			BuiLeftChatDTPanel:Show()
			BuiRightChatDTPanel:Show()
		elseif db.showChatDt == 'LEFT' then
			if not edb.leftChatPanel then
				BuiLeftChatDTPanel:Show()
			end
			BuiRightChatDTPanel:Hide()
		elseif db.showChatDt == 'RIGHT' then
			BuiLeftChatDTPanel:Hide()
			if not edb.rightChatPanel then
				BuiRightChatDTPanel:Show()
			end
		end
	else
		BuiLeftChatDTPanel:Hide()
		BuiRightChatDTPanel:Hide()
	end
end

function mod:ResizeMinimapPanels()
	MinimapPanel:Point('TOPLEFT', Minimap.backdrop, 'BOTTOMLEFT', 0, -SPACING)
	MinimapPanel:Point('BOTTOMRIGHT', Minimap.backdrop, 'BOTTOMRIGHT', -SPACING, -(SPACING + PANEL_HEIGHT))
end

function mod:ToggleTransparency()
	local db = E.db.benikui.datatexts.chat
	local Bui_ldtp = _G.BuiLeftChatDTPanel
	local Bui_rdtp = _G.BuiRightChatDTPanel

	if not db.backdrop then
		Bui_ldtp:SetTemplate('NoBackdrop')
		Bui_rdtp:SetTemplate('NoBackdrop')
		for i = 1, BUTTON_NUM do
			bbuttons[i]:SetTemplate('NoBackdrop')
			if BUI.ShadowMode then
				bbuttons[i].shadow:Hide()
			end
		end
		if BUI.ShadowMode then
			Bui_ldtp.shadow:Hide()
			Bui_rdtp.shadow:Hide()
		end
	else
		if db.transparent then
			Bui_ldtp:SetTemplate('Transparent')
			Bui_rdtp:SetTemplate('Transparent')	
			for i = 1, BUTTON_NUM do
				bbuttons[i]:SetTemplate('Transparent')
			end
		else
			Bui_ldtp:SetTemplate('Default', true)
			Bui_rdtp:SetTemplate('Default', true)
			for i = 1, BUTTON_NUM do
				bbuttons[i]:SetTemplate('Default', true)
			end
		end
		if BUI.ShadowMode then
			Bui_ldtp.shadow:Show()
			Bui_rdtp.shadow:Show()
			for i = 1, BUTTON_NUM do
				bbuttons[i].shadow:Show()
			end
		end
	end
end

function mod:MiddleDatatextLayout()
	local db = E.db.benikui.datatexts.middle
	local Bui_mdtp = _G.BuiMiddleDTPanel

	if db.enable then
		Bui_mdtp:Show()
	else
		Bui_mdtp:Hide()
	end

	if not db.backdrop then
		Bui_mdtp:SetTemplate('NoBackdrop')
		if BUI.ShadowMode then
			Bui_mdtp.shadow:Hide()
		end
	else
		if db.transparent then
			Bui_mdtp:SetTemplate('Transparent')
		else
			Bui_mdtp:SetTemplate('Default', true)
		end
		if BUI.ShadowMode then
			Bui_mdtp.shadow:Show()
		end
	end

	if Bui_mdtp.style then 
		if db.styled and db.backdrop then
			Bui_mdtp.style:Show()
		else
			Bui_mdtp.style:Hide()
		end
	end
end

function mod:ChatStyles()
	if not E.db.benikui.general.benikuiStyle then return end
	local Bui_ldtp = _G.BuiLeftChatDTPanel
	local Bui_rdtp = _G.BuiRightChatDTPanel

	if E.db.benikui.datatexts.chat.styled and E.db.chat.panelBackdrop == 'HIDEBOTH' then
		Bui_rdtp.style:Show()
		Bui_ldtp.style:Show()
		for i = 1, BUTTON_NUM do
			bbuttons[i].style:Show()
		end
	else
		Bui_rdtp.style:Hide()
		Bui_ldtp.style:Hide()
		for i = 1, BUTTON_NUM do
			bbuttons[i].style:Hide()
		end
	end
end

function mod:MiddleDatatextDimensions()
	local db = E.db.benikui.datatexts.middle
	local Bui_mdtp = _G.BuiMiddleDTPanel

	Bui_mdtp:Width(db.width)
	Bui_mdtp:Height(db.height)
	DT:UpdatePanelInfo('BuiMiddleDTPanel')
end

function mod:PositionEditBoxHolder(bar)
	Bui_deb:ClearAllPoints()
	Bui_deb:Point('TOPLEFT', bar.backdrop, 'BOTTOMLEFT', 0, -SPACING)
	Bui_deb:Point('BOTTOMRIGHT', bar.backdrop, 'BOTTOMRIGHT', 0, -(PANEL_HEIGHT + 6))
end

local function updateButtonFont()
	for i = 1, BUTTON_NUM do
		if bbuttons[i].text then
			bbuttons[i].text:SetFont(LSM:Fetch('font', E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
			bbuttons[i].text:SetTextColor(BUI:unpackColor(E.db.general.valuecolor))
		end
	end
end

local function Panel_OnShow(self)
	self:SetFrameLevel(0)
end

function mod:ChangeLayout()
	local db = E.db.benikui.datatexts

	-- Left dt panel
	local Bui_ldtp = CreateFrame('Frame', 'BuiLeftChatDTPanel', E.UIParent)
	Bui_ldtp:SetTemplate('Default', true)
	Bui_ldtp:SetFrameStrata('BACKGROUND')
	Bui_ldtp:Point('TOPLEFT', LeftChatPanel, 'BOTTOMLEFT', (SPACING +PANEL_HEIGHT), -SPACING)
	Bui_ldtp:Point('BOTTOMRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -(SPACING +PANEL_HEIGHT), -PANEL_HEIGHT -SPACING)
	Bui_ldtp:Style('Outside', nil, false, true)
	DT:RegisterPanel(BuiLeftChatDTPanel, 3, 'ANCHOR_BOTTOM', 0, -4)

	-- Right dt panel
	local Bui_rdtp = CreateFrame('Frame', 'BuiRightChatDTPanel', E.UIParent)
	Bui_rdtp:SetTemplate('Default', true)
	Bui_rdtp:SetFrameStrata('BACKGROUND')
	Bui_rdtp:Point('TOPLEFT', RightChatPanel, 'BOTTOMLEFT', (SPACING +PANEL_HEIGHT), -SPACING)
	Bui_rdtp:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(SPACING +PANEL_HEIGHT), -PANEL_HEIGHT -SPACING)
	Bui_rdtp:Style('Outside', nil, false, true)
	DT:RegisterPanel(BuiRightChatDTPanel, 3, 'ANCHOR_BOTTOM', 0, -4)

	-- Middle dt panel
	local Bui_mdtp = CreateFrame('Frame', 'BuiMiddleDTPanel', E.UIParent)
	Bui_mdtp:SetTemplate('Default', true)
	Bui_mdtp:SetFrameStrata('BACKGROUND')
	Bui_mdtp:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 2)
	Bui_mdtp:Width(db.middle.width or 400)
	Bui_mdtp:Height(db.middle.height or PANEL_HEIGHT)
	Bui_mdtp:Style('Outside', nil, false, true)
	DT:RegisterPanel(BuiMiddleDTPanel, 3, 'ANCHOR_BOTTOM', 0, -4)

	E:CreateMover(Bui_mdtp, "BuiMiddleDtMover", L['BenikUI Middle DataText'], nil, nil, nil, 'ALL,BenikUI', nil, 'benikui,datatexts')

	-- dummy frame for chat (left)
	Bui_dchat:SetFrameStrata('LOW')
	Bui_dchat:Point('TOPLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, -SPACING)
	Bui_dchat:Point('BOTTOMRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, -PANEL_HEIGHT -SPACING)

	-- Buttons
	for i = 1, BUTTON_NUM do
		bbuttons[i] = CreateFrame('Button', 'BuiButton_'..i, E.UIParent)
		bbuttons[i]:RegisterForClicks('AnyUp')
		bbuttons[i]:SetFrameStrata('BACKGROUND')
		bbuttons[i]:CreateSoftGlow()
		bbuttons[i].sglow:Hide()
		bbuttons[i]:Style('Outside', nil, false, true)
		bbuttons[i].text = bbuttons[i]:CreateFontString(nil, 'OVERLAY')
		bbuttons[i].text:FontTemplate(LSM:Fetch('font', E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
		bbuttons[i].text:SetPoint('CENTER', 1, 0)
		bbuttons[i].text:SetJustifyH('CENTER')
		bbuttons[i].text:SetTextColor(BUI:unpackColor(E.db.general.valuecolor))
		bbuttons[i].arrow = bbuttons[i]:CreateTexture(nil, 'OVERLAY')
		bbuttons[i].arrow:SetTexture(E.Media.Textures.ArrowUp)
		bbuttons[i].arrow:ClearAllPoints()
		bbuttons[i].arrow:Point('CENTER')
		bbuttons[i].arrow:Size(12)
		bbuttons[i].arrow:SetVertexColor(BUI:unpackColor(E.db.general.valuecolor))
		bbuttons[i].arrow:Hide()

		if (i == 1 or i == 3) then
			bbuttons[i]:RegisterEvent('MODIFIER_STATE_CHANGED')
		end

		-- ElvUI Config
		if i == 1 then
			bbuttons[i]:Point('TOPLEFT', Bui_rdtp, 'TOPRIGHT', SPACING, 0)
			bbuttons[i]:Point('BOTTOMRIGHT', Bui_rdtp, 'BOTTOMRIGHT', PANEL_HEIGHT + SPACING, 0)
			bbuttons[i]:SetParent(Bui_rdtp)
			bbuttons[i].text:SetText('C')
			bbuttons[i].arrow:SetRotation(E.Skins.ArrowRotation.right)
			bbuttons[i].parent = _G.RightChatPanel

			bbuttons[i]:SetScript('OnEnter', function(self)
				GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2 )
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['LeftClick: Toggle Configuration'], 0.7, 0.7, 1)
				if BUI.AS then
					GameTooltip:AddLine(L['RightClick: Toggle Embedded Addon'], 0.7, 0.7, 1)
				end
				GameTooltip:AddLine(L['ShiftClick to toggle chat'], 0.7, 0.7, 1)

				if not E.db.benikui.datatexts.chat.styled then
					self.sglow:Show()
				end

				if IsShiftKeyDown() then
					self.text:SetText('')
					self.arrow:Show()
					self:SetScript('OnClick', ChatButton_OnClick)
				else
					self.arrow:Hide()
					self.text:SetText('C')
					self:SetScript('OnClick', function(self, btn)
						if btn == 'LeftButton' then
							E:ToggleOptionsUI()
						else
							if BUI.AS then
								local AS = unpack(AddOnSkins) or nil
								if AS:CheckOption('EmbedRightChat') and EmbedSystem_MainWindow then
									if EmbedSystem_MainWindow:IsShown() then
										AS:SetOption('EmbedIsHidden', true)
										EmbedSystem_MainWindow:Hide()
									else
										AS:SetOption('EmbedIsHidden', false)
										EmbedSystem_MainWindow:Show()
									end
								end
							else
								E:BGStats()
							end
						end
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
					end)
				end

				GameTooltip:Show()
				if InCombatLockdown() then GameTooltip:Hide() end
			end)

			bbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('C')
				self.sglow:Hide()
				GameTooltip:Hide()
			end)

		-- Game menu button
		elseif i == 2 then
			bbuttons[i]:Point('TOPRIGHT', Bui_rdtp, 'TOPLEFT', -SPACING, 0)
			bbuttons[i]:Point('BOTTOMLEFT', Bui_rdtp, 'BOTTOMLEFT', -(PANEL_HEIGHT + SPACING), 0)
			bbuttons[i]:SetParent(Bui_rdtp)
			bbuttons[i].text:SetText('G')

			bbuttons[i]:SetScript('OnClick', BuiGameMenu_OnMouseUp)

			bbuttons[i]:SetScript('OnEnter', function(self)
				if not E.db.benikui.datatexts.chat.styled then
					self.sglow:Show()
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2 )
				GameTooltip:ClearLines()
				GameTooltip:AddLine(MAINMENU_BUTTON, selectioncolor)
				GameTooltip:Show()
				if InCombatLockdown() then GameTooltip:Hide() end
			end)

			bbuttons[i]:SetScript('OnLeave', function(self)
				self.sglow:Hide()
				GameTooltip:Hide()
			end)

		-- AddOns Button
		elseif i == 3 then
			bbuttons[i]:Point('TOPRIGHT', Bui_ldtp, 'TOPLEFT', -SPACING, 0)
			bbuttons[i]:Point('BOTTOMLEFT', Bui_ldtp, 'BOTTOMLEFT', -(PANEL_HEIGHT + SPACING), 0)
			bbuttons[i]:SetParent(Bui_ldtp)
			bbuttons[i].text:SetText('A')
			bbuttons[i].arrow:SetRotation(E.Skins.ArrowRotation.left)
			bbuttons[i].parent = _G.LeftChatPanel

			bbuttons[i]:SetScript('OnEnter', function(self)
				if not E.db.benikui.datatexts.chat.styled then
					self.sglow:Show()
				end
				if IsShiftKeyDown() then
					self.arrow:Show()
					self.text:SetText('')
					self:SetScript('OnClick', ChatButton_OnClick)
				else
					self:SetScript('OnClick', function(self)
						GameMenuButtonAddons:Click()
					end)
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOP', 64, 2 )
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Click to show the Addon List'], 0.7, 0.7, 1)
				GameTooltip:AddLine(L['ShiftClick to toggle chat'], 0.7, 0.7, 1)
				GameTooltip:Show()
				if InCombatLockdown() then GameTooltip:Hide() end
			end)

			bbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('A')
				self.arrow:Hide()
				self.sglow:Hide()
				GameTooltip:Hide()
			end)

		-- Status Button
		elseif i == 4 then
			bbuttons[i]:Point('TOPLEFT', Bui_ldtp, 'TOPRIGHT', SPACING, 0)
			bbuttons[i]:Point('BOTTOMRIGHT', Bui_ldtp, 'BOTTOMRIGHT', PANEL_HEIGHT + SPACING, 0)
			bbuttons[i]:SetParent(Bui_ldtp)
			bbuttons[i].text:SetText('S')

			bbuttons[i]:SetScript('OnClick', BuiStatusMenu_OnMouseUp)
			
			bbuttons[i]:SetScript('OnEnter', function(self)
				if not E.db.benikui.datatexts.chat.styled then
					self.sglow:Show()
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 2)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Set Player Status or Reload'])
				GameTooltip:Show()
				if InCombatLockdown() then GameTooltip:Hide() end
			end)

			bbuttons[i]:SetScript('OnLeave', function(self)
				self.sglow:Hide()
				GameTooltip:Hide()
			end)
		end
	end
	
	MinimapPanel:Height(PANEL_HEIGHT)
	ElvUI_BottomPanel:SetScript('OnShow', Panel_OnShow)
	ElvUI_BottomPanel:SetFrameLevel(0)
	ElvUI_TopPanel:SetScript('OnShow', Panel_OnShow)
	ElvUI_TopPanel:SetFrameLevel(0)

	LeftChatPanel.backdrop:Style('Outside', 'LeftChatPanel_Bui') -- keeping the names. Maybe use them as rep or xp bars... dunno... yet
	RightChatPanel.backdrop:Style('Outside', 'RightChatPanel_Bui')

	if BUI.ShadowMode then
		MinimapPanel:CreateSoftShadow()
		LeftChatDataPanel:CreateSoftShadow()
		LeftChatToggleButton:CreateSoftShadow()
		RightChatDataPanel:CreateSoftShadow()
		RightChatToggleButton:CreateSoftShadow()
	end

	-- Minimap elements styling
	if E.private.general.minimap.enable then Minimap.backdrop:Style('Outside') end

	if CopyChatFrame then CopyChatFrame:Style('Outside') end

	self:ResizeMinimapPanels()
	self:ToggleTransparency()
end

-- Add minimap styling option in ElvUI minimap options
local function InjectMinimapOption()
	E.Options.args.maps.args.minimap.args.generalGroup.args.benikuiStyle = {
		order = 3,
		type = "toggle",
		name = BUI:cOption(L['BenikUI Style']),
		disabled = function() return not E.private.general.minimap.enable or not E.db.benikui.general.benikuiStyle end,
		get = function(info) return E.db.general.minimap.benikuiStyle end,
		set = function(info, value) E.db.general.minimap.benikuiStyle = value; mod:ToggleMinimapStyle(); end,
	}
end
tinsert(BUI.Config, InjectMinimapOption)

function mod:ToggleMinimapStyle()
	if E.private.general.minimap.enable ~= true or E.db.benikui.general.benikuiStyle ~= true then return end
	if E.db.general.minimap.benikuiStyle then
		Minimap.backdrop.style:Show()
	else
		Minimap.backdrop.style:Hide()
	end
end

function mod:regEvents()
	self:MiddleDatatextLayout()
	self:MiddleDatatextDimensions()
	self:ToggleTransparency()
end

function mod:PLAYER_ENTERING_WORLD(...)
	self:ToggleBuiDts()
	self:regEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function InjectDatatextOptions()
	E.Options.args.datatexts.args.panels.args.BuiLeftChatDTPanel.name = BUI.Title..BUI:cOption(L['Left Chat Panel'])
	E.Options.args.datatexts.args.panels.args.BuiLeftChatDTPanel.order = 1001

	E.Options.args.datatexts.args.panels.args.BuiRightChatDTPanel.name = BUI.Title..BUI:cOption(L['Right Chat Panel'])
	E.Options.args.datatexts.args.panels.args.BuiRightChatDTPanel.order = 1002

	E.Options.args.datatexts.args.panels.args.BuiMiddleDTPanel.name = BUI.Title..BUI:cOption(L['Middle Panel'])
	E.Options.args.datatexts.args.panels.args.BuiMiddleDTPanel.order = 1003
end

function mod:Initialize()
	self:ChangeLayout()
	self:ChatStyles()
	self:ToggleMinimapStyle()
	tinsert(BUI.Config, InjectDatatextOptions)
	
	hooksecurefunc(LO, 'ToggleChatPanels', mod.ToggleBuiDts)
	hooksecurefunc(LO, 'ToggleChatPanels', mod.ResizeMinimapPanels)
	hooksecurefunc(LO, 'ToggleChatPanels', mod.ChatStyles)
	hooksecurefunc(M, 'UpdateSettings', mod.ResizeMinimapPanels)
	hooksecurefunc(DT, 'UpdatePanelInfo', mod.MiddleDatatextLayout)
	hooksecurefunc(DT, 'UpdatePanelInfo', mod.ToggleTransparency)
	hooksecurefunc(DT, 'LoadDataTexts', updateButtonFont)
	hooksecurefunc(E, 'UpdateMedia', updateButtonFont)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

BUI:RegisterModule(mod:GetName())