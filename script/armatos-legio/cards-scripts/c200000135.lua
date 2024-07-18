--聖蔓の略奪
--Sunvine Plunder
--Scripted by Playmaker 772211, fixed by pyrQ
Duel.LoadScript("c200000990.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Give control of Judgment Arrows
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Effect Damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.damcon)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JUDGEARROWS,20000070}
function s.tgfilter(c)
	return c:GetSequence()<5 and c:IsCode(CARD_JUDGEARROWS) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	if chkc then return chkc:GetSequence()<5 and chkc:IsControler(tp) and chkc:IsCode(CARD_JUDGEARROWS) and chkc:IsFaceup() end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsCode(20000070) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsImmuneToEffect(e) then
        Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
function s.cfilter(c,tp,re)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE) and re:GetHandler():IsCode(CARD_JUDGEARROWS) and c:GetBaseAttack()>0
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,re)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local atk=eg:Filter(s.cfilter,nil,tp,re):GetSum(Card.GetBaseAttack)/2
    e:SetLabel(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,atk)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	if atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end