# USER GUIDE - ActionIR Emitted Perl Reference
This is the exhaustive companion to the module-oriented ActionIR guides.
Its job is simple: list every currently supported lowering helper or recognized compatibility construct and show the emitted Perl shape.

Use this file when you want to review the real lowering contract rather than just the higher-level explanations.

Scope note:
- “exhaustive” here means exhaustive over the recognized helper/lowering surfaces and compatibility constructs,
- not exhaustive over every possible nested-composition arrangement of those helpers inside method arguments.
- Unlimited nested method composition in arguments is a supported capability; this file uses representative emitted examples rather than trying to enumerate every combination.

## How to read this file
- Preferred canonical helper forms are the best choice for new backend-neutral `.spec` authoring.
- Compatibility helpers are still supported and important because existing specs use them.
- Classified pass-through idioms are preserved verbatim, but they still register canonical ActionIR nodes and therefore do not count as `RAW_PERL` fallback.

Many helpers accept an optional leading scope token in chained forms.
Examples:
- `assign(Top, scalar(c), CAPTURE)` lowers the same way as `assign(scalar(c), CAPTURE)`.
- `declare_a(Top, items)` lowers the same way as `declare_a(items)`.
- `push_value(Top, array(items), scalar(retv))` lowers the same way as `push_value(array(items), scalar(retv))`.

## Preferred canonical helper surface
### Declarations (`DeclareMethod.pm`)
- `declare(array, items, captures)` -> `my @items; my @captures`
- `declare(scalar, flag)` -> `my $flag`
- `declare(hash, by_name)` -> `my %by_name`
- `declare_a(items, captures)` -> `my @items; my @captures`
- `declare_array(items, captures)` -> `my @items; my @captures`
- `declare_s(flag, name)` -> `my $flag; my $name`
- `declare_scalar(flag, name)` -> `my $flag; my $name`
- `declare_h(by_name)` -> `my %by_name`
- `declare_hash(by_name)` -> `my %by_name`
- `declare(scalar, flag=or(scalar(on), scalar(off)))` -> `my $flag = (($on) || ($off))`
- `declare(scalar, token=scalaref(myref, {kind}))` -> `my $token = $myref->{kind}`
- `declare(array, parts=array(scalar(a), scalar(b)))` -> `my @parts = ($a, $b)`
- `declare(hash, by_name=hash("k1", scalar(v1), "k2", scalar(v2)))` -> `my %by_name = ("k1" => $v1, "k2" => $v2)`
- `declare(scalar, flag=1, name, token=scalaref(retv, {content}))` -> `my $flag = 1; my $name; my $token = $retv->{content}`

