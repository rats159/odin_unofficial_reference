# Loops
In Odin, every loop uses the `for` keyword. This includes while loops, C-style for loops, for-each loops, custom iterators, and infinite loops. The reasoning behind using the `for` loop for everything is mainly to reduce the number of "dialects". In C, some people use `for(;;)` for infinite loops, and `for(;cond;)` for while loops. Because of Odin's optional parentheses and semicolons in many cases, `for` and `for cond` become natural ways to translate these loops.

## While loops
To create a loop that runs while a given condition is true, use `for cond`.

Example:
```odin
should_quit := false
for !should_quit {
	event := poll_event()
	if event.type == .Quit {
		should_quit = true
	}

	draw_frame()
}
```

## C-style for loops
To create a C-style for loop, use `for init_stmt; condition_expr; end_stmt`. All parts are optional.

Example:
```odin
for i, j := 0, len(x); i <= j; i += 1, j -= 1 {
	
}
```

## For-each loops
To loop over all items in a collection, use `for item in collection`. For linear collections like [Arrays](/Types/Arrays), [Slices](/Types/Slices), [Dynamic Arrays](/Types/Dynamic%20Arrays), and more, you can optionally include a second item in the iteration which holds the index. 

Example:
```odin
for item, index in my_slice {}
```

For maps, the first variable represents the key and the second variable represents the value.
```odin
for key, value in my_map {}
```

For [Enumerated Arrays](/Types/Enumerated%20Arrays), the first variable represents the value and the second variable represents the enum variant.
```odin
for value, variant in my_enum_arr {}
```

### Iterating by reference

You're able to iterate by-reference on any mutable elements. This means most things, except for map keys, indices, and enum variants.
Example:
```odin
my_slice := []int{1,2,3,4}
for &item in my_slice {
	item *= 2
}
```
Importantly, this is *not* a pointer. It's still an `int`. The difference is that with `&item`, every usage of `item` represents `my_slice[index]`. When you use a regular loop, `item` is a new variable created at the start of each iteration. You can't take the address of the loop variable in these cases to prevent people thinking they're modifying the array when they aren't. If you do want an explicit loop-scoped variable you can modify and address, you can [Shadow](/Misc/Shadowing) it.

### Custom Iterators
A [Procedure](/Procedures) that returns at least two values, the last of which is any [Boolean Type](/Types/Builtin%20Types/#Booleans) can be used as a custom iterator. that procedure will be called at the start of every iteration, and when its final return is `false`, the loop will exit.

Example:
```
for item in foo_iter(&foo) {
	fmt.println(item)
}
```
Which is approximately equivalent to the following:
```
for {
	item := foo_iter(&foo) or_break
	fmt.println(item)
}
```
See [the `or_break` operator](/Control%20Flow/#or-break) for information on that.

A lot of the time, iterators need to keep state. Because of that, it's relatively common to have an iterator struct. This is especially useful with two-part foreach loops

## Two-part foreach loops
For-each loops support a two-part syntax, similar to [If statements](/Control%20Flow/If%20Statements/#two-part-if-statements).
```
for iter := make_foo_iterator(foo); item in foo_iterate(&iter) {
	fmt.println(item)
}
```

## Infinite loops
By omitting the condition entirely, you get behavior equivalent to `for true`. This is similar to [Switch statements](/Control%20Flow/Switch%20Statements/#expressionless-switch).