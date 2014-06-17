local _, S = ...

local L = {
	enUS = {
		MSG_INTERRUPT = "<SRC><SPELL> "..ACTION_SPELL_INTERRUPT.." <DEST><XSPELL>",
		MSG_JUKE = "<SRC> juked <SPELL> on <DEST>",
		BROKER_CLICK = "|cffFFFFFFClick|r to open the options menu",
	},
	deDE = {
		MSG_INTERRUPT = "<SRC><SPELL> unterbrach <DEST><XSPELL>", -- Needs review
		MSG_JUKE = "<SRC> verschwendete <SPELL> on <DEST>", -- Needs review
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmenü zu öffnen",
	},
	esES = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones",
	},
	--esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ruRU = {},
	zhCN = {
		BROKER_CLICK = "|cffFFFFFF点击|r打开选项菜单",
	},
	zhTW = {
		BROKER_CLICK = "|cffFFFFFF點擊|r打開選項菜單",
	},
}

L.esMX = L.esES -- esMX is empty

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
