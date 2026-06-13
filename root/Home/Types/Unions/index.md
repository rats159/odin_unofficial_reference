# Unions
Unions are a way to create one type that's composed of multiple different types.
```odin
Int_Or_String :: union {
    int, string
}

an_int := Int_Or_String(123)
a_string := Int_Or_String("Hello")

// Reassignment works fine
both := an_int
both = a_string
```

There's also an implicit cast from a variant of a union to the union
```odin
my_val: Int_Or_String
my_val = 123
my_val = "hello"
```
All unions include a "nil variant", unless [otherwise specified](#directives). Unions store a tag to represent which variant is currently active, and 0 represents the nil variant. Variants count up from there, so 1 represents the first named type, 2 the second, etc. The type of the tag is the smallest integer that can hold all values. There is no way to customize the tag used for the union.

The tag can be read and modified directly using [Reflection](/Reflection).

Corrupted tags are *not* considered UB in Odin. This means that a [type switch](#type-switches) which checks all named variants of a union does not count as exhaustive. Consider a catchall `case` block, or simply handle the corrupted case after the switch

If the union contains *exactly one variant, which is a pointer*, then the union is not tagged. Instead, the nil pointer represents the nil union. This means there is *no way* to represent a non-nil union holding a nil pointer. You will need to use an intermediary struct.

There is no way to provide alternate names to the variants, they are always referred to by their types.

Unions can have [Type Parameters](/Types/Parametric%20Polymorphism)

## Type Assertions

To pull a value out of a union, use a Type Assertion:
```odin
my_val := Int_Or_String(123)

as_int := my_val.(int)
```

If you use an incorrect type, the assertion will fail
```odin
my_val := Int_Or_String(123)

// Assertion failure, program crash
as_int := my_val.(string)
```

Type Assertions support [optional-ok semantics](/Misc/Optional-Ok%20Semantics), so you can do a non-crashing check using an additional variable:
```odin
my_val := Int_Or_String(123)
as_int, is_int := my_val.(int) // is_int == true
as_str, is_str := my_val.(string) // is_str == false
```
If the union isn't holding the asserted type, the extracted value will be that types [zero value](/Misc/Zero%20Values).

## Type Switches
Sometimes, you want to have different behavior based on which variant the union is holding. A giant chain if two-part if/elses would get out of hand quick, so that's why there's Type Switches, which are a union version of a [Switch Statement](/Control%20Flow/Switch%20Statements)
```odin
my_val := Int_Or_String(123)

switch t in my_val {
   case int: fmt.println("It's an int!") 
   case string: fmt.println("It's a string!") 
}
```
Here, `t` is a variable representing the actual data inside the union. It's downcast to the actual type inside of a case. If you have multiple types inside of one case, `t` is not downcast:
```odin
switch t in something {
   case int: assert(type_of(t) == int)
   case string: assert(type_of(t) == string)
   case f32, f64: assert(type_of(t) == type_of(something))
}
```
`fallthrough` is not allowed inside a type switch.

## Directives
The following directives apply to unions:
- `#align(N)`: Aligns this type to N bytes.
- `#no_nil`: Removes the nil variant of this union. The zero value is now the first variant.
- `#shared_nil`: The `nil` of all types within the union represent the `nil` variant of the union itself. This does not prevent invalid tags. This is only allowed if every variant can be represented using the `nil` keyword specifically.
`#no_nil` and `#shared_nil` are mutually exclusive, so a `union` cannot have both.
- `#maybe`: Removed functionality that has been merged with standard `union`s.