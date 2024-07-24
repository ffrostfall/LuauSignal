local task = task or require("@lune/task")

local freeThread: thread?

local function run<T...>(func: (T...) -> (), ...: T...)
	local ref = freeThread
	freeThread = nil

	func(...)

	-- Luau type solver error, uninhabited type
	freeThread = ref :: thread?
end

local function yieldLoop()
	while true do
		run(coroutine.yield())
	end
end

local signal = {}
export type Identity<T...> = typeof(setmetatable(
	{} :: {
		[number]: (T...) -> (),
	},
	{
		-- Workaround for generics: This basically creates a unique metatable type for each signal
		-- This is because if we use the same metatable for all signals, the generics will be shared because
		-- well that's how metatables work.
		__index = signal :: {
			fire: (self: Identity<T...>, T...) -> (),
			connect: (self: Identity<T...>, callback: (T...) -> ()) -> () -> (),
		},
	}
))

local function constructor<T...>(): Identity<T...>
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

function signal.fire<T...>(self: Identity<T...>, ...: T...)
	for _, callback in self do
		if not freeThread then
			freeThread = coroutine.create(yieldLoop)
			coroutine.resume(freeThread :: thread)
		end

		-- Type states don't take into account assigning yet
		task.spawn(freeThread :: thread, callback, ...)
	end
end

function signal.connect<T...>(self: Identity<T...>, callback: (T...) -> ())
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

return constructor
