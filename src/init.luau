local task = task or require("@lune/task")

local freeThread: thread? = nil

local function run<T...>(func: (T...) -> (), ...: T...)
	local ref: thread? = freeThread
	freeThread = nil

	func(...)

	freeThread = ref
end

local function yieldLoop()
	while true do
		run(coroutine.yield())
	end
end

local signal = {}
type InternalIdentity<T...> = typeof(setmetatable(
	{} :: {
		[number]: (T...) -> (),
	},
	{
		-- Workaround for generics: This basically creates a unique metatable type for each signal
		-- This is because if we use the same metatable for all signals, the generics will be shared because
		-- well that's how metatables work.
		__index = signal :: {
			fire: (self: InternalIdentity<T...>, T...) -> (),
			connect: (self: InternalIdentity<T...>, callback: (T...) -> ()) -> () -> (),
			once: (self: InternalIdentity<T...>, callback: (T...) -> ()) -> () -> (),
			wait: (self: InternalIdentity<T...>) -> T...,
			disconnectAll: (self: InternalIdentity<T...>) -> T...,
		},
	}
))

local function constructor<T...>(): InternalIdentity<T...>
	return setmetatable(
		{} :: {
			[number]: (T...) -> (),
		},
		{
			-- See above comment
			__index = signal :: any,
		}
	)
end

function signal.fire<T...>(self: InternalIdentity<T...>, ...: T...)
	for _, callback in self do
		if not freeThread then
			freeThread = coroutine.create(yieldLoop)
			task.spawn(freeThread :: thread)
		end

		-- Type states don't take into account assigning yet
		task.spawn(freeThread :: thread, callback, ...)
	end
end

function signal.once<T...>(self: InternalIdentity<T...>, callback: (T...) -> ())
	local disconnect
	disconnect = self:connect(function(...)
		(disconnect :: any)()

		callback(...)
	end)
end

function signal.wait<T...>(self: InternalIdentity<T...>): T...
	local running = coroutine.running()

	self:once(function(...)
		assert(
			coroutine.status(running) == "suspended",
			":wait() called, then another thread resumed the waiting thread. Please dont do that :("
		)

		task.spawn(running, ...)
	end)

	return coroutine.yield()
end

function signal.connect<T...>(self: InternalIdentity<T...>, callback: (T...) -> ())
	table.insert(self, callback)
	local callbackRef = callback

	return function()
		for i, v in self do
			if v == callbackRef then
				table.remove(self, i)
				break
			end
		end
	end
end

function signal.disconnectAll<T...>(self: InternalIdentity<T...>)
	table.clear(self)
end

export type Identity<T...> = {
	fire: (self: Identity<T...>, T...) -> (),
	connect: (self: Identity<T...>, callback: (T...) -> ()) -> () -> (),
	once: (self: Identity<T...>, callback: (T...) -> ()) -> () -> (),
	wait: (self: Identity<T...>) -> T...,
	disconnectAll: (self: Identity<T...>) -> (),
}

return (constructor :: any) :: <T...>() -> Identity<T...>
