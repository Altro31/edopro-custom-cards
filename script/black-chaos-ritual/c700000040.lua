local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --ATK increase
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCountLimit(1)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 1) end
end

function s.cfilter(c)
    return c:IsRitualMonster() and c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_SPELLCASTER)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    --requirement
    if Duel.DiscardDeck(tp, 1, REASON_COST) > 0 then
        --effect
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
            e1:SetValue(1000)
            c:RegisterEffect(e1)
            if Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, null) then
                local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
                if #g > 0 then
                    for tc in g:Iter() do
                        local e2 = Effect.CreateEffect(c)
                        e2:SetType(EFFECT_TYPE_SINGLE)
                        e2:SetCode(EFFECT_UPDATE_ATTACK)
                        e2:SetValue(500)
                        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e2:SetReset(RESETS_STANDARD_PHASE_END)
                        tc:RegisterEffect(e2)
                    end
                end
            end
        end
    end
end
