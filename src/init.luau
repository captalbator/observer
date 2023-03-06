--[[
    Copyright (c) 2023 captalbator

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local defaultTagAncestors = { Workspace }

local function ObserveTag(tagName: string, callback: (Instance) -> (() -> ()), instAncestors: { Instance }?)
	local managed = {}

	local ancestors = instAncestors or defaultTagAncestors

	local taggedInstances = CollectionService:GetTagged(tagName)
	for _, instance in taggedInstances do
		if ancestors then
			for _, ancestor in ancestors do
				if instance:IsDescendantOf(ancestor) then
					managed[instance] = callback(instance)
				end
			end
		end
	end

	CollectionService:GetInstanceAddedSignal(tagName):Connect(function(instance)
		if ancestors then
			for _, ancestor in ancestors do
				if instance:IsDescendantOf(ancestor) then
					managed[instance] = callback(instance)
				end
			end
		end
	end)

	CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
		if managed[instance] then
			managed[instance]()
			managed[instance] = nil
		end
	end)
end

local function ObserveAttribute<T>(instance: Instance, attributeName: string, callback: (T) -> ())
	local currentValue = instance:GetAttribute(attributeName)
	if currentValue then
		callback(currentValue)
	end

	local attributeChangedSignal = instance:GetAttributeChangedSignal(attributeName):Connect(function()
		local changedValue = instance:GetAttribute(attributeName)
		if changedValue then
			callback(changedValue)
		end
	end)

	local ancestryChangedSignal
	ancestryChangedSignal = instance.AncestryChanged:Connect(function()
		if instance.Parent == nil then
			-- NOTE(capt): Cleanup
			attributeChangedSignal:Disconnect()
			ancestryChangedSignal:Disconnect()
		end
	end)
end

-- Ideas for further functions:
-- ObserveInstance - watch for instance change? watch for instance destroyed?
-- Maybe a function for creating a custom observe? mapping?

return {
	ObserveTag = ObserveTag,
	ObserveAttribute = ObserveAttribute,
}
