-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2014.06.17					---
--- Version: 0.1 [2014.06.17]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/juke
--- WoWInterface	...

local NAME, S = ...
S.VERSION = GetAddOnMetadata(NAME, "Version")
S.BUILD = "Release"

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

S.EventColor = {
	interrupt = {0, 110/255, 1},
	juke = {1, .5, 0},
}

S.ReactionColor = {
	Friendly = "FF57A3FF",
	Hostile = "FFBF0D0D",
	Unknown = "FFBFBFBF",
}

S.Talk = {
	SAY = true,
	YELL = true,
}

	-------------
	--- Timer ---
	-------------

-- behold KethoTimer, its not fueled on animations but it works x)
-- I think vs AceTimer this is better in the case of single OnUpdates
local timers = {}

local function GetTimer() -- allocate timers
	local i = 1
	while timers[i] and timers[i].running do
		i = i + 1
	end
	-- if a timer isnt running return that, otherwise return a new one
	if not timers[i] then
		timers[i] = CreateFrame("Frame")
	end
	return timers[i]
end

function S.Timer(func, delay)
	local t = GetTimer()
	t.running = true
	local sum = 0
	t:SetScript("OnUpdate", function(self, e)
		sum = sum + e
		if sum > delay then
			self:SetScript("OnUpdate", nil)
			self.running = false
			func()
		end
	end)
end

	--------------
	--- Player ---
	--------------

local player = {
	name = UnitName("player"),
}
S.player = player

-- guid not readily available at first startup
S.Timer(function() S.player.guid = UnitGUID("player") end, 0)

function S.dex2hex(color)
	return format("%02X%02X%02X", color[1]*255, color[2]*255, color[3]*255)
end
