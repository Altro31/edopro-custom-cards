--Judgment Sword
Duel.LoadScript("c200000990.lua")


local s, id = GetID()
function s.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_series = { CARDS_A_LEGIO }
function s.confilter(c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsExistingMatchingCard(s.confilter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.confilter, tp, 0, LOCATION_MZONE, 1, nil)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.confilter, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_MZONE)
end

function s.spfilter(c, e, tp, lk)
    return c:IsSetCard(CARDS_A_LEGIO) and c:IsLinkMonster() and c:IsLink(lk) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end


function s.activate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.confilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    if #g > 0 and Duel.Remove(g, POS_FACEUP, REASON_EFFECT) > 0 then
        local bc = Duel.GetOperatedGroup():GetFirst()
        if bc and bc:IsLinkMonster() then
            local sg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,bc:GetLink())
            local str=0
            if bc:IsCanBeSpecialSummoned(e,0,tp,false,false,1-tp) then
                str=aux.Stringid(id,0)
            else
                str=aux.Stringid(id,1)
            end
            if #sg1>0 and Duel.SelectYesNo(tp,str) then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local sg = sg1:Select(tp,1,1,nil)
                if #sg > 0 then
                    local tc = sg:GetFirst()
                    if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) then
                        Duel.SpecialSummon(bc, 0, tp, 1 - tp, false, false, POS_FACEUP)
                    end
                end
            end
        end
    end
end

function s.spcon(e)
    return Duel.GetFlagEffect(e:GetOwnerPlayer(), id) > 0
end

function s.checkop(e, tp, eg, ep, ev, re, r, rp)
    if eg:IsExists(Card.IsSummonType, 1, nil, SUMMON_TYPE_LINK) then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
    end
end
