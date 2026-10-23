"""One-shot public calibration of the retained Rust negative-index coercion."""
import json
import common as c
import context


def main():
    command = c.load('native-rust.json.gz')['rows'][0]['run']['command'][0]
    binary = c.load('native-rust-artifact.json')
    assert c.identity(command) == {key:binary[key] for key in ('sha256','mode')}
    source_path = 'rust/linkedspec-runtime/src/engine.rs'
    source = c.read(source_path)
    assert c.load('native-inputs.json.gz')['context']['inputs'][source_path] == c.identity(source_path)
    program = 'Top: /x/\n I { items=[10,20,30]; chosen_index=-2; return([chosen_index,items[chosen_index],items[-1],items[-4],items[0]]) }\n'
    trace = '.linkedspec-data/verification/signed-index-rust-clamp.trace.log'
    assert not (c.ROOT/trace).exists()
    epoch = context.snapshot()
    c.write_new('rust-clamp-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'rust_clamp.py'),engine=source,
        binary=binary,program=program,trace_path=trace,
        scope='Exact original Rust CLI artifact and current owned engine; original negative coercion test remains unchanged.'))
    run = c.run([command,'--inline-spec',program,'--input','x','--trace','debug',
        '--trace-file',trace,'--trace-mode','route','--trace-reset'])
    stable = c.unchanged(epoch['inputs'])
    value = json.loads(c.decode(run['stdout_base64'])) if run['returncode'] == 0 else None
    c.write_new('rust-clamp-run.json.gz',dict(run=run,inputs_unchanged=stable,
        trace=c.read(trace),value=value,
        scope='Public value calibration: negative variable remains -2 before indexing; three negative selectors and index0 all return the first element. This is original Rust behavior, not new signed-policy acceptance.'))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    assert value == [-2,10,10,10,10]
    text = c.decode(source['base64'])
    assert b'let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;' in text
    assert b'(RuntimeValue::Number(-1.0), serde_json::json!("a"))' in text
    assert c.identity(command) == {key:binary[key] for key in ('sha256','mode')}
    print('Rust clamp calibrated: negative -2 is preserved as a value, while negative indexes select element0; actual binary/source/trace retained')


if __name__ == '__main__':
    main()
