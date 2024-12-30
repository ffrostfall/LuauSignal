# luausignal

[Documentation](https://ffrostfall.github.io/luausignal/docs/intro)

---

luausignal is a signal implementation written for modern Luau, with modern best practices.

```lua
local signal = require(path.to.signal)

local tookDamage: signal.Identity<Player, number> = signal()

tookDamage:connect(function(player, amount)
	print(`player { player.Name } took { amount } damage!`)
end)

tookDamage:fire(Players.theReader101, 50)
```

## It's a table. Don't worry about memory leaks.

luausignal is just a table, with a metatable. The connections are just functions in an array. This means that it will be garbage collected.
