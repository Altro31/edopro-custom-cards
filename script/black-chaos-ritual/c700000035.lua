local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Destroy 1 card
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cfilter(c)
    return c:IsRitualMonster() and c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_SPELLCASTER)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.filter(c)
    return not c:IsMaximumModeSide()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local dg = Duel.GetMatchingGroup(s.filter, tp, 0, LOCATION_ONFIELD, nil)
    if chk == 0 then
        return #dg > 0
    end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local dg = Duel.GetMatchingGroup(s.filter, tp, 0, LOCATION_ONFIELD, nil)
    if #dg > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local sg = dg:Select(tp, 1, 1, nil)
        sg = sg:AddMaximumCheck()
        Duel.HintSelection(sg, true)
        Duel.Destroy(sg, REASON_EFFECT)
    end
end
