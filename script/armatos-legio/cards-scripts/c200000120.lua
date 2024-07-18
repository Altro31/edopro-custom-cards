--Armatos Legio Legatus Legionis
Duel.LoadScript("c200000990.lua")


local s, id = GetID()
function s.initial_effect(c)
    --destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hdcon)
	e1:SetTarget(s.hdtg)
	e1:SetOperation(s.hdop)
	c:RegisterEffect(e1)
    --destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.descon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series = { CARDS_A_LEGIO }
function s.cfilter1(c,tp)
	return c:IsControler(1-tp) and c:IsSummonPlayer(1-tp)
end
function s.cfilter2(c)
	return c:IsSetCard(CARDS_A_LEGIO) and c:IsLinkMonster()
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_HAND,0,1,nil) 
        and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,1)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
    local ct=2
    if ct>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) end
	if ct<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg1=g:Select(tp,1,ct,nil)
    if #dg1<=0 then return end
    local ct1=Duel.Destroy(dg1,REASON_EFFECT)
    if ct1>0 then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
        local dg2=Duel.SelectMatchingCard(1-tp,aux.TRUE,tp,0,LOCATION_HAND,ct1,ct1,nil)
        if #dg2>0 then
            Duel.Destroy(dg2,REASON_EFFECT)
        end
    end
end
function s.desfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end