### Value selectors and constructors (`MethodLowering.pm`, `ValueExpr.pm`)
These are value-expression lowerings.
They take effect when the expression appears inside a statement or helper that consumes values, such as `assign(...)`, `push_value(...)`, `return(payload)`, `declare(...=...)`, or a flow/control expression.
- `scalar(name)` -> `$name`
- `scalar(IMATCH_LIST, 0)` -> `$IMATCH_LIST[0]`
- `scalar(array(items), idx)` -> `$items[$idx]`
- `scalar(hash(by_name), key)` -> `$by_name{$key}`
- `scalaref(retv, {content})` -> `$retv->{content}`
- `scalaref(cur_object, [1])` -> `$cur_object->[1]`
- `scalaref(myref, [A][B]{C}[D])` -> `$myref->[A]->[B]->{C}->[D]`
- `array(scalar(tag), scalar(name))` -> `[$tag, $name]`
- `array()` -> `[]`
- `hash("kind", "node", "item", scalar(name))` -> `{"kind" => "node", "item" => $name}`
- `array_copy(array(items))` -> `[@items]`
- `array_values(array(items))` -> `[@items]` (compatibility alias for `array_copy(...)`)
- `trim(scalar(IMATCH))` -> `do { my $__ls_trim = $IMATCH; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }`
- `lowercase(trim(scalaref(retv, {content})))` -> `do { my $__ls_lower = do { my $__ls_trim = $retv->{content}; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }; defined($__ls_lower) ? lc($__ls_lower) : $__ls_lower }`
- `uppercase(coalesce(scalaref(retv, {type}), "word"))` -> `do { my $__ls_upper = do { my $__ls_coalesce = $retv->{type}; defined($__ls_coalesce) ? $__ls_coalesce : "word" }; defined($__ls_upper) ? uc($__ls_upper) : $__ls_upper }`
- `count(array(parts))` -> `scalar(@parts)`
- `count(coalesce(scalaref(retv, {parts}), array("empty")))` -> `do { my $__ls_count = do { my $__ls_coalesce = $retv->{parts}; defined($__ls_coalesce) ? $__ls_coalesce : ["empty"] }; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }`
- `count_keys(hash(meta))` -> `scalar(keys %meta)`
- `count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")))` -> `do { my $__ls_count_keys = do { my $__ls_coalesce = $retv->{meta}; defined($__ls_coalesce) ? $__ls_coalesce : {"kind" => "fallback"} }; defined($__ls_count_keys) ? scalar(keys %{$__ls_count_keys}) : 0 }`
- `sorted_keys(hash(meta))` -> `[sort keys %meta]`
- `sorted_keys(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage"))` -> `do { my $__ls_sorted_keys = do { my $__ls_pick_source = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "stage") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }; defined($__ls_sorted_keys) ? [sort keys %{$__ls_sorted_keys}] : [] }`
- `has_key(hash(meta), "kind")` -> `((exists $meta{"kind"}) ? 1 : 0)`
- `has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind")` -> `do { my $__ls_has_key = do { my $__ls_coalesce = $retv->{meta}; defined($__ls_coalesce) ? $__ls_coalesce : {"kind" => "fallback"} }; defined($__ls_has_key) ? ((exists $__ls_has_key->{"kind"}) ? 1 : 0) : 0 }`
- `merge_hash(hash(meta), hash("stage", "normalized"))` -> `{%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}`
- `merge_hash(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), hash("source", scalar(rule_name)))` -> `{do { my $__ls_merge_hash = do { my $__ls_coalesce = $retv->{meta}; defined($__ls_coalesce) ? $__ls_coalesce : {"kind" => "fallback"} }; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }, do { my $__ls_merge_hash = {"source" => $rule_name}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}`
- `drop_keys(hash(meta), "debug")` -> `do { my $__ls_drop_source = \%meta; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{"debug"}; \%__ls_drop } else { {} } }`
- `drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug", "span")` -> `do { my $__ls_drop_source = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{"debug", "span"}; \%__ls_drop } else { {} } }`
- `pick_keys(hash(meta), "kind", "source")` -> `do { my $__ls_pick_source = \%meta; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "source") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }`
- `pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage")` -> `do { my $__ls_pick_source = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "stage") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }`
- `coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN")` -> `do { my $__ls_coalesce = $retv->{content}; defined($__ls_coalesce) ? $__ls_coalesce : do { my $__ls_coalesce = $IMATCH; defined($__ls_coalesce) ? $__ls_coalesce : "UNKNOWN" } }`
- `coalesce(scalaref(retv, {parts}), array("empty"))` -> `do { my $__ls_coalesce = $retv->{parts}; defined($__ls_coalesce) ? $__ls_coalesce : ["empty"] }`
- `flat_array(items)` -> `@items`
- `flat(array(parts))` -> `@parts`
- `flatten(array(parts))` -> `@parts`
- `flat_hash(extra)` -> `%extra`
- `flat(hash(extra))` -> `%extra`
- `flatten(hash(extra))` -> `%extra`
- `join_values("", array(word))` -> `join("", @word)`
- `call(Leaf)` -> `&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`

Important nuance:
- `scalar(container, key)` with a bare container name uses heuristics to decide between array indexing and hash-key access.
- `scalar(array(items), idx)` and `scalar(hash(by_name), key)` are clearer than `scalar(items, idx)` or `scalar(by_name, key)`.

