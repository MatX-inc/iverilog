#!/usr/bin/env python3
"""Check the VVP_EXECUTABLE override by executing the generated script."""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suffix', default='')
    parser.add_argument('--iverilog')
    parser.add_argument('--vvp')
    args = parser.parse_args()
    if os.name != 'posix':
        print('SKIP: VVP_EXECUTABLE shebang execution requires POSIX')
        return

    compiler = shutil.which(args.iverilog or 'iverilog' + args.suffix)
    runtime = shutil.which(args.vvp or 'vvp' + args.suffix)
    if compiler is None or runtime is None:
        raise RuntimeError('iverilog and vvp must be installed')
    compiler = str(Path(compiler).resolve())
    runtime = Path(runtime).resolve()
    source = Path(__file__).resolve().parent / 'ivltests' / 'vvp_executable.v'
    env = os.environ.copy()
    env.pop('VVP_EXECUTABLE', None)

    with tempfile.TemporaryDirectory(prefix='ivl-vvp-runtime-') as directory:
        root = Path(directory)
        relocated = root / 'runtime' / 'bin' / 'vvp'
        relocated.parent.mkdir(parents=True)
        relocated.symlink_to(runtime)
        elsewhere = root / 'elsewhere'
        elsewhere.mkdir()

        def compile_script(name, override=None):
            executable = root / (name + '.vvp')
            compile_env = env.copy()
            if override is not None:
                compile_env['VVP_EXECUTABLE'] = override
            subprocess.run([compiler, '-o', str(executable), str(source)],
                           cwd=root, env=compile_env, check=True)
            return executable

        def run_script(executable, cwd):
            result = subprocess.run([str(executable)], cwd=cwd, env=env,
                                    check=True, capture_output=True, text=True)
            if result.stdout.strip() != 'PASSED':
                raise AssertionError(result.stdout + result.stderr)

        for name, override, cwd in [
                ('absolute', str(relocated), elsewhere),
                ('relative', 'runtime/bin/vvp', root)]:
            executable = compile_script(name, override)
            header = executable.read_text().splitlines()[0]
            if header != '#! ' + override:
                raise AssertionError(f'{name}: unexpected interpreter: {header}')
            run_script(executable, cwd)

        default = compile_script('default')
        header = default.read_text().splitlines()[0]
        if not header.startswith('#! ') or header in (
                '#! ' + str(relocated), '#! runtime/bin/vvp'):
            raise AssertionError(f'default interpreter was not restored: {header}')
        subprocess.run([str(runtime), str(default)], cwd=elsewhere, env=env,
                       check=True, capture_output=True, text=True)

    print('PASSED: VVP_EXECUTABLE absolute and relative runtime relocation')


if __name__ == '__main__':
    main()
