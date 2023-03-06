# Observer

A module for observing tagged instances and attributes.

# Installation

Install using wally: `Observer = "captalbator/observer@0.1.0"`

# Example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observer = require(ReplicatedStorage.Packages.Observer)

Observer.ObserveTag("Rotate", function(instance)
    local startingCFrame = instance.CFrame

    local rotationSpeed = 1
    -- ObserveAttribute runs once when called and again every time the attribute changes
    Observer.ObserveAttribute(instance, "RotationSpeed", function(newSpeed: number)
        rotationSpeed = newSpeed
    end)

    local rotateConnection = RunService.RenderStepped:Connect(function()
        instance.CFrame = startingCFrame * CFrame.Angles(0, (os.clock() % 6.28) * rotationSpeed, 0)    
    end)

    -- Cleanup function, called when the instance is removed
    return function()
        rotateConnection:Disconnect()
    end
end, { Workspace }) -- The third argument is optional and defaults to { Workspace }

```