### Assignment, push, and in-place mutation (`ValueExpr.pm`, `MethodLowering.pm`)
- `assign(scalar(c), CAPTURE)` -> `$c = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)`
- `assign(scalar(token), IMATCH)` -> `$token = $IMATCH`
- `assign(scalar(closing_token), LMATCH)` -> `$closing_token = $LMATCH`
- `assign(scalar(flag), or(scalar(on), scalar(off)))` -> `$flag = (($on) || ($off))`
- `assign(scalar(name), lowercase(trim(coalesce(scalaref(retv, {content}), scalar(IMATCH), " UNKNOWN "))))` -> `$name = do { my $__ls_lower = do { my $__ls_trim = do { my $__ls_coalesce = $retv->{content}; defined($__ls_coalesce) ? $__ls_coalesce : do { my $__ls_coalesce = $IMATCH; defined($__ls_coalesce) ? $__ls_coalesce : " UNKNOWN " } }; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }; defined($__ls_lower) ? lc($__ls_lower) : $__ls_lower }`
- `assign(scalar(part_count), count(coalesce(scalaref(retv, {parts}), array("empty"))))` -> `$part_count = do { my $__ls_count = do { my $__ls_coalesce = $retv->{parts}; defined($__ls_coalesce) ? $__ls_coalesce : ["empty"] }; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }`
- `assign(scalar(meta_key_count), count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback"))))` -> `$meta_key_count = do { my $__ls_count_keys = do { my $__ls_coalesce = $retv->{meta}; defined($__ls_coalesce) ? $__ls_coalesce : {"kind" => "fallback"} }; defined($__ls_count_keys) ? scalar(keys %{$__ls_count_keys}) : 0 }`
- `assign(scalar(has_kind), has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind"))` -> `$has_kind = do { my $__ls_has_key = do { my $__ls_coalesce = $retv->{meta}; defined($__ls_coalesce) ? $__ls_coalesce : {"kind" => "fallback"} }; defined($__ls_has_key) ? ((exists $__ls_has_key->{"kind"}) ? 1 : 0) : 0 }`
- `assign(hash(merged_meta), merge_hash(hash(meta), hash("stage", "normalized")))` -> `%merged_meta = (%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () })`
- `assign(hash(cleaned_meta), drop_keys(hash(meta), "debug", "span"))` -> `%cleaned_meta = (do { my $__ls_hash_init = do { my $__ls_drop_source = \%meta; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{"debug", "span"}; \%__ls_drop } else { {} } }; defined($__ls_hash_init) ? %{$__ls_hash_init} : () })`
- `assign(hash(projected_meta), pick_keys(hash(meta), "kind", "source"))` -> `%projected_meta = (do { my $__ls_hash_init = do { my $__ls_pick_source = \%meta; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "source") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }; defined($__ls_hash_init) ? %{$__ls_hash_init} : () })`
- `assign(array(projected_keys), sorted_keys(pick_keys(hash(meta), "kind", "source")))` -> `@projected_keys = (do { my $__ls_array_init = do { my $__ls_sorted_keys = do { my $__ls_pick_source = \%meta; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "source") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }; defined($__ls_sorted_keys) ? [sort keys %{$__ls_sorted_keys}] : [] }; defined($__ls_array_init) ? @{$__ls_array_init} : () })`
- `assign(scalar(capt_joined), join_values('', array(capt)))` -> `$capt_joined = join('', @capt)`
- `assign(scalar(name), coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN"))` -> `$name = do { my $__ls_coalesce = $retv->{content}; defined($__ls_coalesce) ? $__ls_coalesce : do { my $__ls_coalesce = $IMATCH; defined($__ls_coalesce) ? $__ls_coalesce : "UNKNOWN" } }`
- `assign(scalar(retv), call(Leaf))` -> `$retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`
- `assign(array(items), array(scalar(retv)))` -> `@items = ($retv)`
- `assign(array(items), array())` -> `@items = ()`
- `assign(hash(by_name), hash("kind", scalar(kind), "name", scalar(name)))` -> `%by_name = ("kind" => $kind, "name" => $name)`
- `push_value(array(items), scalar(retv))` -> `push @items, $retv`
- `push_value(items, array(scalar(tag), scalar(name)))` -> `push @items, [$tag, $name]`
- `push_value(array(assigns), array_copy(array(keyval_pairs)))` -> `push @assigns, [@keyval_pairs]`
- `substr(scalar(c), "\\s*$", "", o)` -> `$c =~ s{\\s*$}{}o`
- `substr(scalar(c), /^\"|\"$/, //, go)` -> `$c =~ s{^\"|\"$}{}go`
- `regex_subst(scalar(name), /\\s+/, "_", go)` -> `$name =~ s{\\s+}{_}go`
- `assign(scalar(pos_begin), pos $$STRING)` -> `$pos_begin = pos $$STRING`
- `assign(scalar(subprogram_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))` -> `$subprogram_statement_part = substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH)`

