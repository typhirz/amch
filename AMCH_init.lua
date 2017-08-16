-- Arcane Conservation Helper
-- Made by Nicholas Porter

-- Defining some constants here
aura_env.ab_m_0 = 33000 -- Mana cost of a base arcane blast
aura_env.abar_m = 5500  -- Mana cost of arcane barrage
aura_env.gcd = 1.5      -- Base GCD length
aura_env.ab_c_b = 2.25  -- Base ABlast length
aura_env.am_c_b = 2     -- Base AM length
aura_env.cycle3 = 3     -- Cycle of 3 charges
aura_env.cycle4 = 4     -- See above

-- Rough approximation of the expected number of AMs per cycle
-- I only assumed the first batch of AMs could proc more AMs to
-- save time calculating. These are slight underestimates, which
-- is nice as it means you'll most likely end up with more AMs and
-- more mana than expected.
-- TODO: Calculate these on init.
function expam(num)
    if num == 3 then return 2.2 end 
    if num == 4 then return 2.8125 end
end

-- Mana cost of a 4x AB
aura_env.ab_m_4 = (aura_env.ab_m_0 + aura_env.ab_m_0 * (1.25 * 4))

-- This function calculates cast times based on haste
function casttime (c_b, haste)
    c = c_b /(1 + haste/100)
    return c
end

-- Calculates the mana cost of the 3 or 4 conserve cycle
function manacycle(num)
    local abmana = aura_env.ab_m_0
    local manacost = 0
    for i=0,num-1 do
        abmana = aura_env.ab_m_0 + (aura_env.ab_m_0 * 1.25 * i)
        manacost = manacost + abmana
    end
    manacost = manacost + aura_env.abar_m
    manacost = (math.floor(manacost/1000 + .5)*1000)
    return manacost
end

-- To prevent this function call happening every frame later.
aura_env.mana4 = manacycle(4)


-- Function that takes in the cycle number to simplify the code
-- in the display tab.
function cycle(num)
    
    -- Inits a variable that will count the seconds needed.
    local seconds = 0
    
    -- Iterates over the number of AC for ABlasts.
    for i=1,num do
        if tf then
            aura_env.ctf = i
        end
        seconds = seconds + casttime(aura_env.ab_c_b, aura_env.haste)*(1-0.05*aura_env.ctf)
    end
    
    -- Adds GCD and expected time for AM.
    seconds = seconds + casttime(aura_env.gcd, aura_env.haste) + expam(num) * (casttime(aura_env.am_c_b, aura_env.haste))
    
    -- Remaining mana after continuous cycles.
    rmcycle = aura_env.rm - (manacycle(num)/seconds - aura_env.mreg_b) * aura_env.EvRem
    
    return rmcycle
    
end
