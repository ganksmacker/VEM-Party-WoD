local mod	= DBM:NewMod(1235, "DBM-Party-WoD", 4, 558)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, true, "SoundWOP")

mod:SetRevision(("$Revision: 11511 $"):sub(12, -3))
mod:SetCreatureID(81297, 81305)
mod:SetEncounterID(1749)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 164426",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnBurningArrows					= mod:NewSpellAnnounce(164635, 3)
local warnRecklessProvocation			= mod:NewTargetAnnounce(164426, 3)

local specWarnBurningArrows				= mod:NewSpecialWarningSpell(164635, nil, nil, nil, true)
local specWarnRecklessProvocation		= mod:NewSpecialWarningReflect(164426)

local timerBurningArrowsCD				= mod:NewNextTimer(25, 164635)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 164426 then
		sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\stopattack.mp3")
		sndWOP:Schedule(2, "Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(3, "Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(4, "Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\countone.mp3")
		warnRecklessProvocation:Show(args.destName)
		specWarnRecklessProvocation:Show(args.destName)
	end
end

--Not detectable in phase 1. Seems only cleanly detectable in phase 2, in phase 1 boss has no "boss" unitid so cast hidden.
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 164635 then
		warnBurningArrows:Show()
		specWarnBurningArrows:Show()
		timerBurningArrowsCD:Start()
	end
end
