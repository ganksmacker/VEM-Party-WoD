local mod	= DBM:NewMod(1163, "VEM-Party-WoD", 3, 536)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 11582 $"):sub(12, -3))
mod:SetCreatureID(79545)
mod:SetEncounterID(1732)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 160681",
	"SPELL_CAST_START 163550 160680",
	"SPELL_PERIODIC_DAMAGE 166570",
	"SPELL_PERIODIC_MISSED 166570",
	"UNIT_DIED",
	"UNIT_TARGETABLE_CHANGED"
)

local warnMortar				= mod:NewSpellAnnounce(163550, 3)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnSupressiveFire		= mod:NewTargetAnnounce(160681, 2)--In a repeating loop
--local warnGrenadeDown			= mod:NewAnnounce("warnGrenadeDown", 1, "ej9711", nil, DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej9711"))--Boss is killed by looting using these positive items on him.
--local warnMortarDown			= mod:NewAnnounce("warnMortarDown", 4, "ej9712", nil, DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej9712"))--So warn when adds that drop them die
local warnPhase3				= mod:NewPhaseAnnounce(3)

local specWarnSupressiveFire	= mod:NewSpecialWarningYou(160681)
local yellSupressiveFire		= mod:NewYell(160681)
local specWarnSlagBlast			= mod:NewSpecialWarningMove(166570)

local timerSupressiveFire		= mod:NewTargetTimer(10, 160681)

local grenade = EJ_GetSectionInfo(9711)
local mortar = EJ_GetSectionInfo(9712)
mod.vb.phase = 1

function mod:SupressiveFireTarget(targetname, uId)
	if not targetname then return end
	warnSupressiveFire:Show(targetname)
	if targetname == UnitName("player") then
		specWarnSupressiveFire:Show()
		yellSupressiveFire:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.phase = 1
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 160681 and args:IsDestTypePlayer() then
		timerSupressiveFire:Start(args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 163550 then
		warnMortar:Show()
	elseif args.spellId == 160680 then
		self:BossTargetScanner(79548, "SupressiveFireTarget", 0.2, 15)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 166570 and destGUID == UnitGUID("player") and self:AntiSpam() then
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runaway.ogg")
		specWarnSlagBlast:Show()
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 79739 then--Blackrock Grenadier
		warnGrenadeDown:Show(grenade)
	elseif cid == 79720 then--Blackrock Artillery Engineer
		warnMortarDown:Show(mortar)
	end
end]]

function mod:UNIT_TARGETABLE_CHANGED()
	self.vb.phase = self.vb.phase + 1
	if self.vb.phase == 2 then
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ptwo.ogg")
		warnPhase2:Show()
	elseif self.vb.phase == 3 then
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\pthree.ogg")
		warnPhase3:Show()
	end
end
