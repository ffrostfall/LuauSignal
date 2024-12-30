--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local goodsignal = require(ReplicatedStorage.benches.libs.goodsignal)
local luausignal = require(ReplicatedStorage.benches.libs["luausignal-mirror"])

return {
	Functions = {
		["luausignal constructor"] = function()
			local _s

			for i = 1, 500 do
				_s = luausignal()
			end
		end,

		["goodsignal constructor"] = function()
			local _s

			for i = 1, 500 do
				_s = goodsignal.new()
			end
		end,

		["luausignal connection"] = function()
			local sig = luausignal()
			local f = function() end

			for i = 1, 500 do
				sig:connect(f)
			end
		end,

		["goodsignal connection"] = function()
			local sig = goodsignal.new()
			local f = function() end

			for i = 1, 500 do
				sig:Connect(f)
			end
		end,

		["luausignal disconnection"] = function(Profiler: any)
			local sig = luausignal()
			local f = function() end
			local disconnects = {}

			for i = 1, 500 do
				disconnects[i] = sig:connect(f)
			end

			Profiler.Begin("disconnection")
			for i = 1, 500 do
				disconnects[i]()
			end
			Profiler.End()
		end,

		["goodsignal disconnection"] = function(Profiler: any)
			local sig = goodsignal.new()
			local f = function() end
			local disconnects = {}

			for i = 1, 500 do
				disconnects[i] = sig:Connect(f)
			end

			Profiler.Begin("disconnection")
			for i = 1, 500 do
				disconnects[i]:Disconnect()
			end
			Profiler.End()
		end,

		["luausignal firing (zero connections)"] = function()
			local sig = luausignal()

			for i = 1, 500 do
				sig:fire()
			end
		end,

		["goodsignal firing (zero connections)"] = function()
			local sig = goodsignal.new()

			for i = 1, 500 do
				sig:Fire()
			end
		end,

		["luausignal firing (five connections)"] = function()
			local sig = luausignal()
			for i = 1, 5 do
				sig:connect(function() end)
			end

			for i = 1, 500 do
				sig:fire()
			end
		end,

		["goodsignal firing (five connections)"] = function()
			local sig = goodsignal.new()
			for i = 1, 5 do
				sig:Connect(function() end)
			end

			for i = 1, 500 do
				sig:Fire()
			end
		end,
	},
}
