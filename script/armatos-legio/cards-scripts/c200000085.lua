--Armatos Legio Galea
Duel.LoadScript("c200000990.lua")


local s,id=GetID()
function s.initial_effect(c)
	c:AddALProtection()
	--Special Summon this card from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--linked group
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.linkcon)
	e2:SetOperation(s.linkop)
	c:RegisterEffect(e2)
	--no dmg
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.ndamcon)
	e3:SetOperation(s.ndamop)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
end
s.listed_series={CARDS_A_LEGIO}
function s.filter(c)
	return c:IsLinkMonster() and c:IsSetCard(CARDS_A_LEGIO)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3002)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.linkfilter(c,e,tp)
	return c:IsLinkMonster() and c:IsSetCard(CARDS_A_LEGIO) and c:IsControler(tp)
		and (e:GetHandler():GetLinkedGroup():IsContains(c) or c:GetLinkedGroup():IsContains(e:GetHandler()))
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if #g>0 then
		e:SetLabel(1)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,3210)
			--local e1=Effect.CreateEffect(c)
			--e1:SetDescription(3210)
			--e1:SetType(EFFECT_TYPE_SINGLE)
			--e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			--tc:RegisterEffect(e1)
		end
	end
end
function s.ndamcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetLabelObject():GetLabel()==1
end
function s.ndamop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetValue(1)
	e1:SetReset(EVENT_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,c)
	return c:GetFlagEffect(id)>0
end