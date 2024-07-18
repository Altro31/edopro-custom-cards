--Armatos Legio Plumbum Trident
Duel.LoadScript("c200000990.lua")


local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Force zone for this card summon
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_FORCE_MZONE)
    e0:SetValue(0x60)
    c:RegisterEffect(e0)
    --spsummon limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
    --summmon success/Gain ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    --immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)
    --Force zone both player's monsters
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_FORCE_MZONE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1, 1)
    e4:SetValue(function(e) return e:GetHandler():GetLinkedZone() end)
    c:RegisterEffect(e4)
    --disable
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e5:SetCode(EFFECT_DISABLE)
    e5:SetTarget(function(e, c) return e:GetHandler():GetLinkedGroup():IsContains(c) end)
    c:RegisterEffect(e5)
    aux.GlobalCheck(s, function()
        s.count = 0
    end)
    local ge1 = Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_CHAIN_SOLVING)
    ge1:SetOperation(s.adjustop)
    Duel.RegisterEffect(ge1, 0)
end

s.listed_names = { 20000110 }
function s.efilter(e, te)
    return te:GetOwner() ~= e:GetOwner()
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:UpdateAttack(s.count * 600, RESET_EVENT + RESETS_STANDARD_DISABLE)
end

function s.splimit(e, se, sp, st)
    local sc = se:GetHandler()
    return sc and sc:IsCode(20000110)
end

function s.adjustop(e, tp, eg, ep, ev, re, r, rp)
    if re and re:GetHandler():IsCode(20000110) and not re:GetHandler():IsDisabled() then
        local ge1 = Effect.GlobalEffect()
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_REMOVE)
        ge1:SetOperation(s.remop)
        ge1:SetLabelObject(re:GetHandler())
        Duel.RegisterEffect(ge1, re:GetOwnerPlayer())
        local ge2 = Effect.GlobalEffect()
        ge2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_CHAIN_SOLVED)
        ge2:SetOperation(s.resetop(ge1))
        ge2:SetLabelObject(re:GetHandler())
        Duel.RegisterEffect(ge2, re:GetOwnerPlayer())
    end
end

function s.resfilter(c,re)
    return re and re:GetHandler():IsCode(20000110)
end

function s.remop(e, tp, eg, ep, ev, re, r, rp)
    local judg_sword = e:GetLabelObject()
    if not eg or not eg:IsExists(s.resfilter, 1, nil, re) or judg_sword:IsDisabled() then return end
    local g=eg:Filter(s.resfilter,nil,re)
    s.count = s.count + #g
end

function s.resetfil(c)
    return c:GetFlagEffect(id) > 0
end

function s.resetop(ge)
    return function(e, tp, eg, ep, ev, re, r, rp)
        if re and re:GetHandler():IsCode(20000110) then
            s.count = 0
            e:Reset()
            ge:Reset()
        end
    end
end
