local NAME, S = ...
local VERSION = .1

-- only uses AceGUI part of the Ace3 framework
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L

local tonumber = tonumber
local select = select
local wipe = wipe
local strsub = strsub
local bit_band = bit.band

local Juke = CreateFrame("Frame")
local db
local args = {}
local guids = {}

local crop = ":64:64:4:60:4:60"
local isBattleground
local chatType

	---------------
	--- Options ---
	---------------

local defaults = {
	version = .1, -- update this on savedvars changes
	toggleinterrupt = true,
	colorinterrupt = {0, 110/255, 1},
	interrupt = L.MSG_INTERRUPT,
	togglejuke = true,
	juke = L.MSG_JUKE,
	colorjuke = {1, .5, 0},
	chat = 1,
}

local options = {
	type = "group",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	handler = Juke,
	get = "GetValue", set = "SetValue",
	args = {
		inline1 = {
			type = "group", order = 1, inline = true,
			name = " ",
			args = {
				toggleinterrupt = {
					type = "toggle", order = 1, descStyle = "",
					name = function() return " |cff"..S.dex2hex(db.colorinterrupt)..INTERRUPT.."|r" end,
				},
				colorinterrupt = {
					type = "color", order = 2, descStyle = "",
					name = " ",
					get = "GetColor", set = "SetColor",
				},
				interrupt = {
					type = "input", order = 3, width = "full",
					name = "",
					set = "SetInput",
				},
				togglejuke = {
					type = "toggle", order = 4, descStyle = "",
					name = function() return " |cff"..S.dex2hex(db.colorjuke).."Juke|r" end,
				},
				colorjuke = {
					type = "color", order = 5, descStyle = "",
					name = " ",
					get = "GetColor", set = "SetColor",
				},
				juke = {
					type = "input", order = 6, width = "full",
					name = "",
					set = "SetInput",
				},
			},
		},
		reset = {
			type = "execute", order = 3, descStyle = "",
			name = RESET,
			func = function()
				JukeDB = CopyTable(defaults)
				db = JukeDB
			end,
		},
		chat = {
			type = "select", order = 4, descStyle = "",
			name = "   |cffFFFFFF"..CHAT.." "..CHANNEL.."|r",
			values = {
				"|cffFF0000<"..NONE..">|r",
				"  "..CHAT_MSG_SAY,
				"  |cffA8A8FF"..CHAT_MSG_PARTY.."|r / |cffFF7F00"..CHAT_MSG_RAID.."|r",
			},
			set = function(i, v)
				db.chat = v
				Juke:GROUP_ROSTER_UPDATE() -- update chatType
			end,
		},
	},
}

