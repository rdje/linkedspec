// Read only a generated mdBook data asset; expose no host APIs inside its context.
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync(0, 'utf8');
const sandbox = { window: { search: Object.create(null) } };
vm.createContext(sandbox, { codeGeneration: { strings: false, wasm: false } });
vm.runInContext(source, sandbox, { timeout: 30000 });
process.stdout.write(JSON.stringify(sandbox.window.search));
