local Register = {}
local Object = {}

local register_meta = {
	__mode = 'k',

	__newindex = function(self, key, value)		
		if type(key) ~= "userdata" then
			return error('key is not userdata')
		end

		if type(value) ~= "table" then
			return
		end
		
		rawset(self, key, value)
	end,
	
	__call = function(self, obj)
		
		-- if we already have the object in the register
		-- then return it
		if self[obj] then
			return self[obj]
		end
		
		local newRegisterObject = Object.new(obj)
		self[obj] = newRegisterObject
		
		return self[obj]
	end
}

Object.__index = function(self, key)
	-- First, check if it's a pre-defined method
	-- on the Object, **not the current object (self)**
	if Object[key] then
		return Object[key]
	end
	
	local RblxRef = self.RblxInstance[key]
	if not RblxRef then
		return
	end
	
	if type(RblxRef) == "function" then
		return function(g, v)
			local success, returnValue = pcall(RblxRef, self.RblxInstance, v)
			return returnValue
		end
	end
	
	return RblxRef
end

Object.__newindex = function(self, key, value)
	if type(key) ~= "string" then
		return error('key must be a string')
	end
	
	if type(value) == "function" then
		return rawset(self, key, value)
	end
	
	if type(value) == "table" and value.RblxInstance then
		value = value.RblxInstance
	end
	
	self.RblxInstance[key] = value
end

Object.AddMethod = function(self, name, func)
	rawset(self, name, func)
end

Object.new = function(obj)
	local newObject = {}
	newObject.RblxInstance = obj
	
	return setmetatable(newObject, Object)
end


setmetatable(Register, register_meta)

local game = Register(game)

function game:GetDataStore(name, scope)
	local DS = self:GetService('DataStoreService')
	return DS:GetDataStore(name, scope)
end

game:AddMethod('GetFromReplicatedStorage', function(self, name)
	local ReplicatedStorage = self:GetService('ReplicatedStorage')
	return ReplicatedStorage:FindFirstChild(name)
end)

game:AddMethod('GetFromServerStorage', function(self, name)
	local ServerStorage = self:GetService('ServerStorage')
	return ServerStorage:FindFirstChild(name)
end)

return Register
