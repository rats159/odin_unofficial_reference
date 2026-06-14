# Switch Statements
Switch statements allow you to concisely compare a value against a series of other values. The basic syntax is this:
```odin
switch x {
    case 1:
        fmt.println("It's 1")
    case 2:
        fmt.println("It's 2")
    case 3:
        fmt.println("It's 3")
    case 4:
        fmt.println("It's 4")
    case:
        fmt.println("It's something else!")
}
```
If you want a catchall case, simply use `case` without an expression.

There is no need for `break` after every case like in C. Fallthrough is explicit in Odin, so use the `fallthrough` keyword if you need that behavior.

Cases do not need to be constant values:
```odin
compare :: proc(x, y: int) {
  switch x {
    case y: runtime.print_string("Equal!")
    case 3: runtime.print_string("Three!")
    case: runtime.print_string("Something else")
  }
}
```
If a case is a non-constant expression, it will be evaluated every time *that case* is checked

## Optimization
If possible, the switch will be transformed into a jump table. This can generally happen when all cases are constant integer values. Otherwise, the switch is equivalent to an if/else chain. The order of case checks is guaranteed in this case. That means that some case orderings may be more optimal than others, e.g. you may want to place all static checks before any expensive dynamic checks.

## Expressionless Switch
You may omit the check expression from your `switch` statement, which gives you a compact way to write several conditions. It's equivalent to `switch true`, meaning each case is checked for truthiness.

Example:
```odin
switch {
    case a == b: print("Equal!")
    case a < b:  print("A less")
    case a > b:  print("A greater")
}
```

## Type Switch
See the [Unions Page](/Types/Unions/#type-switches) and the [Any Page](/Reflection/Any/#type-switches)