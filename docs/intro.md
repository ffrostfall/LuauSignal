# Intro

LuauSignal aims to be a strictly-typed Luau implementation of a signal. It does not aim to be 1:1 to `RBXScriptSignal`, because there's multiple needless features that don't need to be there (for example, an entire class for connections.)

## Why use this over GoodSignal?

GoodSignal was not written in strict Luau, which means that it has several type errors. Alongside this, GoodSignal aims to replicate `RBXScriptSignal` almost perfectly. This, however, is limiting. It means more memory usage overall, and it means an entire class just for connections. In LuauSignal, the `Connect` method returns a function. Calling this function disconnects the connection.

## Drawbacks

The drawbacks of using LuauSignal over the alternative, GoodSignal, are:

- Connections are not fired in order of when they were connected
- You cannot connect the exact same callback more than once

## Luau Types

The main benefit of using LuauSignal over GoodSignal is that you can type your signals using generic types.

```lua
--!strict
local signal = LuauSignal.new()

signal:Connect(function()
	print("I don't do anything!")
end)

signal:Fire(5, 4, 3) -- This will lint, saying there are more arguments than expected.
```

```lua
--!strict
local signal: LuauSignal.Signal<string> = LuauSignal.new()

signal:Connect(function(text) -- This is typechecked as a string
	print(text)
end)

signal:Fire("some random text") -- This doesn't lint!
```

### Incorrect number of arguments to .new()

If your linter says "incorrect number of arguments to .new()", you can solve it by simply putting "..." in the `.new()` function like so:
`local signal: LuauSignal.Signal<string> = LuauSignal.new(...)`
