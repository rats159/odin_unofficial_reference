# Optional-Ok Semantics
Some expressions, such as [map](/Types/Maps) accesses, [union](/Types/Unions) and [any](/Types/Builtin%20Types/#any) type assertions, and some [procedure](/Procedures) calls, have "Optional-Ok Semantics." This means that when the values is stored in some variables, you're able to omit the second value (the "ok" value). 

For procedures, the `#optional_ok` directive allows you to ignore the second return value, which must be a bool. The procedure must have exactly 2 return values. Procedures can also be tagged with `#optional_allocator_error`, which has the same behavior, except it requires a `runtime.Allocator_Error` as the second return type, rather than a `bool`.

Example:
```odin
get_at :: proc(data: []int, index: int) -> (int, bool) #optional_ok {
    if index < 0 || index >= len(data) {
        return 0, false
    }

    return data[index], true
}

my_numbers := []int{1,2,3}
value, exists := get_at(my_numbers, 2) // 3, true
value, exists := get_at(my_numbers, 5) // 0, false
value := get_at(my_numbers, 5)         // 0
```

## Specific Behavior
The exact behavior depends on what the expression is.

### Unions and Anys
If you ignore the ok value of a union type assertion, an [assertion](/Procedures/Builtin%20Procedures#assert) failure is triggered when the asserted variant doesn't match the actual one.

Example:
```odin
My_Union :: union {
    int, string
}

val := My_Union(123)

// Assertion failure triggered
as_string := val.(string)

// No failure, ok == false
as_string, ok := val.(string)
```
### Maps
If you ignore the ok value of a map access, you silently get the [zero value](/Misc/Zero%20Values) of the map. This does *not* insert the key if it wasn't present. Consider [map_entry](/Procedures/Builtin%20Procedures#map_entry) for this purpose.

Example:
```odin
my_map: map[string]int
val, ok := my_map["123"] // val == 0, ok == false
val := my_map["123"] // val == 0
assert("123" not_in my_map) // not inserted still
```

### Procedures
When an ok value is ignored in a procedure call, nothing special happens. The procedure still runs as normal.