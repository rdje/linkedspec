"""Actual non-writing component checks with complete declared fixture closure."""
import json
import os
import subprocess
import common as c


def main():
    roots=['tests/language-readiness','capability_conformance','examples',
        'rust/linkedspec-runtime/tests/corpus']
    paths=subprocess.check_output(['git','ls-files',*roots],cwd=c.ROOT,text=True).splitlines()
    extras=paths+['tests/signed-array-dart/cases.json','tests/signed-array-dart/observe.dart',
        'dart/test/signed_array_selector_contract_test.dart','tools/test_dart_project_data_storage.sh',
        'tools/run_cli_conformance.pl']
    supplied=c.context(extras)
    c.save('component-inputs.json.gz',supplied)
    commands=[
        ('changed-analysis',['bash','tools/run_dart_project_data.sh','analyze','--fatal-infos','--fatal-warnings',
            'dart/lib/src/runtime/interpreter.dart','dart/test/signed_array_selector_contract_test.dart',
            'tests/signed-array-dart/observe.dart'],c.ROOT,None),
        ('whole-format',['bash','tools/run_dart_project_data.sh','format','--output=none','--set-exit-if-changed',
            '--language-version=3.9','dart'],c.ROOT,None),
        ('whole-analysis',['bash','../tools/run_dart_project_data.sh','analyze','--fatal-infos','--fatal-warnings'],c.ROOT/'dart',None),
        ('all-tests',['bash','../tools/run_dart_project_data.sh','test','--reporter=expanded'],c.ROOT/'dart',None),
        ('storage',['bash','tools/test_dart_project_data_storage.sh','--reuse-complete-dart-gate'],c.ROOT,None),
        ('primary-help',['bash','tools/run_dart_project_data.sh','--packages=dart/.dart_tool/package_config.json',
            'dart/bin/linkedspec_dart.dart','--help'],c.ROOT,None),
        ('corpus-help',['bash','../tools/run_dart_project_data.sh','run','bin/corpus_runner.dart','--help'],c.ROOT/'dart',None),
        ('corpus',['bash','../tools/run_dart_project_data.sh','run','bin/corpus_runner.dart','--corpus',
            '../rust/linkedspec-runtime/tests/corpus','--execute'],c.ROOT/'dart',None),
    ]
    for posix in (False,True):
        env=os.environ.copy();env['PERL5LIB']=''
        if posix:env['POSIXLY_CORRECT']='1'
        else:env.pop('POSIXLY_CORRECT',None)
        commands.append(('cli-posix' if posix else 'cli-default',
            ['perl','tools/run_cli_conformance.pl','--display-command','dart run bin/linkedspec_dart.dart','--',
             'bash','{{REPO_ROOT}}/tools/run_dart_project_data.sh',
             '--packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json',
             '{{REPO_ROOT}}/dart/bin/linkedspec_dart.dart'],c.ROOT,env))
    results={}
    for name,command,cwd,env in commands:
        run=c.run(command,cwd=cwd,env=env)
        stable=c.unchanged(supplied['inputs'])
        c.save('component-'+name+'.json.gz',dict(run=run,inputs_unchanged=stable,
            environment_overrides={'POSIXLY_CORRECT':'1' if name=='cli-posix' else None,'PERL5LIB':''}
                if name.startswith('cli-') else {}))
        results[name]=run['returncode']
        print(name,run['returncode'],'stable',stable,flush=True)
        assert stable
    c.save('component-result.json',dict(returncodes=results,
        limits='Whole format/analysis retain existing SDK debt separately; no complete component-gate PASS. '
            'Package discovery runs original tests and unchanged nested/context/lossless readiness consumers. '
            'Temporary generated child workspaces remain governed by their original test producers and SDK; '
            'this record retains complete first-party test/fixture inputs and actual runner channels, '
            'not every transient package kernel or installed hosted-package/SDK implementation. '
            'Separately captured signed AOT and emitted artifacts retain complete actual executable custody.'))
    assert results['whole-format']==1 and results['whole-analysis']==2
    assert all(code==0 for name,code in results.items() if name not in ('whole-format','whole-analysis'))


if __name__=='__main__':main()
