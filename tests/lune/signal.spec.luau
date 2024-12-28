local signal = require("@src")
local case, eof = require("@tests/suite")()

case("creating doesn't error", function(interface)
	signal()

	signal()
end)

case("connecting adds connection", function(interface)
	local sig = signal()
	local f = function() end

	sig:connect(f)

	interface.expect.truthy((sig :: any)[1])
end)

case("disconnecting removes connection", function(interface)
	local sig = signal()
	local f = function() end

	local connection = sig:connect(f)

	interface.expect.truthy((sig :: any)[1])

	connection()

	interface.expect.equal(nil, (sig :: any)[1])
end)

case("firing resumes :wait()", function(interface)
	local sig = signal() :: signal.Identity<>

	local thread = task.spawn(function()
		sig:wait()
	end)

	interface.expect.equal(coroutine.status(thread), "suspended")

	sig:fire()

	interface.expect.equal(coroutine.status(thread), "dead")
end)

case("firing calls connected functions", function(interface)
	local sig = signal() :: signal.Identity<>

	local called = false
	sig:connect(function()
		called = true
	end)

	sig:fire()

	interface.expect.truthy(called)
end)

case("firing passes arguments", function(interface)
	local sig = signal() :: signal.Identity<>

	local called = false
	sig:connect(function(a, b)
		called = a == 1 and b == 2
	end)

	sig:fire(1, 2)

	interface.expect.truthy(called)
end)

case("firing doesn't error with no connections", function(interface)
	local sig = signal() :: signal.Identity<>

	sig:fire()
end)

case("disconnectAll removes all connections", function(interface)
	local sig = signal() :: signal.Identity<>

	local called = 0
	sig:connect(function()
		called += 1
	end)

	sig:connect(function()
		called += 1
	end)

	sig:disconnectAll()

	sig:fire()

	interface.expect.equal(0, called)
end)

case("once only calls once", function(interface)
	local sig = signal() :: signal.Identity<>

	local called = 0
	sig:once(function()
		called += 1
	end)

	sig:fire()
	sig:fire()

	interface.expect.equal(1, called)
end)

case("once passes arguments", function(interface)
	local sig = signal() :: signal.Identity<>

	local called = false
	sig:once(function(a, b)
		called = a == 1 and b == 2
	end)

	sig:fire(1, 2)

	interface.expect.truthy(called)
end)

return eof()
