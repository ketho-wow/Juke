local _, S = ...

local L = {
	enUS = {
		MSG_INTERRUPT = "<SRC><SPELL> "..ACTION_SPELL_INTERRUPT.." <DEST><XSPELL>",
		MSG_INTERRUPT_SOLO = "<SPELL> "..ACTION_SPELL_INTERRUPT.." <DEST><XSPELL>",
		MSG_JUKE = "<SRC> juked <SPELL> on <DEST>",
		MSG_JUKE_SOLO = "Juked <SPELL> on <DEST>",
		BROKER_CLICK = "|cffFFFFFFClick|r to open the options menu",
	},
	deDE = {
		MSG_INTERRUPT = "<SRC><SPELL> unterbrach <DEST><XSPELL>",
		MSG_INTERRUPT_SOLO = "<SPELL> unterbrach <DEST><XSPELL>",
		MSG_JUKE = "<SRC> verschwendete <SPELL> on <DEST>",
		MSG_JUKE_SOLO = "Verschwendete <SPELL> on <DEST>",
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmenü zu öffnen",
	},
	esES = {
		MSG_INTERRUPT = "<SRC><SPELL> interrumpió <DEST><XSPELL>",
		MSG_INTERRUPT_SOLO = "<SPELL> interrumpió <DEST><XSPELL>",
		MSG_JUKE = "<SRC> malgastó <SPELL> de <DEST>",
		MSG_JUKE_SOLO = "Malgasté <SPELL> de <DEST>",
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones",
	},
	esMX = {
		MSG_INTERRUPT = "<SRC><SPELL> interrumpió <DEST><XSPELL>",
		MSG_INTERRUPT_SOLO = "<SPELL> interrumpió <DEST><XSPELL>",
		MSG_JUKE = "<SRC> malgastó <SPELL> de <DEST>",
		MSG_JUKE_SOLO = "Malgasté <SPELL> de <DEST>",
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones",
	},
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

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
