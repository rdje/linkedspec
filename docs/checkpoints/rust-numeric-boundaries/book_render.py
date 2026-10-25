"""Supplied same-volume mdBook rendering with complete output custody."""
import os
from pathlib import Path
import subprocess
import tempfile
import common as c

HTML='dsl/values-containers-and-flow-helpers.html'


def render(packets):
    with tempfile.TemporaryDirectory(prefix='numeric-book-',dir=os.environ['TMPDIR']) as folder:
        root=Path(folder)
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for name,item in packets.items():
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
            file=root/name;file.parent.mkdir(parents=True,exist_ok=True)
            raw=c.decode(item['base64']);assert c.sha(raw)==item['sha256']
            file.write_bytes(raw);file.chmod(item['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        env={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        process=subprocess.run(command,cwd=root,env=env,capture_output=True)
        output=root/'output'
        files={file.relative_to(output).as_posix():c.read(file.relative_to(c.ROOT))
            for file in sorted(output.rglob('*')) if file.is_file()}
        return dict(command=command,returncode=process.returncode,
            stdout_base64=c.encode(process.stdout),stderr_base64=c.encode(process.stderr),
            outputs=files,page_base64=files.get(HTML,{}).get('base64',''))
