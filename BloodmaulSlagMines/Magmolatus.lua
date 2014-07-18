local mod	= DBM:NewMod(893, "DBM-Party-WoD", 2, 385)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 11336 $"):sub(12, -3))
mod:SetCreatureID(74366, 74475)--74366 Forgemaster Gog'duh, 74475 Magmolatus
mod:SetEncounterID(1655)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 149997 149975 150032",
	"SPELL_CAST_START 150038"
)

-------------------------------------------
local warnFirestorm				= mod:NewSpellAnnounce(149997, 3)
local warnDancingFlames			= mod:NewTargetAnnounce(149975, 3, nil, mod:IsHealer())
local warnWitheringFlames		= mod:NewTargetAnnounce(150032, 3, nil, mod:IsHealer())
local warnMoltenImpact			= mod:NewSpellAnnounce(150038, 4)

local specWarnRuination			= mod:NewSpecialWarningSwitch("ej8622", not mod:IsHealer())
local specWarnCalamity			= mod:NewSpecialWarningSwitch("ej8626", not mod:IsHealer())
local specWarnFirestorm			= mod:NewSpecialWarningInterrupt(149997, not mod:IsHealer())
local specWarnMagmolatus		= mod:NewSpecialWarningSwitch("ej8621", mod:IsTank())--Dps can turn this on too I suppose but 5 seconds after boss spawns they are switching to add anyways, so this is mainly for tank to pick it up
local specWarnMoltenImpact		= mod:NewSpecialWarningSpell(150038, nil, nil, nil, 2)
local specWarnDancingFlames		= mod:NewSpecialWarningDispel(149975, mod:IsHealer())
local specWarnWitheringFlames	= mod:NewSpecialWarningDispel(150032, mod:IsHealer())

local specWarnSlagSmash		= mod:NewSpecialAnnounce(150023, 3, nil, mod:IsMelee)

local timerMoltenImpactCD		= mod:NewNextTimer(21.5, 150038)

local activeAddGUIDS = {}

function mod:OnCombatStart(delay)
	table.wipe(activeAddGUIDS)
	self:RegisterShortTermEvents(
		"INSTANCE_ENCOUNTER_ENGAGE_UNIT"
	)
end

function mod:OnCombatEnd()
	table.wipe(activeAddGUIDS)
	self:UnregisterShortTermEvents()
end

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 5 do
		local unitID = "boss"..i
		local unitGUID = UnitGUID(unitID)
		local cid = self:GetCIDFromGUID(unitGUID)
		if UnitExists(unitID) and not activeAddGUIDS[unitGUID] then
			activeAddGUIDS[unitGUID] = true
			--Ruination#Creature:0:3314:1175:11531:74570
			if cid == 74570 then--Ruination
				sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\mobsoon.mp3")
				specWarnRuination:Show()
			elseif cid == 74571 then--Calamity
				specWarnCalamity:Show()
				sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\mobsoon.mp3")
			elseif cid == 74475 then--Magmolatus
				sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\phasechange.mp3")
				specWarnMagmolatus:Show()
				timerMoltenImpactCD:Start(5)
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 149997 then
		if mod:IsTank() then
			sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\kickcast.mp3")
		else
			sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\helpkick.mp3")
		end
		warnFirestorm:Show()
		specWarnFirestorm:Show(args.sourceName)
	elseif spellId == 149975 then
		if mod:IsHealer() then
			sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\dispelnow.mp3")
		end
		warnDancingFlames:CombinedShow(0.3, args.destName)--heroic is 2 targets so combined.
		specWarnDancingFlames:Show(args.destName)--This will only warn for one of em though but still good alert for sound, at that point healer can find 2nd target off reg warn or frames
	elseif spellId == 150032 then
		if mod:IsHealer() then
			sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\dispelnow.mp3")
		end
		warnWitheringFlames:Show(args.destName)
		specWarnWitheringFlames:Show(args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 150038 then
		warnMoltenImpact:Show()
		specWarnMoltenImpact:Show()
		timerMoltenImpactCD:Start()
	elseif args.spellId == 150023 then
		specWarnSlagSmash:Show()
		if mod:IsMelee() then
			sndWOP:Play("Interface\\AddOns\\"..DBM.Options.CountdownVoice.."\\runaway.mp3")
		end
	end
end