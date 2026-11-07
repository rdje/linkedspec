"""Keep the original writer; qualify warning-free spelling with identical Python AST."""
import ast
import hashlib
import json
from pathlib import Path
import warnings

BASE = Path(__file__).resolve().parent
original = (BASE / 'repair.py').read_text()
assert original.count("helper = '''") == 1
qualified = original.replace("helper = '''", "helper = r'''", 1)
with warnings.catch_warnings(record=True) as observed:
    warnings.simplefilter('always')
    old_tree = ast.parse(original, filename=str(BASE / 'repair.py'))
    compile(original, str(BASE / 'repair.py'), 'exec')
old_warnings = [dict(category=w.category.__name__, message=str(w.message), line=w.lineno) for w in observed]
assert old_warnings and all(w['category'] == 'SyntaxWarning' and 'invalid escape sequence' in w['message'] for w in old_warnings)
with warnings.catch_warnings(record=True) as clean:
    warnings.simplefilter('always')
    new_tree = ast.parse(qualified, filename=str(BASE / 'repair_qualified.py'))
    compile(qualified, str(BASE / 'repair_qualified.py'), 'exec')
assert not clean
assert ast.dump(old_tree, include_attributes=False) == ast.dump(new_tree, include_attributes=False)
mutated = qualified.replace('flat_hash', 'flat_wrong', 1)
assert ast.dump(old_tree, include_attributes=False) != ast.dump(ast.parse(mutated), include_attributes=False)
(BASE / 'repair_qualified.py').write_text(qualified)
(BASE / 'writer-qualification.json').write_text(json.dumps(dict(
    result='PASS', original_sha256=hashlib.sha256(original.encode()).hexdigest(),
    qualified_sha256=hashlib.sha256(qualified.encode()).hexdigest(),
    observed_warning_replay=old_warnings, qualified_warnings=[], python_ast_identical=True,
    control='changed Perl helper constant yields different AST',
    limit='Compiler replay only; original writer/first SDK epochs untouched; no mutation-command outer-channel completeness credit'), indent=2) + '\n')
print('Original writer warning retained; raw-string spelling compiles cleanly with identical AST; changed helper constant rejects')
