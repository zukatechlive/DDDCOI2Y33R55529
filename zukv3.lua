local zukv3 = {}
local originalDecompile = decompile
function zukv3.cleanScript(uncleanScript, custom_url)
    local HttpService = game:GetService("HttpService")
    local url = custom_url or "http://localhost:5000/fix_script"
    local requestBody = {
        script = uncleanScript
    }
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local jsonBody = HttpService:JSONEncode(requestBody)
    local success, response = pcall(function()
        local result = request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = jsonBody
        })
        if result and result.StatusCode == 200 then
            local resultData = HttpService:JSONDecode(result.Body)
            return resultData.fixed_script
        else
            warn("Request failed with status code: " .. (result and result.StatusCode or "unknown"))
            warn("Response body: " .. (result and result.Body or "no response body"))
        end
    end)
    if not success then
        warn("An error occurred: " .. response)
    end
    return uncleanScript
end
function zukv3.decompile(scr, boolval, custom_url)
    local success, srcScript = pcall(function()
        return originalDecompile(scr)
    end)
    if success and boolval then
        success, srcScript = pcall(function()
            return zukv3.cleanScript(srcScript, custom_url)
        end)
        if not success then
            warn("Clean Script Error: " .. srcScript)
        end
    elseif not success then
        warn("Decompiler Error: " .. srcScript)
    end
    return srcScript
end
return zukv3
