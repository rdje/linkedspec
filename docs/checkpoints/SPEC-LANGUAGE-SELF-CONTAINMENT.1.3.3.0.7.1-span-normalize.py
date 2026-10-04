"""Independent oracle for the three repaired nested action-block frames.

Only child action blocks determine a new frame. All other data, node structure,
source strings and executable bytes must remain equal. This is an evidence
review helper, never compiler input or a general source normalizer.
"""
import json
import re


def ast(value, offset=0):
    if isinstance(value, list):
        return [ast(item, offset) for item in value]
    if not isinstance(value, dict):
        return value
    if isinstance(value.get("start"), int) and isinstance(value.get("end"), int):
        return {key: item + offset if key in ("start", "end") else item
                for key, item in value.items()}
    result = {}
    for key, item in value.items():
        child_offset = offset
        if isinstance(item, dict) and item.get("kind") == "action_block":
            if key == "block" and value.get("kind") == "block_value":
                child_offset = value["source_span"]["start"] + offset + 1 - item["source_span"]["start"]
            elif key == "body" and "body_source_span" in value:
                child_offset = value["body_source_span"]["start"] + offset + 1 - item["source_span"]["start"]
            elif key == "body_ast" and "body_span" in value:
                # Callable bodies already carry the right frame, but may be
                # nested inside a previously unframed eager/control block.
                child_offset = value["body_span"]["start"] + offset - item["source_span"]["start"]
        result[key] = ast(item, child_offset)
    return result


PACK = re.compile(r'pack\("H\*",\s*"([0-9a-f]+)"\)')


def source_equal(before, after):
    if before == after:
        return True
    if not isinstance(before, str) or not isinstance(after, str):
        return False
    old = list(PACK.finditer(before))
    new = list(PACK.finditer(after))
    if len(old) != len(new) or not old:
        return False
    # Preserve every byte outside serialized JSON action-AST operands. Decode
    # each changed operand and admit exactly the structural frame transform.
    cursor_old = cursor_new = 0
    for left, right in zip(old, new):
        if before[cursor_old:left.start(1)] != after[cursor_new:right.start(1)]:
            return False
        if left.group(1) != right.group(1):
            try:
                prior = json.loads(bytes.fromhex(left.group(1)))
                current = json.loads(bytes.fromhex(right.group(1)))
            except (ValueError, UnicodeError):
                return False
            if ast(prior) != current or prior == current:
                return False
        cursor_old, cursor_new = left.end(1), right.end(1)
    return before[cursor_old:] == after[cursor_new:]
