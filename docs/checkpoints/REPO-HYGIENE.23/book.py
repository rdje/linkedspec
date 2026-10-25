"""Complete supplied-book render in an automatically removed local workspace."""
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c


def main():
    tracked=set(subprocess.check_output(['git','ls-files'],cwd=c.ROOT,text=True).splitlines())
    names={path for path in tracked if path.startswith('docs/linkedspec-book/src/') or path=='docs/linkedspec-book/book.toml'}
    pending=list(names)
    while pending:
        name=pending.pop()
        for include in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.source(name).read_bytes()):
            target=((c.ROOT/name).parent/include.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in tracked
            if target not in names:names.add(target);pending.append(target)
    inputs={name:c.read(name) for name in sorted(names)}
    supplied=c.snapshot()
    c.save('book-inputs.json.gz',dict(book=inputs,producers=supplied))
    with tempfile.TemporaryDirectory(prefix='hygiene23-book-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==c.ROOT.stat().st_dev
        for name,packet in inputs.items():
            path=root/name;path.parent.mkdir(parents=True,exist_ok=True)
            path.write_bytes(c.decode(packet['base64']));path.chmod(packet['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        env={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        result=subprocess.run(command,cwd=root,env=env,capture_output=True)
        outputs={path.relative_to(root/'output').as_posix():c.read(path.relative_to(c.ROOT))
            for path in sorted((root/'output').rglob('*')) if path.is_file()}
        c.save('book-render.json.gz',dict(command=command,returncode=result.returncode,
            stdout_base64=c.encode(result.stdout),stderr_base64=c.encode(result.stderr),outputs=outputs))
        assert result.returncode==0
        page=c.decode(outputs['development/documentation-workflow.html']['base64']).decode()
        for text in ('112,969,338,880','119,213,043,712','55,259,061','REPO-HYGIENE.24','docs/checkpoints/REPO-HYGIENE.23/review.py'):
            assert text in page,'rendered maintenance guidance: '+text
    assert c.unchanged(supplied['inputs'])
    assert all(c.identity(name)=={key:row[key] for key in ('sha256','mode')} for name,row in inputs.items())
    print('Complete supplied book rendered; actual maintenance guidance verified; workspace removed.')


if __name__=='__main__':main()