Important nuance:
- Helper shells may still carry raw host expressions on the right-hand side.
- The outer statement remains canonical ActionIR even when the inner expression is still Perl-flavored.

### Structured returns (`MethodLowering.pm`, `Contracts.pm`)
- `return(array("?node:", scalar(name), scalar(kind)))` -> `return ["?node:", $name, $kind]`
- `return(["semantic", { key => scalar(name) }, [123, scalar(foo_arr, idx)]])` -> `return ["semantic", { key => $name }, [123, $foo_arr[$idx]]]`
- `return({ item => scalar(foo_hash, key), list => [scalar(name), 123] })` -> `return { item => $foo_hash{$key}, list => [$name, 123] }`
- `return(hash("kind", "node", "item", scalar(foo_hash, key), "list", array(scalar(name), 123)))` -> `return {"kind" => "node", "item" => $foo_hash{$key}, "list" => [$name, 123]}`
- `return(array_copy(array(items)))` -> `return [@items]`
- `return(hash("content", coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN")))` -> `return {"content" => do { my $__ls_coalesce = $retv->{content}; defined($__ls_coalesce) ? $__ls_coalesce : do { my $__ls_coalesce = $IMATCH; defined($__ls_coalesce) ? $__ls_coalesce : "UNKNOWN" } }}`
- `return(merge_hash(hash(meta), hash("stage", "normalized")))` -> `return {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}`
- `return(drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug"))` -> `return do { my $__ls_drop_source = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{"debug"}; \%__ls_drop } else { {} } }`
- `return(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage"))` -> `return do { my $__ls_pick_source = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "stage") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }`
- `return(hash("keys", sorted_keys(pick_keys(hash(meta), "kind", "source"))))` -> `return {"keys" => do { my $__ls_sorted_keys = do { my $__ls_pick_source = \%meta; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ("kind", "source") { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }; defined($__ls_sorted_keys) ? [sort keys %{$__ls_sorted_keys}] : [] }}`
- `return(array("?subprogram_declaration:", flat_array(IMATCH_LIST)))` -> `return ["?subprogram_declaration:", @IMATCH_LIST]`
- `return(array("semantic", flat(array(parts)), scalar(name)))` -> `return ["semantic", @parts, $name]`
- `return(array("semantic", flatten(array(parts)), scalar(name)))` -> `return ["semantic", @parts, $name]`
- `return(hash(flat_hash(extra), "kind", "node", "item", scalar(name)))` -> `return {%extra, "kind" => "node", "item" => $name}`
- `return(hash(flat(hash(extra)), "kind", "node"))` -> `return {%extra, "kind" => "node"}`
- `return(hash(flatten(hash(extra)), "kind", "node"))` -> `return {%extra, "kind" => "node"}`
- `return(flat_array(items))` -> `return @items`
- `return(scalaref(myref, [A][B]{C}[D]))` -> `return $myref->[A]->[B]->{C}->[D]`
- `return_undef()` -> `return undef`

Important nuance:
- `return(payload)` is the preferred general return surface because nested `scalar`, `scalaref`, `array`, `hash`, `array_copy`, compatibility `array_values`, and `flat_*` helpers all lower inside the payload.

