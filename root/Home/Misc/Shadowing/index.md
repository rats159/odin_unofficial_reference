# Shadowing
You're able to declare a variable with the same name as an already existing variable, so long as that variable is from a higher scope. This is called shadowing, because the higher-scoped variable is hidden "in the shadow" of the lower-scoped variable. There are some cases in Odin where shadowing is incredibly useful, and often required. 

Basic example:
```odin
main :: proc() {
    x := 1
    {
        x := 2
        // This affects the inner scope only
        x += 1
    }
    assert(x == 1)
}
```

The most common time you'll actually use shadowing is when you have something that doesn't work quite like a variable, but you want it to. In these cases, you'll usually shadow a variable with its outer-scope version, like `x := x`.

You can compile with the `-vet-shadowing` flag, which will give you errors about all shadowing, except shadowing that reassigns to the exact same name, like `x := x`.

## Procedure parameters
Procedure parameters have some [special rules](/Procedures/#parameter-rules), which prevent addressing and assignment. If you need to modify or address one of these parameters, shadowing is the right answer.
```odin
process :: proc(a, b: int) -> int {
    a := a // now we have a copy we can modify
    a += b
    a *= b
    a -= b
    a /= b
    return a
}
```

## Loop variables
Loop variables have the same rules as procedure parameters:
```odin
for item in my_slice {
    item := item
    item.x += 3
    item.y /= 4
    do_something(&item)
}
```