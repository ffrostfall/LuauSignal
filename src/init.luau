local freeThread: thread?

local function functionPasser(fn, ...)
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
local prototypeMetatable = { __index = luauSignalPrototype }
type luauSignalType = typeof(setmetatable(
	{} :: {
		_rootNode: node?,
	},
	prototypeMetatable
))

local function constructor(): luauSignalType
	return setmetatable({}, prototypeMetatable)
end

function luauSignalPrototype.Fire(self: luauSignalType, ...)
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

function luauSignalPrototype.Once(self: luauSignalType, callback: () -> ())
	local connection
	local done = false

	connection = self:Connect(function(...)
		if done then
			return
		end

		callback(...)

		done = true
		connection()
	end)

	return connection
end

function luauSignalPrototype.Connect(self: luauSignalType, callback: () -> ())
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

function luauSignalPrototype.DisconnectAll(self: luauSignalType)
	self._rootNode = nil
end

export type luauSignal<T...> = {
	Fire: (self: luauSignal<T...>, T...) -> (),
	Connect: (self: luauSignal<T...>, callback: (T...) -> ()) -> () -> (),
	Once: (self: luauSignal<T...>, callback: (T...) -> ()) -> () -> (),
	DisconnectAll: (self: luauSignal<T...>) -> (),
}

local thisType = (table.freeze({
	new = constructor,
}) :: any) :: {
	new: <T...>() -> luauSignal<T...>,
}
