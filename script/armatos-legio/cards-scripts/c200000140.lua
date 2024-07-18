-- Armatos Legio Imperator
Duel.LoadScript("c200000990.lua")

local s, id = GetID()
function s.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    Link.AddProcedure(c, s.matfilter, 3)

    --unique on field
    c:SetUniqueOnField(1, 0, id)

    --Gains 1000 x co-linked monsters
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    --Damage and Special Summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCondition(s.condition)
    c:RegisterEffect(e3)

    --destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)

    --Register links used
	aux.GlobalCheck(s,function()
		s.link_list={}
		s.link_list[0]=0
		s.link_list[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_END)
		ge1:SetCountLimit(1)
		ge1:SetCondition(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end)
end

s.listed_series = { CARDS_A_LEGIO }
function s.matfilter(c, lc, sumtype, tp)
    return c:IsSetCard(CARDS_A_LEGIO, lc, sumtype, tp)
end

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.link_list[0]=0
	s.link_list[1]=0
	return false
end

function s.atkcon(e, c, tp)
    return c:IsSummonType(SUMMON_TYPE_LINK)
end

function s.atkfilter(c)
    return #c:GetMutualLinkedGroup():Filter(Card.IsMonster, nil) > 0
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.atkfilter, 0, LOCATION_ONFIELD, LOCATION_ONFIELD) * 1000
end

function s.cfilter(c,e,tp)
    local link = c:GetLink()
    return c:IsAbleToExtraAsCost() and c:IsLinkMonster() and c:IsSetCard(CARDS_A_LEGIO) and s.link_list[tp]&link==0
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 1, nil,e,tp) end
    local sg = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil,e,tp)
    e:SetLabelObject(sg:GetFirst())
    Duel.SendtoDeck(sg, nil, 0, REASON_COST)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local tc = e:GetLabelObject()
    local dam = tc:GetLink() * 100
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dam)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dam)
    Duel.SetChainLimit(function() return false end)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    if Duel.Damage(p, d, REASON_EFFECT)<=0 then return end
    local tc = e:GetLabelObject()
    if not (tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_EXTRA)) then return end
    local c = e:GetHandler()
    if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
    if Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and Duel.SelectYesNo(tp,aux.StringId(id,1)) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
    local link = tc:GetLink()
    s.link_list[tp]=s.link_list[tp]|link
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,"Link: "+str)
end

function s.repfilter(c,e,g)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and g:IsContains(c)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local g = c:GetMutualLinkedGroup()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and not c:IsReason(REASON_RULE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,0,1,c,e,g) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e,g)
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