### Flow expressions (`FlowExpr.pm`)
- `or(scalar(on), scalar(off))` -> `(($on) || ($off))`
- `and(scalar(enabled), scalar(flag))` -> `(($enabled) && ($flag))`
- `not(scalar(off))` -> `(!($off))`
- `is_defined(scalaref(retv, {content}))` -> `defined($retv->{content})`
- `is_undefined(scalaref(retv, {type}))` -> `(!defined($retv->{type}))`
- `is_defined(coalesce(scalaref(retv, {type}), scalar(IMATCH)))` -> `defined(do { my $__ls_coalesce = $retv->{type}; defined($__ls_coalesce) ? $__ls_coalesce : $IMATCH })`
- `has_key(hash(meta), "kind")` -> `((exists $meta{"kind"}) ? 1 : 0)`
- `has_key(merge_hash(hash(meta), hash("stage", "normalized")), "kind")` -> `do { my $__ls_has_key = {%meta, do { my $__ls_merge_hash = {"stage" => "normalized"}; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }}; defined($__ls_has_key) ? ((exists $__ls_has_key->{"kind"}) ? 1 : 0) : 0 }`
- `has_key(drop_keys(hash(meta), "debug"), "kind")` -> `do { my $__ls_has_key = do { my $__ls_drop_source = \%meta; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{"debug"}; \%__ls_drop } else { {} } }; defined($__ls_has_key) ? ((exists $__ls_has_key->{"kind"}) ? 1 : 0) : 0 }`
- `num_gt(count(array(parts)), 0)` -> `(scalar(@parts) > 0)`
- `num_gt(count_keys(hash(meta)), 1)` -> `(scalar(keys %meta) > 1)`
- `eq(lowercase(trim(scalaref(retv, {type}))), "word")` -> `(do { my $__ls_lower = do { my $__ls_trim = $retv->{type}; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }; defined($__ls_lower) ? lc($__ls_lower) : $__ls_lower } eq "word")`
- `is_empty(array(items))` -> `(!@items)`
- `is_empty(scalar(name))` -> `(!defined($name) || $name eq '')`
- `is_nonempty(array(items))` -> `(!((!@items)))`
- `is_nonempty(scalar(name))` -> `(!((!defined($name) || $name eq '')))`
- `eq(scalar(kind), "SPACE")` -> `($kind eq "SPACE")`
- `ne(scalaref(retv, {type}), "COMMENTS")` -> `($retv->{type} ne "COMMENTS")`
- `gt(scalar(name), "M")` -> `($name gt "M")`
- `ge(scalar(name), "M")` -> `($name ge "M")`
- `lt(scalar(name), "M")` -> `($name lt "M")`
- `le(scalar(name), "M")` -> `($name le "M")`
- `num_eq(scalar(count), 0)` -> `($count == 0)`
- `num_ne(scalar(count), 0)` -> `($count != 0)`
- `num_gt(scalar(index), 3)` -> `($index > 3)`
- `num_ge(scalar(index), 3)` -> `($index >= 3)`
- `eq(coalesce(scalaref(retv, {type}), "UNKNOWN"), "WORD")` -> `(do { my $__ls_coalesce = $retv->{type}; defined($__ls_coalesce) ? $__ls_coalesce : "UNKNOWN" } eq "WORD")`
- `num_lt(scalar(index), 3)` -> `($index < 3)`
- `num_le(scalar(depth), 8)` -> `($depth <= 8)`
- `matches(scalar(token), /^[A-Z_]+$/)` -> `($token =~ /^[A-Z_]+$/)`

Important nuance:
- Nested forms compose recursively.
- `is_defined(...)` and `is_undefined(...)` are presence checks, not emptiness checks, so `""` and `0` remain defined.
- `if(or(scalar(on), and(not(scalar(off)), is_empty(scalar(name)))))` emits one Perl condition built from the same lowerings listed above.

### Structured control flow and output (`ControlFlow.pm`)
- `if(scalar(on))` -> `if ($on) {`
- `i(scalar(on))` -> `if ($on) {`
- `elseif(scalar(alt_on))` -> `} elsif ($alt_on) {`
- `elif(scalar(alt_on))` -> `} elsif ($alt_on) {`
- `else()` -> `} else {`
- `endif()` -> `}`
- `say("warn")` -> `say "warn"`
- `say("entered rule ", scalar(rule_name))` -> `say "entered rule ", $rule_name`
- `print("token=", scalar(token), "\n")` -> `print "token=", $token, "\n"`
- `switch(scalar(op))` -> `do { my $__ls_switch_value_1 = $op; my $__ls_switch_hit_1 = 0`
- `case("|")` inside that switch -> `if (!$__ls_switch_hit_1 && $__ls_switch_value_1 eq "|") { $__ls_switch_hit_1 = 1`
- `case(/^BEGIN_/)` inside that switch -> `if (!$__ls_switch_hit_1 && $__ls_switch_value_1 =~ /^BEGIN_/) { $__ls_switch_hit_1 = 1`
- `default()` inside that switch -> `if (!$__ls_switch_hit_1) { $__ls_switch_hit_1 = 1`
- `endcase()` -> `}`
- `endswitch()` -> `}` if there was no open case, or `} }` when it closes the current case and then the switch scope
- `switch(scalar(op), case("|", say("hit")), default(return_undef()))` -> `do { my $__ls_switch_value_1 = $op; my $__ls_switch_hit_1 = 0; if (!$__ls_switch_hit_1 && $__ls_switch_value_1 eq "|") { $__ls_switch_hit_1 = 1; say "hit" }; if (!$__ls_switch_hit_1) { $__ls_switch_hit_1 = 1; return undef } }`

