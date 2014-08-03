local mod	= DBM:NewMod(1138, "DBM-Party-WoD", 3, 536)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 11438 $"):sub(12, -3))
mod:SetCreatureID(77803, 77816)
mod:SetEncounterID(1715)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 162500 162407 161090",
	"UNIT_DIED"
)

local warnVX18B					= mod:NewCountAnnounce(162500, 2)--Cast twice, 3rd cast is X2101, then repeats
local warnX2101AMissile			= mod:NewSpellAnnounce(162407, 4)
local warnMadDash				= mod:NewSpellAnnounce(161090, 3)

local specWarnMadDash			= mod:NewSpecialWarningInterrupt(161090, mod:IsTank())--It's actually an interrupt warning for OTHER boss, not caster of this spell

local timerVX18BCD				= mod:NewCDTimer(33, 162500)
local timerX2101AMissileCD		= mod:NewCDTimer(42, 162407)
local timerMadDashCD			= mod:NewCDTimer(42, 161090)

local rocketsName = EJ_GetSectionInfo(9430)
mod.vb.VXCast = 0

function mod:OnCombatStart(delay)
	self.vb.VXCast = 0
	timerX2101AMissileCD:Start(21-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 162500 then
		self.vb.VXCast = self.vb.VXCast + 1
		warnVX18B:Show(self.vb.VXCast)
		if self.vb.VXCast == 2 then
			timerVX18BCD:Start()
		else
			timerVX18BCD:Start(7)
		end
	elseif spellId == 162407 then
		warnX2101AMissile:Show()
		timerX2101AMissileCD:Start()
	elseif spellId == 161090 then
		specWarnMadDash:Show(rocketsName)
		timerMadDashCD:Start()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	--Maybe both cancel if either one dies?
	if cid == 77816 then
		timerMadDashCD:Cancel()
	elseif cid == 77803 then
		timerX2101AMissileCD:Cancel()
	end
end
