local s, id = GetID()
function s.initial_effect(c)
    --Activate
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,lv=7,extrafil=s.extragroup,
									extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_EXTRA,extratg=s.extratg})
	c:RegisterEffect(e1)
end

s.listed_names = { 700000035, 700000040, }

function s.ritualfil(c)
    return (c:IsCode(700000035) or c:IsCode(700000040)) and c:IsRitualMonster()
end

function s.matfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave() and not c:IsMaximumModeSide()
end

function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    mat=mat:AddMaximumCheck()
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
