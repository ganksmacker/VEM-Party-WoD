local mod	= DBM:NewMod(1210, "VEM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 11483 $"):sub(12, -3))
mod:SetCreatureID(83846)
mod:SetEncounterID(1756)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 169179 169613",
	"SPELL_CAST_SUCCESS 169251",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnColossalBlow			= mod:NewSpellAnnounce(169179, 2)
local warnEntanglement			= mod:NewSpellAnnounce(169251, 3)
local warnFontofLife			= mod:NewSpellAnnounce(169120, 3)--Does this need a switch warning too?
local warnGenesis				= mod:NewSpellAnnounce(169251, 4)

local specWarnColossalBlow		= mod:NewSpecialWarningSpell(169179, nil, nil, nil, 2)
local specWarnEntanglement		= mod:NewSpecialWarningSwitch(169251, mod:IsDps())
local specWarnGenesis			= mod:NewSpecialWarningSwitch(169613)--Everyone. "Switch" is closest generic to "run around stomping flowers"

--Only timers that were consistent, others are all over the place.
local timerFontOfLife			= mod:NewNextTimer(15, 169120)
local timerGenesis				= mod:NewNextTimer(60, 169613)

function mod:OnCombatStart(delay)
	timerFontOfLife:Start(-delay)
	timerGenesis:Start(30-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 169179 then
		warnColossalBlow:Show()
		specWarnColossalBlow:Show()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\shockwave.ogg")
	elseif spellId == 169613 then
		warnGenesis:Show()
		specWarnGenesis:Show()
		timerGenesis:Start()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\153247.ogg")
		sndWOP:Schedule(10, DBM.SoundMMPath.."\\countfive.ogg")
		sndWOP:Schedule(11, DBM.SoundMMPath.."\\countfour.ogg")
		sndWOP:Schedule(12, DBM.SoundMMPath.."\\countthree.ogg")
		sndWOP:Schedule(13, DBM.SoundMMPath.."\\counttwo.ogg")
		sndWOP:Schedule(14, DBM.SoundMMPath.."\\countone.ogg")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 169251 then
		warnEntanglement:Show()
		specWarnEntanglement:Show()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 169120 then
		warnFontofLife:Show()
		timerFontOfLife:Start()
	end
end
