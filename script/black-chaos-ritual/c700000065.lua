local s, id = GetID()
function s.initial_effect(c)
    --Activate
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,700000050),lv=8,extrafil=s.extragroup,
									extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_EXTRA,extratg=s.extratg})
	c:RegisterEffect(e1)
end

s.listed_names = { 700000050 }

function s.matfilter(c)
	return c:IsAbleToGrave() and not c:IsMaximumModeSide()
end

function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    mat=mat:AddMaximumCheck()
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

