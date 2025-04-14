local s, id = GetID()
function s.initial_effect(c)
    --Special summon 1 ritual monster from GY
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.cfilter(c)
    return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 2, nil) end
end

function s.filter(c, e, sp)
    return c:IsLevel(7) and c:IsRitualMonster() and c:IsAttack(2300) and c:IsDefense(2500) and
    c:IsCanBeSpecialSummoned(e, 0, sp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
        Duel.HintSelection(g)
        if #g > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
