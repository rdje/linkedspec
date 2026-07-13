Top::
 -> Value .push
 LX { return(copy(Top)) }

Value:
 /x/
 I {
  set(upper, ["a", "Bc"])
  uppercase_each(upper)
  return(hash(
   "coalesce", coalesce(undef, "fallback"),
   "concat_arrays", concat_arrays([1, 2], [3]),
   "contains", contains(["a", "b"], "b"),
   "contains_substr", contains_substr("abc", "b"),
   "ends_with", ends_with("abc", "bc"),
   "starts_with", starts_with("abc", "ab"),
   "flat", ["x", flat(["y", "z"])],
   "has_key", has_key({ "a" : 1 }, "a"),
   "slice", slice(["a", "b", "c", "d"], 1, 2),
   "take_last", take_last(["a", "b", "c"], 2),
   "uppercase_each", copy(upper),
   "num_abs", num_abs(-3),
   "num_avg", num_avg([2, 4, 6]),
   "num_ceil", num_ceil(2.2),
   "num_clamp", num_clamp(12, 0, 10),
   "num_div", num_div(9, 3),
   "num_floor", num_floor(2.8),
   "num_ge", num_ge(3, 3),
   "num_le", num_le(3, 3),
   "num_median", num_median([5, 1, 3]),
   "num_mod", num_mod(10, 4),
   "num_mul", num_mul(3, 4),
   "num_ne", num_ne(3, 4),
   "num_range", num_range([3, 9, 1, 7]),
   "num_round", num_round(2.6),
   "num_sum", num_sum([1, 2, 3])
  ))
 }
