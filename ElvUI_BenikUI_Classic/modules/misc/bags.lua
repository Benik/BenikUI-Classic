local BUI, E, L, V, P, G = unpack(select(2, ...))
local mod = BUI:NewModule('Bags', 'AceHook-3.0', 'AceEvent-3.0');
local B = E:GetModule('Bags')

local _G = _G
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

-- GLOBALS: hooksecurefunc

local SPACING = (E.PixelMode and 1 or 5)
local BORDER = E.Border;

function mod:StyleBags()
	if ElvUI_ContainerFrame then
		ElvUI_ContainerFrame:BuiStyle('Outside')
		ElvUI_ContainerFrameContainerHolder:BuiStyle('Outside')
	end

	if ElvUI_ContainerFrameContainerHolder then
		ElvUI_ContainerFrameContainerHolder:Point('BOTTOMLEFT', ElvUI_ContainerFrame.style, 'TOPLEFT', 0, SPACING + BORDER)
	end

	if ElvUIBags then
		ElvUIBags.backdrop:BuiStyle('Outside')
		ElvUIBags.backdrop:SetTemplate('Transparent')
	end
end

function mod:OpenBankBags()
	if ElvUI_BankContainerFrame then
		ElvUI_BankContainerFrame:BuiStyle('Outside')
		ElvUI_BankContainerFrameContainerHolder:BuiStyle('Outside')
	end

	if ElvUI_BankContainerFrameContainerHolder then
		ElvUI_BankContainerFrameContainerHolder:Point('BOTTOMLEFT', ElvUI_BankContainerFrame.style, 'TOPLEFT', 0, SPACING + BORDER)
	end
end

function mod:SkinBlizzBags()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local container = _G['ContainerFrame'..i]
		if container.backdrop then
			container.backdrop:BuiStyle('Inside')
		end
	end
	if BankFrame then
		BankFrame:BuiStyle('Outside')
	end
end

function mod:AllInOneBags()
	self:StyleBags()
	hooksecurefunc(B, "OpenBank", mod.OpenBankBags)
end

function mod:Initialize()
	if E.db.benikui.general.benikuiStyle ~= true then return end
	self:AllInOneBags()
	self:SkinBlizzBags()
	self:OpenBankBags()
end

BUI:RegisterModule(mod:GetName())