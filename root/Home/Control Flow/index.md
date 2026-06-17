# Control Flow
Odin has a lot of control flow features. For the constructs themselves, see [If Statements](/Control%20Flow/If%20Statements), [Switch Statements](/Control%20Flow/Switch%20Statements), and [Loops](/Control%20Flow/Loops).

## Break
A lone `break` will break one level out of a loop or a switch statement. You can also provide a [Label](/Misc/Labels), which allows you to break out of any block, including if statements and [standalone Blocks](/Misc/Blocks).

## or_break
The `or_break` keyword is a postfix operator. It takes a multi-valued expression, the last of which is either a [nilable type](/Types/#nilable-types) or a [Boolean type](/Types/Builtin%20Types/#booleans), and breaks if that value is non-nil or false.

It roughly desugars like this:
```odin
foo := bar() or_break

// for booleans
foo, ok := bar()
if !ok do break

// for nilables
foo, err := bar()
if err != nil do break
```

## Continue
A lone `continue` will skip to the next ieration of the containing loop. You can also provide a [Label](/Misc/Labels), which allows you to skip to the next iteration of loops other than the innermost one.

## or_continue
The `or_continue` keyword is a postfix operator. It takes a multi-valued expression, the last of which is either a [nilable type](/Types/#nilable-types) or a [Boolean type](/Types/Builtin%20Types/#booleans), and continues if that value is non-nil or false.

It roughly desugars like this:
```odin
foo := bar() or_continue

// for booleans
foo, ok := bar()
if !ok do continue

// for nilables
foo, err := bar()
if err != nil do continue
```

## Fallthrough
The `fallthrough` keyword prevents the implicit `break` at the end of every `case` inside a switch statement.

Example:
```odin
do_switch :: proc(x: int) {
	switch x {
		case 1:
			fmt.println("One",x)
			fallthrough
		case 2:
			fmt.println("Two",x)
			fallthrough
		case 3:
			fmt.println("Three",x)
			fallthrough
		case:
			fmt.println("Other", x)
	}
}
do_switch(1)
fmt.println()
do_switch(2)
fmt.println()
do_switch(3)
fmt.println()
do_switch(4)
```
Output:
```
One 1
Two 1
Three 1
Other 1

Two 2
Three 2
Other 2

Three 3
Other 3

Other 4
```

## Return

The `return` keyword exits from the current procedure. You can return any number of values from a procedure. See [Procedures](/Procedures) for more info.

## or_return
The `or_return` keyword is a postfix operator. It takes a multi-valued expression, the last of which is either a [nilable type](/Types/#nilable-types) or a [Boolean type](/Types/Builtin%20Types/#booleans), and returns if that value is non-nil or false.

It roughly desugars like this:
```odin
foo := bar() or_return

// for booleans
foo, ok := bar()
if !ok do return ok

// for nilables
foo, err := bar()
if err != nil do return err
```

There is no way to configure what is returned, it always propagates from the expression attached to it.

## or_else
The `or_else` keyword is a binary operator. It takes an n-valued expression on the left, the last of which is either a [nilable type](/Types/#nilable-types) or a [Boolean type](/Types/Builtin%20Types/#booleans), and another n-1 valued expression, and evaluates to the first expression if the last value is nil or true, otherwise the second expression.

It roughly desugars like this:
```odin
foo := bar() or_else 10

// for booleans
foo, ok := bar()
if !ok do foo = 10

// for nilables
foo, err := bar()
if err != nil do foo = 10
```

All of the `or_*` keywords also work with expressions with optional-ok semantics, such as map accesses or [union type assertions](/Types/Union#type-assertions).