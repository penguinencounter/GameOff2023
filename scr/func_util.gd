class_name FuncUtil


## Produces a filter that matches any value in the given array.
static func f_in(matches: Array) -> Callable:
    return func(val: Variant) -> bool:
        return matches.has(val)


## Transforms a filter to its negation.
static func t_not(f: Callable) -> Callable:
    return func(value: Variant) -> bool:
        return !f.call(value)

static func apply1(f: Callable, value: Variant) -> Callable:
    return func() -> Variant:
        return f.call(value)
