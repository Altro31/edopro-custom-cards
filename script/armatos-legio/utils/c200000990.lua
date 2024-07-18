-- Constants
CARDS_A_LEGIO = 0x1789
CARD_JUDGEARROWS = 511009503
CARD_A_COLOSSEUM = 200000055

-- Functions

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

--------------------------------------------