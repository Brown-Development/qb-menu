local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject() end)

local theseOptions = nil 
local thisHeader = nil
local focus = false 

local function toggleControls(toggle)
    focus = toggle 

    if not focus then 
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({ show = false })
        return 
    end

    if focus then 
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
    
        Citizen.CreateThread(function()
            while focus do  
                Citizen.Wait(0)
                SetPauseMenuActive(false)
            end
        end)
    
        Citizen.CreateThread(function()
            while focus do 
                Citizen.Wait(0) 
    
                if not config.allowMovement then 
                    DisableControlAction(0, 30, true)
                    DisableControlAction(0, 31, true)
                end
                
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 59, true)
                DisableControlAction(0, 60, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 75, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 24, true)
            end
        end)
    end
end

local function openMenu (data)

    toggleControls (true)

    
    local header, options = {}, {}

    for _, item in ipairs(data) do 
        if item.isMenuHeader then 
            header = item 
        else
            options[#options + 1] = item  
        end

    end

    thisHeader = header
    theseOptions = options


    if header.params and header.params.event and type(header.params.event) == 'function' then 
        header.params.event = nil 
    end

    for i = 1, #options do 
        local option = options[i]
        if option.params and option.params.event and type(option.params.event) == 'function' then  
            option.params.event = nil 
        end
    end

    SendNUIMessage({
        show = true,
        header = header,
        options = options,
    })


end

local function onClick (data, cb)

    toggleControls (false)


    local isHeader = data.isHeader
    local index = data.index 
    local params = data.params

    if params.event then
        if params.event.isServer then
            TriggerServerEvent(params.event, params.args)
        elseif params.event.isCommand then
            ExecuteCommand(params.event)
        elseif params.event.isQBCommand then
            TriggerServerEvent('QBCore:CallCommand', params.event, params.args)
        elseif params.event.isAction then
            if isHeader then 
                thisHeader.params.event(params.args)
            else
                theseOptions[index + 1].params.event(params.args)
            end
        else
            TriggerEvent(params.event, params.args)
        end

    end

    thisHeader = nil
    theseOptions = nil

    cb('ok')


end

local function closeMenu ()
    toggleControls (false)

    thisHeader = nil
    theseOptions = nil
end

local function showHeader(header)
    toggleControls (true)

    thisHeader = header 

    SendNUIMessage({
        show = true,
        header = header,
        options = {},
    })

end


RegisterNetEvent('qb-menu:client:closeMenu', closeMenu)
RegisterNetEvent('qb-menu:closeMenu', closeMenu)

RegisterNUICallback('onClick', onClick)
RegisterNUICallback('menuCheckCallback', menuCheckCallback)

exports('openMenu', openMenu)
exports('closeMenu', closeMenu)
exports('showHeader', showHeader)
