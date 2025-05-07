local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Make opponents monsters lose ATK and gain multiple attack
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

s.listed_names = { 700000005 }
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 1) end
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsAttackAbove(0)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.posfilter, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then
        return Duel.IsAbleToEnterBP() or #g > 0
    end
    local c = e:GetHandler()
    local ct = c:GetMaterialCount()
    local atk = ct * 1000
    Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, e:GetHandler(), 1, tp, atk)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.DiscardDeck(tp, 1, REASON_COST) <= 0 then return end
    local c = e:GetHandler()
    local ct = c:GetMaterialCount()
    local g = Duel.GetMatchingGroup(s.posfilter, tp, 0, LOCATION_MZONE, nil)
    for tc in g:Iter() do
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000 * ct)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        tc:RegisterEffect(e1)
    end
    local propery = EFFECT_FLAG_CANNOT_DISABLE
    if ct > 1 then
        propery = propery | EFFECT_FLAG_CLIENT_HINT
    end
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(propery)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetValue(ct - 1)
    e2:SetReset(RESETS_STANDARD_PHASE_END)
    c:RegisterEffect(e2)
end
