"""Second explicit supplied-book epoch after restoring the unchanged size cap."""
import os
from pathlib import Path
import subprocess
import tempfile
import common as c


def main():
    original=c.load('book-inputs.json.gz')['book']
    inputs={name:c.read(name) for name in original}
    changed=[name for name in original if inputs[name]!=original[name]]
    assert changed==['docs/linkedspec-book/src/development/documentation-workflow.md']
    before=c.decode(original[changed[0]]['base64']);after=c.decode(inputs[changed[0]]['base64'])
    assert before.split()==after.split(),'wrapping only'
    supplied=c.snapshot()
    c.save('book-current-inputs.json.gz',dict(book=inputs,producers=supplied,
        qualification='The first successful render is retained. The pressure check found50003/50000 public-reference lines; wrapping four pairs restores49999 without changing words or increasing the cap.'))
    with tempfile.TemporaryDirectory(prefix='hygiene23-book-current-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==c.ROOT.stat().st_dev
        for name,packet in inputs.items():
            path=root/name;path.parent.mkdir(parents=True,exist_ok=True)
            path.write_bytes(c.decode(packet['base64']));path.chmod(packet['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        result=subprocess.run(command,cwd=root,env={k:v for k,v in os.environ.items() if not k.startswith('MDBOOK_')},capture_output=True)
        outputs={path.relative_to(root/'output').as_posix():c.read(path.relative_to(c.ROOT))
            for path in sorted((root/'output').rglob('*')) if path.is_file()}
        c.save('book-current-render.json.gz',dict(command=command,returncode=result.returncode,
            stdout_base64=c.encode(result.stdout),stderr_base64=c.encode(result.stderr),outputs=outputs))
        assert result.returncode==0
        page=c.decode(outputs['development/documentation-workflow.html']['base64']).decode()
        for text in ('112,969,338,880','119,213,043,712','55,259,061','REPO-HYGIENE.24','docs/checkpoints/REPO-HYGIENE.23/review.py'):
            assert text in page
    assert c.unchanged(supplied['inputs'])
    assert all(c.identity(name)=={key:item[key] for key in ('sha256','mode')} for name,item in inputs.items())
    print('Current complete book rendered after wrapping-only pressure correction; workspace removed.')


if __name__=='__main__':main()
