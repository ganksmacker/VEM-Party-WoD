local mod	= DBM:NewMod(966, "VEM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 11371 $"):sub(12, -3))
mod:SetCreatureID(76141)
mod:SetEncounterID(1699)--Verify, name doesn't match
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 154135",
	"SPELL_AURA_APPLIED 154159"
)


--Add smash? it's a 1 sec cast, can it be dodged?
local warnEnergize		= mod:NewSpellAnnounce(154159, 3)
local warnBurst			= mod:NewCountAnnounce(154135, 3)

local specWarnBurst		= mod:NewSpecialWarningCount(154135, nil, nil, nil, 2)

local timerEnergozeCD	= mod:NewNextTimer(20, 154159)
local timerBurstCD		= mod:NewCDCountTimer(23, 154135)

mod.vb.burstCount = 0

function mod:OnCombatStart(delay)
	self.vb.burstCount = 0
	timerBurstCD:Start(20-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 154135 then
		self.vb.burstCount = self.vb.burstCount + 1
		warnBurst:Show(self.vb.burstCount)
		specWarnBurst:Show(self.vb.burstCount)
		timerBurstCD:Start(nil, self.vb.burstCount+1)
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\aesoon.ogg")
		if self.vb.burstCount < 11 then
			sndWOP:Schedule(1.2, "Interface\\AddOns\\DBM-Core\\sounds\\"..DBM.Options.CountdownVoice2.."\\"..self.vb.burstCount..".ogg")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 154159 and self:AntiSpam(2, 1) then
		warnEnergize:Show()
		timerEnergozeCD:Start()
	end
end
