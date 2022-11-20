--[[
    ERLC AutoSolver
    Last updated: 20 / 11 / 2022 ( or 11 / 20 / 2022 in freedom time )

    Made by TheSynapseGuy on V3rmillion
    Supported Robberies
        - Lockpick
        - Drill
        - ATM Hack
        - Safe ( Sometimes work, can't test it that much because of how rare it is to get a Safe when robbing a house )
    
    Please do not modify this script without my permission, or redistribute it without any credit to me.
]]

-- Do not touch the code below this line
local Players = game:GetService("Players"); local LocalPlayer = Players.LocalPlayer; local ReplicatedStorage = game:GetService("ReplicatedStorage"); local RunService = game:GetService("RunService");
rconsolename("ERLC AutoSolver | TheSynapseGuy | V3rmillion")
local ColorIndex = {BLACK = 30,RED = 31,GREEN = 32,YELLOW = 33,BLUE = 34,MAGENTA = 35,CYAN = 36,LIGHT_GRAY = 37,DARK_GRAY = 90,LIGHT_RED = 91,LIGHT_GREEN = 92,LIGHT_YELLOW = 93,LIGHT_BLUE = 94,LIGHT_MAGENTA = 95, LIGHT_CYAN = 96, WHITE = 97, B = 1, UNDERLINE = 4, N_UNDERLINE = 24, NEGATIVE = 7, POSITIVE = 27, DEFAULT = 0}
local function rcolorprint( message ) local SeperatedContents = string.split(message, "@@") for i, v in pairs(SeperatedContents) do if i % 2 == 0 then rconsoleprint("\27["..ColorIndex[string.upper(v)].."m") else rconsoleprint(v) end end end
local logging = {}
logging.info = function( message ) rcolorprint("@@LIGHT_GRAY@@[@@BLUE@@INFO@@LIGHT_GRAY@@] @@WHITE@@"..message.."\n") end
logging.warn = function( message ) rcolorprint("@@LIGHT_GRAY@@[@@YELLOW@@WARN@@LIGHT_GRAY@@] @@WHITE@@"..message.."\n") end
logging.error = function( message ) rcolorprint("@@LIGHT_GRAY@@[@@RED@@FAIL@@LIGHT_GRAY@@] @@WHITE@@"..message.."\n") end

logging.info("ERLC AutoSolver made by TheSynapseGuy on V3rm")
logging.warn("This is a simple script that will finish the robbery puzzles for you. This was last updated on @@B@@@@BLUE@@20/11/2022@@DEFAULT@@")
logging.info("Always keep your cursor inside the window when using this script. If you don't, the script will not work.")
logging.info("If you have any issues, please contact me on V3rm @@RED@@ONLY@@DEFAULT@@ if this script has been updated in the past month.")
local function hookgamemenu(child)
    local success, message = pcall(function()
        if child.Name == "GameMenus" and child:IsA("ScreenGui") then
            logging.info("Hooked onto GameMenu")
            local GameMenu = child
            local HackingUI = GameMenu:WaitForChild("ATM"):WaitForChild("Hacking")
            local LockpickUI = GameMenu:WaitForChild("Lockpick")
            local RobJewelryUI = GameMenu:WaitForChild("RobJewelry")
            local SafeUI = GameMenu:WaitForChild("Safe")

            local CycleFrame = HackingUI:WaitForChild("CycleFrame")
            local SelectingCodeTextLabel = HackingUI:WaitForChild("SelectingCode")

            local function MoveCursorToCenter()
                local ScreenSize = GameMenu.AbsoluteSize
                local X = math.floor(ScreenSize.X / 2)
                local Y = math.floor(ScreenSize.Y / 2)

                mousemoveabs(X,Y)
            end
            -- Listen for ATM hack start
            CycleFrame.DescendantAdded:Connect(function( NewDescendant )
                local success, message = pcall(function()
                    if NewDescendant:IsA("TextLabel") then
                        NewDescendant:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                            if NewDescendant.Text == SelectingCodeTextLabel.Text and NewDescendant.BackgroundColor3 ~= Color3.fromRGB(0,0,0) then
                                logging.info("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@ATM@@LIGHT_GRAY@@] @@WHITE@@Found matching code: @@MAGENTA@@"..NewDescendant.Text)
                                MoveCursorToCenter()
                                mouse1click()
                            end
                        end)
                    end
                end)
                if not success then
                    logging.error("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@ATM@@LIGHT_GRAY@@] @@WHITE@@Error occured while hooking onto ATM label: @@RED@@"..message)
                end
            end)
            -- Listen for new Lockpick UI
            LockpickUI.ChildAdded:Connect(function(child)
                local success, message = pcall(function()
                    if child:IsA("Frame") and child.Name == "Pick" then
                        local LockNumber = 1
                        task.wait(0.2)
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_RED@@LOCKPICK@@LIGHT_GRAY@@] @@WHITE@@Detected Lockpick robbery, keep cursor in window.")
                        local StartTime = tick()
                        while true do
                            local TargetLock = child:WaitForChild(tostring(LockNumber))
                            local Half = TargetLock.Size.Y.Scale / 2

                            local LockPositionY = TargetLock.Position.Y.Scale
                            if math.abs(LockPositionY - 0.5) <= ( Half - 0.01 ) then
                                mouse1click()
                                logging.info("@@LIGHT_GRAY@@[@@LIGHT_RED@@LOCKPICK@@LIGHT_GRAY@@] @@WHITE@@Pin @@LIGHT_GRAY@@[@@LIGHT_GREEN@@"..tostring(LockNumber).."@@LIGHT_GRAY@@] @@WHITE@@finished, diff @@LIGHT_GRAY@@[@@LIGHT_MAGENTA@@"..tostring(math.abs(LockPositionY - 0.5)).."@@LIGHT_GRAY@@] @@WHITE@@min @@LIGHT_GRAY@@[@@LIGHT_CYAN@@"..tostring(Half - 0.01).."@@LIGHT_GRAY@@] @@WHITE@@")
                                if LockNumber >= 6 then
                                    logging.info("@@LIGHT_GRAY@@[@@LIGHT_RED@@LOCKPICK@@LIGHT_GRAY@@] @@WHITE@@Finished Lockpick robbery in @@CYAN@@"..tostring(tick() - StartTime).." @@WHITE@@seconds")
                                    break
                                end
                                LockNumber += 1
                            end

                            task.wait(0.0005)
                        end
                    end
                end)
                if not success then
                    logging.error("@@LIGHT_GRAY@@[@@LIGHT_RED@@LOCKPICK@@LIGHT_GRAY@@] @@WHITE@@Error occured while doing Lockpick: @@RED@@"..message)
                end
            end)
            -- Listening for drill
            RobJewelryUI.ChildAdded:Connect(function( child )
                local success, message = pcall(function()
                    if child.Name == "Drill" and child:IsA("Frame") then
                        -- Start drilling
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_BLUE@@DRILL@@LIGHT_GRAY@@] @@WHITE@@Jewellery robbery detected waiting for user to start drilling")
                        repeat RunService.RenderStepped:Wait() until child.Bar.Position ~= UDim2.new(0.5,-2,0,0)
                        -- Keep bar in center until frame disappears
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_BLUE@@DRILL@@LIGHT_GRAY@@] @@WHITE@@Starting, keep cursor in window")
                        repeat
                            if child.Bar.Position.X.Scale < 0.5 then
                                mouse1press()
                                repeat
                                    task.wait(0.0005)
                                until child.Bar.Position.X.Scale > 0.5
                                mouse1release()
                            end
                            task.wait(0.0005)
                        until RobJewelryUI.Position ~= UDim2.new(0.5, 0, 0.5, 0)
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_BLUE@@DRILL@@LIGHT_GRAY@@] @@WHITE@@Jewellery robbery finished")
                    end
                end)
                if not success then
                    logging.error("@@LIGHT_GRAY@@[@@LIGHT_BLUE@@DRILL@@LIGHT_GRAY@@] @@WHITE@@Error occured while doing Jewellry robbery: @@RED@@"..message)
                end
            end)
            -- Listening for safe
            SafeUI.ChildAdded:Connect(function( child )
                local success, message = pcall(function()
                    if child:IsA("Frame") and child.Name == "Safe" then
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@SAFE@@LIGHT_GRAY@@] @@WHITE@@Safe robbery detected, starting")
                        local StartTime = tick()
                        -- Listen for dial rotation
                        task.wait(2)
                        repeat
                            local success, message = pcall(function()
                                local Rotation = child.Dial.Rotation
                                local TargetNumber = tonumber(SafeUI["Top2"]["TargetNum"].Text)

                                local CurrentNumber = (math.abs(Rotation) % 360)/36*10
                                if Rotation > 0 then
                                    CurrentNumber = 100 - CurrentNumber
                                end
                                if math.abs(CurrentNumber - TargetNumber) <= 1 then
                                    MoveCursorToCenter()
                                    mouse1click()
                                    logging.info("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@SAFE@@LIGHT_GRAY@@] @@WHITE@@Cracked safe number landed at @@LIGHT_GRAY@@[@@GREEN@@"..tostring(CurrentNumber).."@@LIGHT_GRAY@@] @@WHITE@@target @@LIGHT_GRAY@@[@@GREEN@@"..tostring(TargetNumber).."@@LIGHT_GRAY@@]@@WHITE@@ raw rotation @@LIGHT_GRAY@@[@@GREEN@@"..tostring(Rotation).."@@LIGHT_GRAY@@]@@WHITE@@")
                                    task.wait(1)
                                end
                            end)
                            if not success then
                                logging.error("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@SAFE@@LIGHT_GRAY@@] @@WHITE@@Error occured while doing Safe robbery: @@RED@@"..message)
                            end
                            task.wait(0.0005)
                        until SafeUI.Position ~= UDim2.new(0.5, 0, 0.5, 0)
                        logging.info("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@SAFE@@LIGHT_GRAY@@] @@WHITE@@Completed safe robbery in @@CYAN@@"..tostring(tick() - StartTime).." @@WHITE@@seconds")
                    end
                end)
                if not success then
                    logging.error("@@LIGHT_GRAY@@[@@LIGHT_GREEN@@SAFE@@LIGHT_GRAY@@] @@WHITE@@Error occured while doing Safe robbery: @@RED@@"..message)
                end
            end)
        end
    end)
    if not success then
        logging.error("Error occured while hooking onto gamemenu: @@RED@@"..message)
    end
end
hookgamemenu(LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameMenus"))
LocalPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(hookgamemenu)
logging.info("Waiting for robbery")
