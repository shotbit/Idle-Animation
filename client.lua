-- Credit validation logic
local function validateCredit()
    print("Made by Shotbit")
    print("^2[IdleAnim]^7 Made by Shotbit")
end

-- Call to validate credit (kept for credit display)
validateCredit()

local idleTime = 0
local idleThreshold = 10 -- seconds until idle triggers
local animDict = "move_m@generic_idles@std"
local animNames = {"idle_a", "idle_b", "idle_c", "idle_d"}
local isIdlePlaying = false
local checkInterval = 300 -- 1 second idle check
local animationEnabled = true -- Flag to control animation state

-- Load animation dictionary efficiently
local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

-- Play a random idle animation
local function playIdleAnimation()
    if isIdlePlaying or not animationEnabled then return end
    local ped = PlayerPedId()
    loadAnimDict(animDict)
    local anim = animNames[math.random(#animNames)]
    TaskPlayAnim(ped, animDict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    isIdlePlaying = true
end

-- Stop the idle animation
local function stopIdleAnimation()
    if isIdlePlaying then
        ClearPedTasks(PlayerPedId())
        isIdlePlaying = false
    end
end

-- Check for any keyboard input
local function isPlayerActive()
    for i = 0, 254 do
        if IsControlJustPressed(0, i) then
            return true
        end
    end
    return false
end

-- Monitor player activity every second
CreateThread(function()
    while true do
        Wait(checkInterval)

        if isPlayerActive() then
            idleTime = 0
            stopIdleAnimation()
        else
            idleTime = idleTime + 1
            if idleTime >= idleThreshold then
                playIdleAnimation()
            end
        end
    end
end)

-- Command to toggle animation on and off
RegisterCommand("animationoff", function()
    animationEnabled = false
    stopIdleAnimation()
    print("Idle animation has been turned off.")
end, false)

RegisterCommand("animationon", function()
    animationEnabled = true
    print("Idle animation has been turned on.")
end, false)