function Juke:GetValue(i)
	return db[i[#i]]
end

function Juke:SetValue(i, v)
	db[i[#i]] = v
end

function Juke:GetColor(i)
	return unpack(db[i[#i]])
end

function Juke:SetColor(i, r, g, b)
	local c = db[i[#i]]
	c[1] = r
	c[2] = g
	c[3] = b
end

function Juke:SetInput(i, v)
	db[i[#i]] = (v:trim() == "") and defaults[i[#i]] or v
end

	----------------------
	--- Initialization ---
	----------------------

function Juke:OnEvent(event, ...)
	self[event](self, event, ...)
end

Juke:RegisterEvent("ADDON_LOADED")
Juke:SetScript("OnEvent", Juke.OnEvent)

function Juke:ADDON_LOADED(event, addon)
	if addon ~= NAME then return end
	
	if not JukeDB or JukeDB.version ~= defaults.version then
		JukeDB = CopyTable(defaults)
	end
	db = JukeDB
	
	ACR:RegisterOptionsTable("Juke", options)
	ACD:AddToBlizOptions("Juke", NAME)
	ACD:SetDefaultSize("Juke", 420, 290)
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent(event)
	-- initialize in case of /reload
	self:GROUP_ROSTER_UPDATE()
	self:ZONE_CHANGED_NEW_AREA()
end

	---------------------
	--- Slash Command ---
	---------------------

SLASH_JUKE1 = "/juke"

SlashCmdList.JUKE = function(msg, editbox)
	ACD:Open("Juke")
end

	-------------
	--- Cache ---
	-------------

local GetPlayerClass = setmetatable({}, {__index = function(t, k)
	local _, v = GetPlayerInfoByGUID(k)
	rawset(t, k, v)
	return v or "PRIEST" -- fallback
end})

local GetSpellIcon = setmetatable({}, {__index = function(t, k)
	local v = select(3, GetSpellInfo(k))
	rawset(t, k, v)
	return v
end})

local _GetSpellLink = setmetatable({}, {__index = function(t, k)
	local v = GetSpellLink(k)
	rawset(t, k, v)
	return v
end})

	------------------
	--- Processing ---
	------------------

local function _GetSpellInfo(spellID, spellName, spellSchool)
	-- fallback to default spell color for combined magic schools
	local spellLinkLocal = format(" |cff%s"..TEXT_MODE_A_STRING_SPELL.."|r", S.SchoolColor[spellSchool] or "71D5FF", spellID, "", spellName)
	local spellIcon = format("|T%s:16:16:0:0%s|t", GetSpellIcon[spellID], crop)
	return spellLinkLocal..spellIcon, _GetSpellLink[spellID]
end

local function UnitReaction(flags)
	if bit_band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 then
		return "Friendly"
	elseif bit_band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
		return "Hostile"
	else
		return "Unknown"
	end
end

local function UnitIcon(unitFlags, reaction)
	local raidTarget = bit_band(unitFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
	if raidTarget == 0 then return "", "" end
	
	local i = S.COMBATLOG_OBJECT_RAIDTARGET[raidTarget]
	local icon = _G["COMBATLOG_ICON_RAIDTARGET"..i]
	local iconString = format(S.STRING_REACTION_ICON[reaction], raidTarget, icon)
	local chat = "{"..strlower(_G["RAID_TARGET_"..i]).."}"
	return iconString, chat
end

local function ClassColor(sourceGUID)
	return (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[GetPlayerClass[sourceGUID]].colorStr
end

	------------
	--- Args ---
	------------

local function SetEventMessage(msgtype)
	args.msg = db[msgtype]
	args.color = db["color"..msgtype]
end

-- only append x for these chatargs
local ChatArgs = {
	src = true,
	dest = true,
	spell = true,
	xspell = true,
}

local function ReplaceArgs(args, isChat)
	local msg = args.msg
	for k in gmatch(msg, "%b<>") do
		-- remove <>, make case insensitive
		local s = strlower(gsub(k, "[<>]", ""))
		-- escape special characters
		s = gsub(args[isChat and ChatArgs[s] and s.."x" or s] or "", "(%p)", "%%%1")
		k = gsub(k, "(%p)", "%%%1")
		msg = msg:gsub(k, s)
	end
	msg = msg:gsub("  ", " ") -- remove double whitespaces
	return msg
end

	-------------
	--- Event ---
	-------------

function Juke:GROUP_ROSTER_UPDATE(event)
	local c = db.chat
	
	if c == 2 then
		chatType = "SAY"
	elseif c == 3 then
		local isInstanceChat = IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
		chatType = isInstanceChat and "INSTANCE_CHAT" or IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	end
end

-- dont output to battleground chat
function Juke:ZONE_CHANGED_NEW_AREA(event)
	local _, instanceType = IsInInstance()
	isBattleground = (instanceType == "pvp")
end

	------------
	--- CLEU ---
	------------

function Juke:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	
	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, SuffixParam1, SuffixParam2, SuffixParam3 = ...
	
	local sourceType = tonumber(strsub(sourceGUID, 5, 5))
	local destType = tonumber(strsub(destGUID, 5, 5))
	local sourcePlayer = sourceType and (bit_band(sourceType, 0x7) == 0)
	local destPlayer = destType and (bit_band(destType, 0x7) == 0)
	if not sourcePlayer then return end -- only show jukes/interrupts done by players
	
	wipe(args)
	
	------------
	--- Miss ---
	------------
	
	if subevent == "SPELL_CAST_SUCCESS" then
		if S.InterruptID[spellID] and db.togglejuke then
			guids[sourceGUID] = true -- casted interrupt
			-- trying to save a vararg; am I doing this right? :x
			local varg, n = {...}, select("#", ...)
			varg[2] = "SPELL_INTERRUPT_WASTED"
			S.Timer(function()
				if guids[sourceGUID] then -- wasted interrupt
					-- need to fire another event since we are now delayed
					self:COMBAT_LOG_EVENT_UNFILTERED(event, unpack(varg, 1, n))
				end
				guids[sourceGUID] = false
			end, .5) -- wait for SPELL_INTERRUPT delay/lag
		end
	
	elseif subevent == "SPELL_MISSED" then
		-- check if the interrupt missed, instead of being wasted
		if S.InterruptID[spellID] then
			guids[sourceGUID] = false -- missed interrupt
		end
	
	elseif subevent == "SPELL_INTERRUPT" then
		args.xspell, args.xspellx = _GetSpellInfo(SuffixParam1, SuffixParam2, SuffixParam3)
		
		if db.toggleinterrupt then
			SetEventMessage("interrupt")
		end
		if S.InterruptID[spellID] then
			guids[sourceGUID] = false -- succesful interrupt
		end
	
	elseif subevent == "SPELL_INTERRUPT_WASTED" then
		SetEventMessage("juke")
	end
	
	---------------
	--- Message ---
	---------------
	
	-- check if there is any message
	if args.msg then
		
	------------
	--- Unit ---
	------------
		
		if sourceName then -- if no unit, then guid is an empty string and name is nil
			-- trim out (CRZ) realm name; only do this for players
			local name = sourcePlayer and strmatch(sourceName, "([^%-]+)%-?.*") or sourceName
			local fname = (sourceGUID == S.player.guid) and UNIT_YOU_SOURCE or name
			local sourceIconLocal, sourceIconChat = UnitIcon(sourceRaidFlags, 1)
			local sourceReaction = UnitReaction(sourceFlags)
			local color = (sourceReaction == "Friendly") and ClassColor(sourceGUID) or S.ReactionColor[sourceReaction]
			
			args.src = format("|c%s"..TEXT_MODE_A_STRING_SOURCE_UNIT.."|r", color, sourceIconLocal, sourceGUID, sourceName, fname)
			args.srcx = format("%s[%s]", sourceIconChat, name)
		end
		
		if destName then
			local name = destPlayer and strmatch(destName, "([^%-]+)%-?.*") or destName
			local fname = (destGUID == S.player.guid) and UNIT_YOU_DEST or name
			local destIconLocal, destIconChat = UnitIcon(destRaidFlags, 2)
			local destReaction = UnitReaction(destFlags)
			local color = (destReaction == "Friendly") and ClassColor(destGUID) or S.ReactionColor[destReaction] 
			
			args.dest = format("|c%s"..TEXT_MODE_A_STRING_DEST_UNIT.."|r", color, destIconLocal, destGUID, destName, fname)
			args.destx = format("%s[%s]", destIconChat, name)
		end
		
		args.spell, args.spellx = _GetSpellInfo(spellID, spellName, spellSchool)
		
	--------------
	--- Output ---
	--------------
		
		ChatFrame1:AddMessage(ReplaceArgs(args), unpack(args.color))
		
		-- dont default to "SAY" if chatType is nil
		if db.chat > 1 and chatType then
			-- avoid ERR_CHAT_WHILE_DEAD
			-- dont ever spam the battleground group
			local iseedeadpeople = UnitIsDeadOrGhost("player") and S.Talk[chatType]
			if iseedeadpeople or isBattleground then return end
			SendChatMessage(ReplaceArgs(args, true), chatType)
		end
	end
end

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "launcher",
	text = NAME,
	icon = "Interface\\Icons\\Spell_Frost_IceShock",
	OnClick = function(clickedframe, button)
		ACD[ACD.OpenFrames.Juke and "Close" or "Open"](ACD, "Juke")
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddLine(L.BROKER_CLICK)
	end,
}

LibStub("LibDataBroker-1.1"):NewDataObject("Juke", dataobject)
