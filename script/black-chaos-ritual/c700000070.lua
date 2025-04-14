local s, id = GetID()
function s.initial_effect(c)
    --prevent a monster from attacking
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 2) end
end

function s.filter(c)
    return c:IsFaceup() and c:IsLevelBelow(8)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter), tp, 0, LOCATION_MZONE,
            1, nil)
    end
end

function s.spfilter(c, e, tp)
    return (c:IsCode(id) or (c:IsLevel(7) and c:IsDefense(2100))) and
        c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Requirement
    if Duel.DiscardDeck(tp, 2, REASON_COST) < 1 then return end
    --Effect
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectMatchingCard(tp, aux.FilterMaximumSideFunctionEx(s.filter), tp, 0, LOCATION_MZONE, 1, 1, nil)
        :GetFirst()
    if not tc then return end
    Duel.BreakEffect()
    Duel.HintSelection(tc)
    --Cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(3206)
    e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetCondition(function(e) return Duel.IsTurnPlayer(1 - e:GetOwnerPlayer()) end)
    e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_SELF_TURN, 1)
    tc:RegisterEffect(e2)
    local g2 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_GRAVE, 0, nil, e, tp)
    if #g2 > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
        if #sg > 0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
