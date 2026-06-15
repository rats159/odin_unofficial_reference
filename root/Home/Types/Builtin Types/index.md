# Builtin Types
Odin has a large number of builtin types compared to most other languages.

### Signed Integers
- `i8`
- `i16`
- `i32`
- `i64`
- `i128`
### Unsigned Integers
- `u8`
- `u16`
- `u32`
- `u64`
- `u128`
- `uintptr`. An unsigned integer guaranteed to be `sizeof(rawptr)`

`byte` exists as an alias of `u8`. It is not a distinct type.
### Endian-specific types
By default, all numeric types have platform-native endianness. These types override that, which is primarily useful for things like parsing file formats, or reading data from the network. This specifically represents the byte-endianness. For that reason, `u8` and `i8` do not have endian-specific variants, as they are only 1 byte.

Big Endian:
- `i16be`
- `u16be`
- `i32be`
- `u32be`
- `i64be`
- `u64be`
- `i128be`
- `u128be`
- `f16be`
- `f32be`
- `f64be`

Little Endian:
- `i16le`
- `u16le`
- `i32le`
- `u32le`
- `i64le`
- `u64le`
- `i128le`
- `u128le`
- `f16le`
- `f32le`
- `f64le`