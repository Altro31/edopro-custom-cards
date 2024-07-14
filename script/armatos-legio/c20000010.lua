--Armatos Legio Scutum

local s, id = GetID()
---@diagnostic disable-next-line: duplicate-set-field
function s.initial_effect(c)
	c:AddALProtection()
	--effect protection
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE, 0)
	e1:SetTarget(aux.ALWeapTg)
	e1:SetValue(s.indval1)
	c:RegisterEffect(e1)
	--battle protection
	local e2 = e1:Clone()
	e2:SetValue(s.indval2)
	c:RegisterEffect(e2)
end

s.listed_series = { CARDS_A_LEGIO }
function s.indval1(e, re, r, rp)
	if r & REASON_BATTLE ~= 0 then
		return 1
	else
		return 0
	end
end

function s.indval2(e, re, r, rp)
	if r & REASON_EFFECT ~= 0 then
		return 1
	else
		return 0
	end
end