Important nuance:
- Marker-style switch is better for long branch bodies.
- Composite switch is good for short one-liners.

### Array pipelines (`ArrayPipeline.pm`)
- `split(array(parts), scalar(args), /\\s*,\\s*/)` -> `@parts = split /\\s*,\\s*/, $args`
- `split(array(parts), scalar(args))` -> `@parts = split /\\s*,\\s*/, $args`
- `split_each(array(parts), /:/)` -> `@parts = map { split /:/, $_ } @parts`
- `trim_each(array(parts))` -> `@parts = map { my $v = $_; $v =~ s/^\\s+|\\s+$//g; $v } @parts`
- `filter_nonempty(array(parts))` -> `@parts = grep { length($_) } @parts`
- `lowercase_each(array(parts))` -> `@parts = map { lc($_) } @parts`
- `uppercase_each(array(parts))` -> `@parts = map { uc($_) } @parts`
- `uniq(array(parts))` -> `@parts = do { my %seen; grep { !$seen{$_}++ } @parts }`
- `filter_match(array(parts), /^[A-Z_]+$/)` -> `@parts = grep { $_ =~ /^[A-Z_]+$/ } @parts`
- `filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)` -> `@parts = grep { $_ =~ /^[A-Z_]+$/ } do { my %seen; grep { !$seen{$_}++ } map { uc($_) } @parts }`
- `split(array(parts), scalar(args), /\\s*,\\s*/); trim_each(array(parts)); filter_nonempty(array(parts))` -> `@parts = split /\\s*,\\s*/, $args; @parts = map { my $v = $_; $v =~ s/^\\s+|\\s+$//g; $v } @parts; @parts = grep { length($_) } @parts`

## Compatibility helper surface (`Contracts.pm`)
### Dispatch and push wrappers
- `call(Foo)` -> `&{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)`
- `push(Foo)` -> `push @Top, &{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)` when the current rule label is `Top`
- `push(Foo, Bar)` -> `push @Bar, &{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)`
- `push(Top, Foo, Bar)` -> `push @Bar, &{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)`
- `my $retv = call(Leaf)` -> `my $retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`
- `$retv = call(Leaf)` -> `$retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`
- `push @Top, call(Leaf)` -> `push @Top, &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`
- `push @Top, call(Leaf)->[1]` -> `push @Top, &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)->[1]`
- `return call(Leaf)` -> `return &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)`

Preferred modern replacement when you need the child result later:
- DSL: `assign(scalar(retv), call(Leaf)); push_value(array(items), scalar(retv))`
- Perl: `$retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); push @items, $retv`

### Legacy return helper family
- `return_a(Top)` -> `return ['?Top:', \@Top]`
- `return_a(Top, $x)` -> `return ['?Top:', ( $x), \@Top]`
- `return_m(Top)` -> `return ['?Top:', @IMATCH_LIST]`
- `return_ma(Top)` -> `return ['?Top:', @IMATCH_LIST, \@Top]`
- `return(Top, $x)` -> `return ['?Top:',  $x]`
- `return_im(group_open)` -> `return ["group_open", $IMATCH]`
- `return_imatch(Top, group_open)` -> `return ["group_open", $IMATCH]`
- `return_array(semantic_annotation, array(scalar(IMATCH_LIST, 0), scalar(c)))` -> `return ["semantic_annotation", [$IMATCH_LIST[0], $c]]`

Important nuance:
- `return_a(...)`, `return_m(...)`, `return_ma(...)`, and `return(label, arg)` are compatibility helpers.
- Their raw arg positions are not the best place to introduce nested helper DSL.
- For new portable authoring, prefer `return(payload)`.

