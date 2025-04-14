local s, id = GetID()
function s.initial_effect(c)
    --Set and Draw
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s, function()
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_DRAW)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1, 0)
    end)
end

function s.checkop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsMainPhase() then
        Duel.RegisterFlagEffect(ep, id, RESET_PHASE|PHASE_END, 0, 1)
    end
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end

function s.sfilter(c)
    return c:IsCode(700000065) and c:IsSSetable()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.sfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
    local sg = Duel.GetMatchingGroup(s.sfilter, tp, LOCATION_GRAVE, 0, nil)
    if ft > 0 and #sg > 0 then
        local tg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.sfilter), tp, LOCATION_GRAVE, 0, 1, 1, nil)
        Duel.HintSelection(tg)
        Duel.SSet(tp, tg)
        if Duel.GetFlagEffect(tp, id) == 0 and Duel.IsPlayerCanDraw(tp, 1) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.BreakEffect()
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end
