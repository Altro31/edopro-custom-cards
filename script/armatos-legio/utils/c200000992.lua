-- AddALProtection
local function ALProtectionCondition(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(aux.ALWeapCon, tp, LOCATION_MZONE, 0, 1, nil, e:GetHandler())
end

function Card.AddALProtection(card)
    if not card then return end
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(ALProtectionCondition)
    e1:SetValue(aux.imval2)
    card:RegisterEffect(e1)
    return e1
end

-- Filter para los "Armatos Legio" cuando un monstruo de Enlace "Armatos Legio" los apunte
function Auxiliary.ALWeapCon(linkmonster,...)
	local cards={...}
	local check=true
	for _,tc in ipairs(cards) do
		if not linkmonster:GetLinkedGroup():IsContains(tc) then
			check=false
			break
		end
	end
	return linkmonster:IsLinkMonster() and linkmonster:IsSetCard(CARDS_A_LEGIO) and check
end

-- Condición de Target para los "Armatos Legio" cuando un monstruo de Enlace "Armatos Legio" los apunte
function Auxiliary.ALWeapTg(e,tc)
	local c=e:GetHandler()
	return tc:IsLinkMonster() and tc:IsSetCard(CARDS_A_LEGIO) and tc:GetLinkedGroup():IsContains(c)
end
