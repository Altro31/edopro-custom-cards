--Armatos Legio Legatus Legionis
Duel.LoadScript("c200000990.lua")

local s, id = GetID()
function s.initial_effect(c)
    --link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, CARDS_A_LEGIO), 2)
    c:EnableReviveLimit()
    --send and special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --actlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.limval)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end

s.listed_series = { CARDS_A_LEGIO }
function s.sendfilter(c, ft)
    return c:IsLevelBelow(4) and c:IsSetCard(CARDS_A_LEGIO) and c:IsAbleToGrave()
end

function s.spfilter(c, e, tp)
    return c:IsLevelBelow(4) and c:IsSetCard(CARDS_A_LEGIO) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return false end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > -1
            and Duel.IsExistingTarget(s.sendfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g1 = Duel.SelectTarget(tp, s.sendfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g2 = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g1, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g2, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local ex, g1 = Duel.GetOperationInfo(0, CATEGORY_TOGRAVE)
    local ex, g2 = Duel.GetOperationInfo(0, CATEGORY_SPECIAL_SUMMON)
    local tc1 = g1:GetFirst()
    local tc2 = g2:GetFirst()
    if tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1, REASON_EFFECT) ~= 0 and tc1:IsLocation(LOCATION_GRAVE) and tc2:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc2, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.limval(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end