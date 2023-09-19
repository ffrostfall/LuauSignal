export type Signal<T...> = {
	Connect: (self: Signal<T...>, (T...) -> ()) -> () -> (),
	Fire: (self: Signal<T...>, T...) -> (),
	Once: (self: Signal<T...>, (T...) -> ()) -> () -> (),
	Wait: (self: Signal<T...>) -> T...,
	DisconnectAll: (self: Signal<T...>) -> (),
}

export type LuauSignalInterface = {
	new: <T...>(T...) -> Signal<T...>,
}

return nil
