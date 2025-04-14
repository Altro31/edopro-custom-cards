local s, id = GetID()
function s.initial_effect(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.isfit(c, mc)
    return (mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))) or mc:ListsCode(c:GetCode())
end

function s.ritualspellfilter(c, tc)
    return s.isfit(tc, c) and c:IsSSetable()
end

function s.revealfilter(c,tp)
    return (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_SPELLCASTER)) and c:IsRitualMonster() and c:IsDefenseAbove(2500) and
        not c:IsPublic() 
        and Duel.IsExistingMatchingCard(s.ritualspellfilter, tp, LOCATION_GRAVE, 0, 1, nil, c)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.revealfilter, tp, LOCATION_EXTRA, 0, 1, nil,tp) end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    --Requirement
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc = Duel.SelectMatchingCard(tp, s.revealfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil,tp):GetFirst()
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleExtra(tp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
    local sg = Duel.GetMatchingGroup(s.ritualspellfilter, tp, LOCATION_GRAVE, 0, nil, tc)
    if ft > 0 and #sg > 0 then
        local tg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.ritualspellfilter), tp, LOCATION_GRAVE, 0, 1, 1,
            nil, tc)
        Duel.HintSelection(tg)
        Duel.SSet(tp, tg)
    end
end
