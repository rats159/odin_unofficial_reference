# Pointers
A pointer is an integer value representing a memory address. You can take the address of a value using the address-of operator `&`. A pointer to some type `T` is represented as `^T`. This can be nested as much as you want, so `^^^^^T` is a perfectly valid type. If you want to get the value out of a pointer , use the dereference operator `^`, placed after the expression. This follows Odin's general rule of modifiers on the left and "undoing" those modifiers on the right.

Example:
```odin
my_number: int = 123
my_pointer: ^int = &my_number

assert(my_number == my_pointer^)
```

A dereference is a valid assignment target, which means you can use a pointer to pass around a value that can be modified, e.g.
```odin
double_int :: proc(x: ^int) {
    x^ = x * 2
}

x := 5
double_int(&x)
assert(x == 10)
```

Not every expression can have its address taken, here are a few common cases and their solutions:
- Procedure parameters can't be addressed, mostly to prevent bugs. If you really do want to take the address *of the parameter*, make a local copy in the function via [shadowing](/Procedures#shadowing). If you want the address of the thing originally passed in, convert the parameter to a pointer and modify the calling code accordingly.
- Simple literals (such as numbers) can't be addressed, because they don't necessarily have one (they may be in registers, or be optimzed away entirely). Store the literal in a variable first.
- Context can't be addressed because of the way it's passed around, and to prevent it being "hijacked". Make a local copy like `ctx := context` and use that. For more details, see [Context](/Misc/Context).

[Compound literals](/Types#compound-literals) can be addressed, so `&Foo{}` is perfectly valid.

## Multipointers
A multipointer is a pointer that can be indexed, with behavior like C. A multipointer type is written as `[^]T`. Multipointers are used most commonly when interfacing with C, but are sometimes found in other places. The most common way to get a multipointer is using the [`raw_data`](/Procedures/Builtin%20Procedures/#raw-data) builtin procedure, but they can also be created directly with [`make`](/Procedures/Builtin%20Procedures/#make).

Multipointers can be [sliced](/Types/Slices/#slicing-operator), which will either give back another multipointer or a [Slice](/Types/Slices), depending on whether or not you provide a length.

Example:
```odin
my_data: [^]int = make([^]int, 10)
// A slice, because it has a length
my_slice: []int = my_data[:10]
// A multipointer, because there's no length
my_data_again: [^]int = my_data[:]
```

Multipointers are the primary alternative to pointer arithmatic or pointer math in C. Here's an example of C code and equivalent Odin code:
```c
const char *str = "Hello";

for (char *ptr = str; *ptr != 0; ptr++) {}
```
```odin
str: cstring = "Hello"
for ptr := transmute([^]u8)str; ptr[0] != 0; ptr = ptr[1:] {}
```
For more info about features used in this example, see [Cstrings](/Types/Builtin%20Types/#cstrings), [`transmute`](/Misc/Transmute), [Loops](/Control%20Flow/Loops)

## Rawptr
[Main article](/Types/Builtin%20Types#rawptr)

`rawptr` is a pointer type representing a pointer to anything. It doesn't track what the type is that it's pointing to (for that, consider [Any](/Types/Builtin%20Types#any)), so it's mainly used as a way to store unknown data. Most commonly it's used inside of callbacks from libraries, to allow you to pass as much arbitrary data into the callback as you want. It's equivalent to `void *` in C.

## Uintptr
`uintptr` isn't necessarily a pointer type, but a pointer-sized integer type. While the difference is subtle, `uintptr` cannot be assigned `nil`, and supports integer operations such as `+` and `-`. It can, however, be cast to and from most pointer types, so it serves as the most fundamental form of pointer arithmatic in Odin.

## Procedures
[Procedure types](/Types/Procedures) are automatically pointers, so storing one in a variable creates a procedure pointer. They can be cast to `rawptr` and to other procedure types, but nothing else. You cannot dereference a procedure.