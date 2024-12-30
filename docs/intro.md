# luausignal

## Why?

I wanted a typechecked, small, cross-runtime & performant signal implementation which didn't use the same Roblox-based RbxScriptSignal API. None existed, so I made one.

## Basic Features

- Firing and disconnecting (duh)
- Disconnect all
- Wait
- Once
- Function constructor, `signal()` over `signal.new()`

## Overview

- Thread reusage
- Cross-runtime (Roblox, Lune)
- Strictly typed, with an exported "Identity" type for your type-definition needs.
- Extremely performant implementation; literally just an array with a metatable. No linked lists here!
- Automated testing guarantees behavior and stability
- Error handling for niche cases
- Battle-tested. This has been around for a while and I use it
- Future-proof (this uses the new solver lol)

## Installation

### Wally

You can find luausignal under `ffrostfall/luausignal@<latest version>`.

### Literally just copy pasting

You can also just literally copy paste this. It's one file.

## Benchmarks (why not ig)

specs:

- 64gb 3600mz RAM
- i79700kf @ ~4.00 GHz (overclocked)
  - 8 cores
  - 512kb L1 cache

Numbers are done by the 50th percentile.
| Test | luausignal (μs) | goodsignal (μs) |
| ---- | ---------- | ---------- |
| Firing (5 connections) | 2.178 | 2.124 |
| Firing (0 connections) | 0.038 | 0.026 |
| Connecting | 0.104 | 0.212 |
| Disconnecting | 0.172 | 2.554 |
| Constructing | 0.066 | 0.102 |

### Firing (5 connections) analysis

Both luausignal and goodsignal use the same thread reuse method, and are doing nearly the exact same operations.
However, arrays are slightly cheaper than linked lists at the end of the day.

### Firing (0 connections) analysis

Again, nearly identical except for a handful of CPU cycles.

Goodsignal wins due to it's usage of linked lists. Iterating over a zero-length array is slower than iterating over a zero-length linked list.

### Connecting analysis

Luausignal wins by a decent margin here because inserting into an array is substantially faster than inserting into a linked list.

### Disconnecting analysis

Luausignal wins by an **incredibly** large margin here. This is because, again, arrays are faster than linked lists! table.find and table.remove

### Constructor analysis

Luausignal wins here for obvious reasons: constructing an array with a metatable is faster than a dictionary.
