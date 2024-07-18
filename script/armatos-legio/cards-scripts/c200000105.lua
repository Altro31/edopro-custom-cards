--Armatos Legio
Duel.LoadScript("c200000990.lua")

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--cannot be attack target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
    --save co-linked group
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.colinkop)
	c:RegisterEffect(e2)
	--effect damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.dmgcon)
	e3:SetTarget(s.dmgtg)
	e3:SetOperation(s.dmgop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--above damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={CARDS_A_LEGIO}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(CARDS_A_LEGIO,lc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
function s.colinkop(e,tp,eg,ep,ev,re,r,rp)
	local clg=e:GetHandler():GetMutualLinkedGroup()
	e:SetLabelObject(clg)
	if #clg>0 then
		clg:KeepAlive()
	else
		clg:DeleteGroup()
	end
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT) and g and #g>0
end
function s.dmgfilter(c,e)
	return c:IsLinkMonster() and c:IsSetCard(CARDS_A_LEGIO) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():GetLabelObject()
	if chkc then return g and g:IsContains(chkc) and s.dmgfilter(chkc,e) end
	if chk==0 then return g and g:IsExists(s.dmgfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local dg=g:FilterSelect(tp,s.dmgfilter,1,1,nil,e)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dg:GetFirst():GetBaseAttack())
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		Duel.Damage(tp,atk,REASON_EFFECT,true)
		Duel.Damage(1-tp,atk,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Each turn, reduce battle or effect damage to 0 the first time.
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.damval2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetCondition(function(e)return e:GetHandler():GetFlagEffect(id)==0 end)
	Duel.RegisterEffect(e4,tp)
end
function s.damval2(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	if r&REASON_EFFECT~=0 and c:GetFlagEffect(id)==0 and val>=Duel.GetLP(tp) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.SetLP(tp,1)
		return 0
	end
	return val
end