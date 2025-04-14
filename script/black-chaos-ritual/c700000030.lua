local s, id = GetID()
function s.initial_effect(c)
    --Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES + CATEGORY_SPECIAL_SUMMON)
    e1:SetRange(LOCATION_MZONE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) end
end

function s.spfilter(c, e, tp)
    return ((c:IsAttack(1200) and c:IsDefense(1500)) or (c:IsAttack(1400) and c:IsDefense(1200))) and
    c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.DiscardDeck(tp, 2, REASON_EFFECT)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_GRAVE, 0, nil, e, tp)
    if #g > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
        if #sg > 0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
        end
    end
end
