-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2014.06.17					---
--- Version: 0.5 [2014.11.08]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/juke
--- WoWInterface	http://www.wowinterface.com/downloads/info22890-Juke.html

local NAME, S = ...
S.VERSION = GetAddOnMetadata(NAME, "Version")
S.BUILD = "Release"

local pairs = pairs

	------------
	--- Data ---
	------------

-- actually used only for jukes
S.InterruptID = {
	[1766] = true, -- Rogue: [Kick]
	[2139] = true, -- Mage: [Counterspell]
	[6552] = true, -- Warrior: [Pummel]
	--[15487] = true, -- Priest: [Silence]
	[47528] = true, -- Death Knight: [Mind Freeze]
	--[47476] = true, -- Death Knight: [Strangulate]
	[147362] = true, -- Hunter: [Counter Shot]
	--[34490] = true, -- Hunter: [Silencing Shot]
	[57994] = true, -- Shaman: [Wind Shear]
	[96231] = true, -- Paladin: [Rebuke]
	[116705] = true, -- Monk: [Spear Hand Strike] (silence)
-- Druid
	[80964] = true, -- [Skull Bash] (Bear); pre-interrupt
	[80965] = true, -- [Skull Bash] (Cat); pre-interrupt
	[93985] = true, -- [Skull Bash; Interrupt
	--[78675] = true, -- [Solar Beam]
}

S.SchoolColor = {
	[0x1] = "FFFF00", -- Physical
	[0x2] = "FFE680", -- Holy
	[0x4] = "FF8000", -- Fire
	[0x8] = "4DFF4D", -- Nature
	[0x10] = "80FFFF", -- Frost
	[0x20] = "8080FF", -- Shadow
	[0x40] = "FF80FF", -- Arcane
}

-- leading FF since its used in the same place as RAID_CLASS_COLORS[class].colorStr
S.ReactionColor = {
	Friendly = "FF57A3FF",
	Hostile = "FFBF0D0D",
	Unknown = "FFBFBFBF",
}

S.STRING_REACTION_ICON = {
	TEXT_MODE_A_STRING_SOURCE_ICON,
	TEXT_MODE_A_STRING_DEST_ICON,
}

S.COMBATLOG_OBJECT_RAIDTARGET = {}
for i = 1, 8 do
	S.COMBATLOG_OBJECT_RAIDTARGET[_G["COMBATLOG_OBJECT_RAIDTARGET"..i]] = i
end

S.Talk = {
	SAY = true,
	YELL = true,
}

	-------------
	--- Timer ---
	-------------

-- screw AceTimer :D
-- borrowed/modified code from Phanx
local timers = {}
S.Timer = CreateFrame("Frame")
S.Timer:Hide()

function S.Timer:New(func, delay)
	timers[func] = delay -- add timer
	self:Show()
end

S.Timer:SetScript("OnUpdate", function(self, elapsed)
	local stop = true
	for func, delay in pairs(timers) do
		timers[func] = delay - elapsed
		stop = false
		if timers[func] < 0 then
			timers[func] = nil -- remove timer
			func()
		end
	end
	if stop then -- all timers finished
		self:Hide()
	end
end)

	--------------
	--- Player ---
	--------------

S.player = {}
-- guid not readily available at first startup
S.Timer:New(function() S.player.guid = UnitGUID("player") end, 0)

function S.dec2hex(color)
	return format("%02X%02X%02X", color[1]*255, color[2]*255, color[3]*255)
end
