
--Armatos Legio Gladius
local s, id = GetID()
function s.initial_effect(c)
	c:AddALProtection()
	--search
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--linked atk up
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE, 0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end

s.listed_series = { CARDS_A_LEGIO }
function s.thfilter(c)
	return c:IsSetCard(0x789) and c:IsAbleToHand() and c:IsSpellTrap()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp, chk)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

function s.atkcon(e)
	return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
end

function s.atktg(e, c)
	if not aux.ALWeapCon(c, e:GetHandler()) then return false end
	return Duel.GetAttacker() == c or c == Duel.GetAttackTarget()
end
