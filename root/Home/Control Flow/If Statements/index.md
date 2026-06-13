# If Statements
If statements allow you to execute code conditionally, based on an expression. The most basic form of if statements are
```odin
if condition {
    body()
}
```

## Two-part If Statements
If statements can also be 2-part. This is most useful for defining a variable that only lives for the duration of the if statement, like this:
```odin
if result := do_xyz(); result == .Error {
    error()
}
```
It's also useful when combined with [Type Assertions](/Types/Unions#type-assertions)