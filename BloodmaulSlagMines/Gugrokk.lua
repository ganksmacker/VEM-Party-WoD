local mod	= DBM:NewMod(889, "VEM-Party-WoD", 2, 385)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 11380 $"):sub(12, -3))
mod:SetCreatureID(74790)
mod:SetEncounterID(1654)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 150677 150784 150755",
	"SPELL_PERIODIC_DAMAGE 150784",
	"SPELL_PERIODIC_MISSED 150784"
)

--TODO, Add heroic ability "Flame Buffet" Since ability name to common can't just wowhead the spellid
local warnMoltenBlast			= mod:NewCastAnnounce(150677, 4)
local warnUnstableSlag			= mod:NewSpellAnnounce(150677, 3)
local warnMagmaEruption			= mod:NewSpellAnnounce(150784, 3)

local specWarnMoltenBlast		= mod:NewSpecialWarningInterrupt(150677)
local specWarnUnstableSlag		= mod:NewSpecialWarningSwitch(150755, not mod:IsHealer())
local specWarnMagmaEruptionCast	= mod:NewSpecialWarningSpell(150784, nil, nil, nil, 2)
local specWarnMagmaEruption		= mod:NewSpecialWarningMove(150784)

local timerMagmaEruptionCD		= mod:NewCDTimer(20, 150784)
local timerUnstableSlagCD		= mod:NewCDTimer(20, 150755)

function mod:OnCombatStart(delay)
--	timerMagmaEruptionCD:Start(8-delay)--Poor sample size
	timerUnstableSlagCD:Start(-delay)--Also poor sample size but more likely to be correct.
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 150677 then
		if mod:IsTank() then
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\kickcast.ogg")
		elseif (not mod:IsHealer()) then
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\helpkick.ogg")
		end
		warnMoltenBlast:Show()
		specWarnMoltenBlast:Show(args.sourceName)
	elseif spellId == 150784 then
		warnMagmaEruption:Show()
		specWarnMagmaEruptionCast:Show()
		timerMagmaEruptionCD:Start()
	elseif spellId == 150755 then
		if (not mod:IsHealer()) then
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\mobkill.ogg")
			sndWOP:Schedule(2, DBM.SoundMMPath.."\\mobkill.ogg")
		end
		warnUnstableSlag:Show()
		specWarnUnstableSlag:Show()
		timerUnstableSlagCD:Start()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 150784 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runaway.ogg")
		specWarnMagmaEruption:Show()
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
