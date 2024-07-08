local freeThread: thread?

local function functionPasser<T...>(fn: (T...) -> (), ...: T...)
	local aquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = aquiredThread
end

local function yielder()
	while true do
		functionPasser(coroutine.yield())
	end
end

type node = {
	_callback: () -> (),
	_nextNode: node?,
}

local luauSignalPrototype = {}
local metatable = { __index = luauSignalPrototype }
type LuauSignalType = typeof(setmetatable(
	{} :: {
		_rootNode: node?,
	},
	metatable
))

local function constructor(): LuauSignalType
	return setmetatable({}, metatable)
end

function luauSignalPrototype.fire(self: LuauSignalType, ...)
	local node = self._rootNode

	while node do
		if freeThread == nil then
			freeThread = coroutine.create(yielder)
			coroutine.resume(freeThread :: thread)
		end

		task.spawn(freeThread :: thread, node._callback, ...)

		node = node._nextNode
	end
end

function luauSignalPrototype.once(self: LuauSignalType, callback: () -> ())
	local connection
	local done = false

	connection = self:connect(function(...)
		if done then
			return
		end

		callback(...)

		done = true
		connection()
	end)

	return connection
end

function luauSignalPrototype.connect(self: LuauSignalType, callback: () -> ())
	local nodeRef = {
		_nextNode = self._rootNode,
		_callback = callback,
	}

	self._rootNode = nodeRef

	return function()
		if self._rootNode == nodeRef then
			self._rootNode = nodeRef._nextNode
		else
			local node = self._rootNode

			while node do
				if node._nextNode == nodeRef then
					node._nextNode = nodeRef._nextNode
					break
				end

				node = node._nextNode
			end
		end
	end
end

function luauSignalPrototype.disconnectAll(self: LuauSignalType)
	self._rootNode = nil
end

export type Identity<T...> = {
	Fire: (self: Identity<T...>, T...) -> (),
	Connect: (self: Identity<T...>, callback: (T...) -> ()) -> () -> (),
	Once: (self: Identity<T...>, callback: (T...) -> ()) -> () -> (),
	DisconnectAll: (self: Identity<T...>) -> (),
}

return (table.freeze({
	new = constructor,
}) :: any) :: {
	new: <T...>() -> Identity<T...>,
}
