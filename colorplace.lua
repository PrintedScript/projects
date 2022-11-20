local BotMode = true
local TargetColor1 = Color3.fromRGB(0,0,0)
local TargetColor2 = Color3.fromRGB(242,47,255)
local VoidRadius = 98
local X,Z = 200,200
if not game.Loaded then
	game.Loaded:wait()
end
task.wait(5)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BlockCache = {}
local AllowedBlocks = {}

local SelectionBlock = Instance.new("Part",workspace)
SelectionBlock.Anchored = true
SelectionBlock.Size = Vector3.new(1.2,1.2,1.2)
SelectionBlock.Transparency = 0.7
SelectionBlock.Material = Enum.Material.Neon
SelectionBlock.CanCollide = false
SelectionBlock.Color = Color3.new(1,0,0)


if BotMode then
    while true do
        local success = pcall(function()
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
            UserSettings():GetService("UserGameSettings").MasterVolume = 0
            settings():GetService("RenderSettings").QualityLevel = Enum.QualityLevel.Level01
            RunService:Set3dRenderingEnabled(false)
            ReplicatedFirst:RemoveDefaultLoadingScreen()
            sethiddenproperty(game:GetService("Lighting"), "Technology", Enum.Technology.Compatibility)
            --StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
            setfpscap(15)

            local ScreenGui = Instance.new("ScreenGui",game:GetService("CoreGui"))
            local TextLabel = Instance.new("TextLabel",ScreenGui)
        end)
        if success then
            break
        else
            task.wait(1)
        end
    end
end

local ColorList = require(ReplicatedStorage:WaitForChild("Shared").Config).Colors
local ChunksFolder = workspace:WaitForChild("Chunks")
local ChangeColorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeColor")
local PlayerGui = LocalPlayer.PlayerGui

local PlacePlaneGui = PlayerGui:WaitForChild("PlacePane")
local PlaceCountText = PlacePlaneGui.PlacePane.wrapper.container.PlaceCount.wrapper.container.placeCount
local function GetPlayerCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
end

local function TravelToCFrame(TargetCFrame)
    local PlayerCharacter = GetPlayerCharacter()
    if PlayerCharacter then
        PlayerCharacter.Humanoid.WalkToPoint = TargetCFrame.Position
        repeat
            task.wait(0.1)
            PlayerCharacter.Humanoid.WalkToPoint = TargetCFrame.Position
        until ( PlayerCharacter.HumanoidRootPart.Position - TargetCFrame.Position ).Magnitude < 5
    end
end

