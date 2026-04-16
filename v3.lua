local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local TweenService: TweenService = game:GetService("TweenService")
local Workspace: Workspace = game:GetService("Workspace")

local LocalPlayer: Player = Players.LocalPlayer
local Camera: Camera = Workspace.CurrentCamera

local CONFIG = {
    MAX_PARTS = 1000,
    CLAIM_SPEED = 50,
    VELOCITY_MAGNITUDE = 650,
    MAX_FORCE = 1e9,
}

local SessionState = {
    Active = false,
    TargetPlayer = nil,
    ManagedParts = {},
    Connections = {},
    OriginalCFrame = nil,
    IsSweeping = false
}

local function SetHiddenProperty(instance: Instance, property: string, value: any)
    pcall(function()
        sethiddenproperty(instance, property, value)
    end)
end

local function ToggleCharacterCollision(state: boolean)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end

local function GhostSweep()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or SessionState.IsSweeping then return end

    SessionState.IsSweeping = true
    SessionState.OriginalCFrame = hrp.CFrame
    
    ToggleCharacterCollision(false)

    local unanchoredParts = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(char) then
            if not v.Parent:FindFirstChildOfClass("Humanoid") then
                table.insert(unanchoredParts, v)
            end
        end
    end

    for i = 1, #unanchoredParts, CONFIG.CLAIM_SPEED do
        if not SessionState.Active then break end
        
        local part = unanchoredParts[i]
        if part and part.Parent then
            hrp.CFrame = part.CFrame
            SetHiddenProperty(LocalPlayer, "SimulationRadius", math.huge)
            pcall(function() part:SetNetworkOwner(LocalPlayer) end)
        end
        RunService.Heartbeat:Wait()
    end

    hrp.CFrame = SessionState.OriginalCFrame
    ToggleCharacterCollision(true)
    SessionState.IsSweeping = false
end

local function CleanPart(part: BasePart)
    local data = SessionState.ManagedParts[part]
    if not data then return end
    if data.Connection then data.Connection:Disconnect() end
    pcall(function()
        if part:FindFirstChild("BH_Velocity") then part.BH_Velocity:Destroy() end
    end)
    SessionState.ManagedParts[part] = nil
end

local function ApplyPhysicsForce(part: BasePart)
    if not part:IsA("BasePart") or part.Anchored or SessionState.ManagedParts[part] then return end
    if part.Parent:FindFirstChildOfClass("Humanoid") or part:IsDescendantOf(LocalPlayer.Character) then return end

    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "BH_Velocity"
    velocity.MaxForce = Vector3.new(CONFIG.MAX_FORCE, CONFIG.MAX_FORCE, CONFIG.MAX_FORCE)
    velocity.Velocity = Vector3.zero
    velocity.Parent = part

    local connection = RunService.Heartbeat:Connect(function()
        if not SessionState.Active or not part.Parent or part.Anchored then
            CleanPart(part)
            return
        end

        pcall(function()
            part:SetNetworkOwner(LocalPlayer)
        end)

        if SessionState.TargetPlayer and SessionState.TargetPlayer.Character then
            local root = SessionState.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                velocity.Velocity = (root.Position - part.Position).Unit * CONFIG.VELOCITY_MAGNITUDE
            end
        end
    end)

    SessionState.ManagedParts[part] = {
        Connection = connection,
        Velocity = velocity
    }
end

local function ToggleState(enabled: boolean)
    SessionState.Active = enabled
    if not enabled then
        for part, _ in pairs(SessionState.ManagedParts) do
            CleanPart(part)
        end
    else
        task.spawn(function()
            GhostSweep()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then ApplyPhysicsForce(v) end
            end
        end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ghost_Architect"
ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 150)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(45, 45, 45)
Stroke.Thickness = 1

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "GHOST SWEEP FLINGER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 14

local Input = Instance.new("TextBox", Main)
Input.Size = UDim2.new(0.9, 0, 0, 35)
Input.Position = UDim2.new(0.05, 0, 0.3, 0)
Input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Input.PlaceholderText = "Target Username..."
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.Code
Input.TextSize = 12
Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size = UDim2.new(0.9, 0, 0, 40)
ActionBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
ActionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ActionBtn.Text = "SWEEP & INITIATE"
ActionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ActionBtn.Font = Enum.Font.Code
ActionBtn.TextSize = 13
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 4)

ActionBtn.MouseButton1Click:Connect(function()
    if not SessionState.Active then
        local targetName = Input.Text:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.Name:lower():find(targetName) or p.DisplayName:lower():find(targetName)) then
                SessionState.TargetPlayer = p
                break
            end
        end

        if SessionState.TargetPlayer then
            ActionBtn.Text = "HALT SYSTEM"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
            ToggleState(true)
        end
    else
        ActionBtn.Text = "SWEEP & INITIATE"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleState(false)
    end
end)

table.insert(SessionState.Connections, RunService.Heartbeat:Connect(function()
    SetHiddenProperty(LocalPlayer, "SimulationRadius", math.huge)
end))
