--Armatos Legio Seeker
local s,id=GetID()
function s.initial_effect(c)
	c:AddALProtection()
	----search
	--local e1=Effect.CreateEffect(c)
    --e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	--e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	--e1:SetCode(EVENT_SUMMON_SUCCESS)
	--e1:SetTarget(s.thtg)
	--e1:SetOperation(s.thop)
	--c:RegisterEffect(e1)
    --Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={CARDS_A_LEGIO}
function s.thfilter(c)
	return c:IsSetCard(CARDS_A_LEGIO) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
        local a=Duel.GetAttacker()
        local b=a:GetBattleTarget()
        return aux.ALWeapCon(a,e:GetHandler()) and a:IsControler(tp)
            and b and b:IsControler(1-tp)
    end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
    local b=a:GetBattleTarget()
	if b and b:IsRelateToBattle() then
		Duel.Destroy(b,REASON_EFFECT)
	end
end