### Capture and backtrack helpers
- `$CAPTURE` -> `substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)`
- `capture(Top)` -> `push @Top, substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)`
- `capture_if(Top)` -> `my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @Top, $capt if $capt`
- `CAPTURE_IF()` -> `my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @Top, $capt if $capt`
- `IBACKTRACK()` -> `pos($$STRING) = $IPOS  - length $IMATCH`
- `ibacktrack(Top)` -> `pos($$STRING) = $IPOS  - length $IMATCH`
- `BACKTRACK()` -> `pos($$STRING)  = $LSPOS - length $LMATCH`
- `backtrack(Top)` -> `pos($$STRING)  = $LSPOS - length $LMATCH`

Important nuance:
- The label argument on `capture(...)`, `capture_if(...)`, `ibacktrack(...)`, and `backtrack(...)` is compatibility syntax.
- Lowering uses the current rule context, not the literal label text inside the call.

## Classified pass-through compatibility patterns
These forms are recognized by the ActionIR scanner, contribute canonical ActionIR nodes, and avoid `RAW_PERL` fallback, but the emitted Perl is intentionally preserved verbatim.
They are important for migration audits and old-spec compatibility, not the preferred first-choice DSL for new backend-neutral authoring.

### Bare return
- DSL: `return 1; return`
- Perl: `return 1; return`
- IR node: `RETURN`

### Bare exit
- DSL: `exit; exit 1; exit(2)`
- Perl: `exit; exit 1; exit(2)`
- IR node: `EXIT`

### Prefix newline linecount
- DSL: `my @startline = substr($$STRING, 0, $IPOS) =~ /\\n/g`
- Perl: `my @startline = substr($$STRING, 0, $IPOS) =~ /\\n/g`
- IR node: `LINE_COUNT`

### Capture-substring print
- DSL: `print "<".substr($$STRING, $IPOS, $LSPOS - $IPOS -1).">\n"`
- Perl: `print "<".substr($$STRING, $IPOS, $LSPOS - $IPOS -1).">\n"`
- IR node: `PRINT`

### Bare lexical declarations
- DSL: `my $retv; my @matches`
- Perl: `my $retv; my @matches`
- IR node: `DECLARE`

### Lexical match assignment
- DSL: `my $args = $IMATCH`
- Perl: `my $args = $IMATCH`
- IR node: `ASSIGN`

### `IMATCH_LIST` destructure
- DSL: `my ($attribute_name, $value) = @IMATCH_LIST`
- Perl: `my ($attribute_name, $value) = @IMATCH_LIST`
- IR node: `ASSIGN`

### Raw regex substitution assignment
- DSL: `$args =~ s/\\s*\\)\\s*$//`
- Perl: `$args =~ s/\\s*\\)\\s*$//`
- IR node: `REGEX_SUBST`

### Bare `next`
- DSL: `next`
- Perl: `next`
- IR node: `NEXT`

### Ref-field assignment
- DSL: `$prev_node_type = $retv->{type}`
- Perl: `$prev_node_type = $retv->{type}`
- IR node: `ASSIGN`

### Position-tracking cluster
- DSL: `my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift`
- Perl: `my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift`
- IR node: `POSITION_TRACK`

### Print-foreach idiom
- DSL: `print "perl_dquotes:<<$_>>\n" foreach (@matches)`
- Perl: `print "perl_dquotes:<<$_>>\n" foreach (@matches)`
- IR node: `PRINT`

### Split/trim/filter raw idiom
- DSL: `my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args`
- Perl: `my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args`
- IR node: `ASSIGN`
- Preferred helper replacement: `split(array(parts), scalar(args), /\s*,\s*/); trim_each(array(parts)); filter_nonempty(array(parts))`

## Preferred authoring defaults
1. Prefer `declare(...)` over bare `my`.
2. Prefer `assign(...)` over raw assignment wrappers.
3. Prefer `assign(scalar(retv), call(rule))` over `$retv = call(rule)`.
4. Prefer `push_value(...)` over raw `push @target, ...` once you already have a value expression.
5. Prefer `return(payload)` over `return_a`/`return_m`/`return_ma` when you want helper-aware nested payload lowering.
6. Prefer helper pipelines over raw `split/map/grep` chains.
7. Treat pass-through classified idioms as compatibility tools, not as the default design language for new `.spec` authoring.
