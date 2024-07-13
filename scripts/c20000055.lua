--Armatos Colosseum
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--register names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
							s.name_list[0]={}
							s.name_list[1]={}
							end)
		end)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.adjustop)
		Duel.RegisterEffect(ge1,0)
end
s.listed_series={CARDS_A_LEGIO}
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(CARDS_A_LEGIO) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.costfilter(c,e,tp)
	local code=c:GetCode()
	return not table.includes(s.name_list[tp],code) and c:IsSetCard(CARDS_A_LEGIO) and c:IsDiscardable(REASON_COST) 
		and c:IsMonster() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,code)
end
function s.tgfilter(c,e,tp,code)
	local zone=c:GetFreeLinkedZone()&0x1f
	return c:IsSetCard(CARDS_A_LEGIO) and c:IsLinkMonster() and zone>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,code,zone)
end
function s.spfilter(c,e,tp,code,zone)
	return c:IsLevelBelow(4) and c:IsSetCard(CARDS_A_LEGIO) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local code=tc:GetCode()
	e:SetLabel(code)
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,code)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(#sg) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local code=e:GetLabel()
	table.insert(s.name_list[tp],code)
	if not tc or not tc:IsRelateToEffect(e) then return end
    local zone=tc:GetFreeLinkedZone()&0x1f
	if zone==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,code,zone)
	if #sg<=0 then return end
	local sg_unq=sg:GetClassCount(Card.GetCode)
	local count=s.zone_count(zone)
	if #sg<count then count=#sg end
	if sg_unq<count then count=sg_unq end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then count=1 end
	if zone~=0 then
		local g=aux.SelectUnselectGroup(sg,e,tp,count,count,s.rescon,1,tp,HINTMSG_SPSUMMON)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(CARDS_A_LEGIO)
end
function s.zone_count(z)
	local c=0
	while z>0 do
		c=c+1
		z=z&(z-1)
	end
	return c
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if not s.name_list[0] or not s.name_list[1] or Duel.GetCurrentPhase()>PHASE_MAIN2 then return end
	for p=0,1 do
		local tc=Duel.GetFirstMatchingCard(aux.FilterFaceupFunction(Card.IsCode,20000055),p,LOCATION_FZONE,0,nil)
		if tc and s.name_list[p] then
			for _,code in ipairs(s.name_list[p]) do
				local loc=s.GetAColosseumCodeLocation(code)
				if loc~=0 then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,loc))
				end
			end
		end
	end
end
if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end
function s.GetAColosseumCodeLocation(code)
	local t = {
		[20000050] = 2,
		[20000035] = 3,
		[20000085] = 4,
		[20000010] = 5,
		[20000095] = 6,
		[20000090] = 7,
		[20000040] = 8
	}
	local loc=0
	if t[code] then
		loc=t[code]
	end
	return loc
end