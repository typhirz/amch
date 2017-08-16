-- This file is everything that is ran continuously,
-- e.g. once per frame during combat.
-- See init.lua for definitions.

function()
    
    -- Defines the remaining cooldown on evocation
    local EvCharges,_,_,EvDur = GetSpellCharges("Evocation")
    local EvStart = GetSpellCooldown("Evocation") or 0
    
    -- An early out to prevent errors if someone loads this 
    -- when not an arcane mage
    if not EvDur then return "You aren't an arcane mage!" end
    
    aura_env.EvRem = -(GetTime() - (EvStart + EvDur))
    aura_env.EvRem = (math.floor(aura_env.EvRem*10))/10
    
    -- Effectively, if evocation is ready, return immediately
    if EvCharges >= 1 then
        aura_env.EvRem = 0
        return "Spend your mana!"
    end
    
    aura_env.haste = GetHaste() -- Haste
    _,aura_env.mreg_b = GetPowerRegen() -- Mana Regen
    aura_env.rm = UnitPower("player") -- Remaining Mana
    
    -- TF is temporal flux. If you have it, then tf is true and ctf
    -- will be non-zero later
    local tf = false
    aura_env.ctf = 0
    if IsTalentSpell(234302, "spell") then
        tf = true   
    end
    
    -- We begin the calculations here, starting with this call to
    -- calculate remaining mana after a 4 cycle.
    local rmcycle4 = cycle(aura_env.cycle4)
    
    -- If you have plenty of mana, then checks if you have enough to
    -- cast a 4x AB and still be above the 4 cycle breakpoint. If so,
    -- then returns.
    if rmcycle4 > aura_env.mana4 then
        local rmafter = rmcycle4 - aura_env.mana4
        rmafter = rmafter / aura_env.ab_m_4
        if rmafter > 1 then
            rmafter = math.floor(rmafter)
            return "Cast "..rmafter.." extra full AB"
        end
    end
    
    -- If your remaining mana is very low, less than 1.5x a 4xAB,
    -- then returns that you should use the 3 AC cycle. 
    if aura_env.rm < aura_env.ab_m_4 * 1.5 then
        return "Use 3 AC cycle"
    end
    
    -- If you'd have 10% mana remaining after using 4 cycles until
    -- EV, then returns.
    if rmcycle4 > .1 * UnitPowerMax("player") then
        return "Use 4 AC cycle"
    end
    
    -- Second calculation, for 3 cycle. This is placed here and not
    -- earlier to prevent unnecessary calculations (why calculate if
    -- you know you'll use 4 cycles?).
    local rmcycle3 = cycle(aura_env.cycle3)
    
    -- If you can sustain 3 cycle, then do so.
    if rmcycle3 > .1 * UnitPowerMax("player") then
        return "Use 3 AC cycle"
    end
    
    -- Fall back on 2 AC cycle if all else fails.
    return "Use 2 AC cycle"
end