local function findClosestColor(color)
    -- thanks daddy wally 😘
    local list = {}

    for i = 1, #ColorList do
        local result = ColorList[i]
        
        -- https://stackoverflow.com/questions/1847092/given-an-rgb-value-what-would-be-the-best-way-to-find-the-closest-match-in-the-d
        -- https://web.archive.org/web/20100316195057/http://www.dfanning.com/ip_tips/color2gray.html

        local r1, g1, b1 = color.r, color.g, color.b
        local r2, g2, b2 = result.r, result.g, result.b

        local rf, gf, bf = 0.3, 0.59, 0.11

        local distance = (
            ((r2-r1) * rf) ^2 +
            ((g2-g1) * gf) ^2 +
            ((b2-b1) * bf) ^2
        )^0.5

        list[#list + 1] = { result, distance }
    end

    table.sort(list, function(a, b)
        return a[2] < b[2]
    end)

    return list[1][1]
end

local function DistanceFromStart(XPos,ZPos)
    return math.sqrt( (X-XPos)^2 + (Z-ZPos)^2)
end

local function IsPositionAllowed(XPos,ZPos)
    if AllowedBlocks[tostring(XPos)..":"..tostring(ZPos)] ~= nil then
        return AllowedBlocks[tostring(XPos)..":"..tostring(ZPos)]
    end
    local Distance = DistanceFromStart(XPos,ZPos)
    local IsAllowed = Distance <= VoidRadius
    AllowedBlocks[tostring(XPos)..":"..tostring(ZPos)] = IsAllowed
    return IsAllowed
end

local function GetColorIndex(color)
    local ClosestColor = findClosestColor(color)
    for i = 1,#ColorList do
        if ColorList[i] == ClosestColor then
            return i 
        end
    end
    return 1
end

local function FindBlockFromCords(X,Z)

    if BlockCache[tostring(X)..":"..tostring(Z)] then
        return BlockCache[tostring(X)..":"..tostring(Z)]
    end

    local ChunkIndex = 1
    local XPos = X
    local ZPos = Z
    while true do
        if ZPos > 25 then
            ZPos -= 25
            ChunkIndex += 1
        else
            break
        end
    end
    
    while true do
        if XPos > 25 then
            XPos -= 25
            ChunkIndex += 16
        else
            break
        end
    end
    local BlockOffset = (XPos - 1) * 25
    local BlockPos = BlockOffset + ZPos
    BlockCache[tostring(X)..":"..tostring(Z)] = ChunksFolder[tostring(ChunkIndex)][tostring(BlockPos)]
    return ChunksFolder[tostring(ChunkIndex)][tostring(BlockPos)]
end

local function PlaceColorAtCords(RGBColor,XPos,ZPos)
    TravelToCFrame(CFrame.new(Vector3.new(XPos,3.025,ZPos)))
    local ColorIndex = GetColorIndex(RGBColor)
    local TargetBlock = FindBlockFromCords(XPos,ZPos)
    ChangeColorRemote:FireServer(
        TargetBlock,
        ColorIndex
    )
end

local function GetColorOfBlock(XPos,ZPos)
    local TargetBlock = FindBlockFromCords(XPos,ZPos)
    return TargetBlock.Color
end

local function GetRemainingPlaces()
    local count = PlaceCountText.Text:split(" ")[1]
    return tonumber(count) 
end

local BlockColorCache = {}
local function FindTargetColor( XPos, ZPos )
	if BlockColorCache[tostring(XPos)..":"..tostring(ZPos)] ~= nil then return BlockColorCache[tostring(XPos)..":"..tostring(ZPos)] end
	local TargetColor = TargetColor1
    if XPos % 2 == 0 then
        if ZPos % 2 == 0 then
            TargetColor = TargetColor1
        else
            TargetColor = TargetColor2
        end
    else
        if ZPos % 2 == 0 then
            TargetColor = TargetColor2
        else
            TargetColor = TargetColor1
        end
    end
	BlockColorCache[tostring(XPos)..":"..tostring(ZPos)] = TargetColor
	return TargetColor
end
--[[
for i = 1, 5 do
    for v = 1, 5 do
       TravelToCFrame(CFrame.new(Vector3.new(i*80,3.025,v*80)))
       task.wait(0.05)
    end
end
TravelToCFrame(CFrame.new(Vector3.new(math.random(0,400),3.025,math.random(0,400))))
]]
TravelToCFrame(CFrame.new(Vector3.new(200,3.025,200)))
local StopThread = false

while true do
    local RemainingPlaces = GetRemainingPlaces()
    local success, errmsg = pcall(function()
    coroutine.wrap(function()
    if RemainingPlaces <= 0 then
        task.wait(math.random(600,800)/1000)
    else
            StopThread = true
            StopThread = false
            local success = pcall(function()
                local CurrentX = 200
                local CurrentZ = 200
                while true do
                    local SelectedBlock = GetColorOfBlock(CurrentX,CurrentZ)
                    local TargetColor
                    if DistanceFromStart(CurrentX,CurrentZ) <= VoidRadius - 5 then
                        TargetColor = FindTargetColor(CurrentX,CurrentZ)
                    else
                        TargetColor = Color3.fromRGB(0,0,0)
                    end
                    if SelectedBlock ~= TargetColor then
                        if IsPositionAllowed(CurrentX,CurrentZ) then
                            SelectionBlock.Position = Vector3.new(CurrentX,0.8,CurrentZ)
                            PlaceColorAtCords(TargetColor,CurrentX,CurrentZ)
                        end
                        break
                    end
                    CurrentX -= math.random(-1,1)
                    CurrentZ -= math.random(-1,1)
                    task.wait(0.005)
                    if StopThread then
                        StopThread = false
                        break
                    end
                end
        end)
    end
end)()
    end)
    if not success then warn(errmsg) end
    task.wait(math.random(600,800)/1000)
end
