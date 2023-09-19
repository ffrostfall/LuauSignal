--!strict
local typings = require(script.typings)

local freeThread: thread?

local function passer(fn: (...unknown) -> (), ...): ()
	local acquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = acquiredThread
end

local function yielder(): ()
	while true do
		passer(coroutine.yield())
	end
end

--[=[
	@class Signal
]=]
local luauSignalInterface = {}

local classMetatable = {
	__index = luauSignalInterface,
	__tostring = function()
		return "LuauSignal"
	end,
}

--[=[
	@method Connect
	@within Signal
	
	Connects a given function to the signal
	```lua
	local signal = LuauSignal.new()
	
	local connection = signal:Connect(function()
		print("hi!")
	end)
	
	signal:Fire()
	
	connection() -- Call the connection to clean it up, to prevent memory leaks
	
	@param callback function
	@return function
	```
]=]
function luauSignalInterface:Connect(callback)
	assert(typeof(callback) == "function", "[LuauSignal] callback is not a function")
	assert(self[callback] ~= nil, "[LuauSignal] callback already exists")
	self[callback] = callback

	return function()
		self[callback] = nil
	end
end

--[=[
	@method Fire
	@within Signal
	
	Fires a signal, calling all of the connected callbacks.
	```lua
	local signal = LuauSignal.new()
	
	connection = signal:Connect(function(...)
		print(...)
	end)
	
	signal:Fire("wow", 3, false) -- will print "wow", 3, false
	
	@param arguments ...
	```
]=]
function luauSignalInterface:Fire(...)
	for _, callback in self do
		if freeThread == nil then
			freeThread = coroutine.create(yielder)
			coroutine.resume(freeThread :: thread)
		end

		task.spawn(freeThread :: thread, callback, ...)
	end
end

--[=[
	@method Once
	@within Signal
	
	Connects to a signal and runs only once.
	```lua
	local signal = LuauSignal.new()
	
	signal:Once(function()
		print("This will only print once")
	end)
	
	signal:Fire()
	signal:Fire()
	
	@param callback function
	@return function
	```
]=]
function luauSignalInterface:Once(callback)
	assert(typeof(callback) == "function", "[LuauSignal] callback is not a function")
	local connection

	connection = self:Connect(function(...)
		connection()
		callback(...)
	end)

	return connection
end

--[=[
	@method Wait
	@within Signal
	
	Yields until the signal is fired. Returns all arguments in the form of a vararg
	```lua
	local signal = LuauSignal.new()
	
	task.delay(1, function()
		signal:Fire("exactly one second!")
	end)
	
	local text = signal:Wait()
	print("this was " .. text) -- prints "this was exactly one second!"
	
	@return ...
	```
]=]
function luauSignalInterface:Wait()
	local runningThread = coroutine.running()

	self:Once(function(...)
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

--[=[
	@method DisconnectAll
	@within Signal
	
	Disconnects all active connections from a signal
	```lua
	local signal = LuauSignal.new()
	
	connection = signal:Connect(function()
		print("This will never run!")
	end)
	
	signal:DisconnectAll()
	
	signal:Fire()
	```
]=]
function luauSignalInterface:DisconnectAll()
	table.clear(self)
end

export type Signal<T...> = typings.Signal<T...>

return (
	table.freeze({
		new = function()
			return setmetatable({}, classMetatable)
		end,
	}) :: any
) :: typings.LuauSignalInterface
