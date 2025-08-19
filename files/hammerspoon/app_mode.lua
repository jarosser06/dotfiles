local M = {}

function M.new(name, config)
    local mode = {
        name = name,
        config = {
            hotkey = config.hotkey,
            apps = config.apps or {},
            showLogs = config.showLogs or false,
            windowLayout = config.windowLayout or nil,
            onEnable = config.onEnable or nil,
            onDisable = config.onDisable or nil
        }
    }
    
    local function log(message)
        if mode.config.showLogs then
            print("[" .. mode.name .. "] " .. message)
        end
    end
    
    local function appExists(appName)
        local app = hs.application.find(appName)
        if app then return true end
        
        local commonPaths = {
            "/Applications/" .. appName .. ".app",
            "/System/Applications/" .. appName .. ".app"
        }
        
        for _, path in ipairs(commonPaths) do
            if hs.fs.attributes(path) then
                return true
            end
        end
        
        return false
    end
    
    function mode.enable()
        log("🚀 Activating " .. mode.name .. " Mode...")
        
        local openedApps = {}
        local skippedApps = {}
        
        -- Open apps
        for _, app in ipairs(mode.config.apps) do
            if appExists(app) then
                log("📱 Opening " .. app .. "...")
                hs.application.launchOrFocus(app)
                table.insert(openedApps, app)
            else
                log("⚠️  Skipping " .. app .. " (not installed)")
                table.insert(skippedApps, app)
            end
        end
        
        -- Custom enable logic
        if mode.config.onEnable then
            mode.config.onEnable()
        end
        
        -- Show notification after everything loads
        hs.timer.doAfter(2, function()
            -- Apply window layout if configured
            if mode.config.windowLayout then
                mode.config.windowLayout()
            end
            
            local message = ""
            if #openedApps > 0 then
                message = table.concat(openedApps, ", ") .. " ready"
            end
            if #skippedApps > 0 then
                if message ~= "" then message = message .. "\n" end
                message = message .. "Skipped: " .. table.concat(skippedApps, ", ")
            end
            
            hs.notify.new({
                title = "🎯 " .. mode.name .. " Mode Enabled",
                informativeText = message,
                autoWithdraw = true
            }):send()
            log("✅ " .. mode.name .. " Mode activated!")
        end)
    end
    
    function mode.disable()
        if mode.config.onDisable then
            mode.config.onDisable()
        end
        
        hs.notify.new({
            title = "🔄 " .. mode.name .. " Mode Disabled",
            informativeText = "Session ended",
            autoWithdraw = true
        }):send()
    end
    
    function mode.init()
        hs.hotkey.bind(mode.config.hotkey[1], mode.config.hotkey[2], mode.enable)
        print("🎯 " .. mode.name .. " Mode loaded (" .. 
              table.concat(mode.config.hotkey[1], "+") .. "+" .. mode.config.hotkey[2] .. ")")
    end
    
    return mode
end

return M
