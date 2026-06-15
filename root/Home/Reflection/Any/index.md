# Any
The `any` type is a builtin type primarily designed for use with reflection. Internally, its structure is very simple:
```odin
Raw_Any :: struct {
    data: rawptr,
    id:   typeid
}
```
An `any`'s fields can be accessed directly, so `your_any.data` and `your_any.id` work fine to access those fields.

### When not to use Any
- You want a struct to be able to hold any type. Consider [Parameteric Polymorphism](/Types/Parametric%20Polymorphism)
- One value could be of a few different types. Consider [Unions](/Types/Unions)
- You want inheritance-like behavior where one type contains another. Consider [the Using keyword](/Misc/Using)
- You want dynamically typed code. Consider [not using Odin](https://pkg.odin-lang.org/vendor/lua/5.4) 
- You want a `userdata` pointer for a callback. Consider [`rawptr`](/Types/Pointers/#rawptr)

### When to use Any
- Printing (sometimes)
- Serialization (sometimes)
- Metaprogramming (sometimes)

It's always worth considering if you really need "any" type, determined at runtime, or if something simpler would work

## Compound Literal
Anys can be created via [Compound Literals](/Types#compound-literals), just like a struct. This is most useful when doing complex reflection tasks, such as getting an `any` representing a field of an unknown struct.
```odin
get_fields :: proc(val: any, inf: runtime.Type_Info_Struct) {
    for i in 0..&ltinf.field_count {
        field_address := rawptr(uintptr(val.data) + inf.offsets[i])
        field_typeid := inf.types[i].id 
        field_any := any{data = field_address, id = field_typeid}
        do_something(field_any)
    }
}
```
For practical usecases, check out `core:encoding/json`, which does this sort of thing a lot. Or just grep for `any\s?{` in core and see what you find.

## Implicit Conversions
The main "magic" with any comes from implicit conversions. Every single type converts to `any` implicitly, with behavior like this:
```odin
x: f32 = 123

// These two are equivalent
my_any_implicit: any = x
my_any_explicit := any {data = &x, id = typeid_of(f32)}
```

It's worth being careful about this. We're implicitly taking the address of a variable and storing it somewhere, which is always risky. Generally, `any`s should never be moved to higher scopes. A trivial example of a Use After Free hidden by `any`'s implicit behavior:
```odin
make_an_any :: proc() -> any {
    x := 10
    return x // surprise! this returns the address of x
}
```

*`any` is allowed to break Odin's standard addressing rules!* It can take the address of literals, procedure parameters, `context`, and more.

## Type Assertions
There's no way to make a variable that holds whatever type is inside an `any`, since that type is determined at runtime, and Odin has static typing. However, you are able to use the [Type Assertion](/Types/Unions/#type-assertions) syntax from unions in a similar way.
```odin
x: any = 123
as_int := x.(int) // All good
as_f32 := x.(f32) // Assertion failure, x.id != f32
```

This behavior effectively compiles down to
```odin
x: any = 123
assert(x.id == typeid_of(int))
as_int: int = (^int)(x.data)^
assert(x.id == typeid_of(f32)) // This assertion fails
as_f32: f32 = (^f32)(x.data)^
```

Like with unions, these type assertions have [Optional-Ok Semantics](/Misc/Optional-Ok%20Semantics).

## Type switches
[Type switches](/Types/Unions/#type-switches) also work on `any`s. They follow the same rules as unions. 