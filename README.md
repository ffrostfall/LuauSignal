# LuauSignal

---

## A pure-Luau signal implementation

LuauSignal is a signal implementation written for modern Luau, with the added benefit of being incredibly fast. It has an API that mirrors Roblox's `RBXScriptSignal`, with a few minor differences. The primary benefit that LuauSignal gives is it being strictly typed, with generic type arguments so you can typecheck your signals.

```lua
local LuauSignal = require(path.to.LuauSignal)

local tookDamage: LuauSignal.Identity<Player, number> = LuauSignal()

tookDamage:connect(function(player, amount)
	print(`player { player.Name } took { amount } damage!`)
end)

tookDamage:fire(Players.theReader101, 50)
```
