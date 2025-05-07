local s, id = GetID()
function s.initial_effect(c)
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names = { 700000000 }
function s.ritualfil(c)
	return c:IsCode(700000000)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
