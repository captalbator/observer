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
-- Observe - observes a multitude of values depending on their type?
-- Maybe a function for creating a custom observe? mapping?

return {
	ObserveTag = ObserveTag,
	ObserveAttribute = ObserveAttribute,
}
