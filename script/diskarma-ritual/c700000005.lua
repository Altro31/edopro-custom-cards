local s, id = GetID()
function s.initial_effect(c)
    --Activate
    local e1 = Ritual.AddProcGreater({ handler = c, filter = s.ritualfil, location = LOCATION_EXTRA, matfilter = s
    .matfil })
end

s.listed_names = { 700000000 }

function s.ritualfil(c)
    return c:IsCode(700000000) and c:IsRitualMonster()
end

function s.matfil(c)
	return c:IsFaceup()
end
