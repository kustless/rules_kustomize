SCRIPT_TEMPLATE = """\
#!/bin/sh
set -e
TMP=`mktemp -d`
STACK=$TMP/{name}
mkdir -p $STACK
pushd $STACK
touch {out}
{bin} edit fix
popd
cp $STACK/{out} {out_path}
rm -r $TMP
"""

def _kustomize_init_impl(ctx):
    script = ctx.actions.declare_file("%s.rc" % ctx.label.name)
    script_content = SCRIPT_TEMPLATE.format(
        name = ctx.label.name,
        bin = ctx.executable._bin.basename,
        out = ctx.outputs.out.basename,
        out_path = ctx.outputs.out.path,
    )
    ctx.actions.write(script, script_content, is_executable = True)
    ctx.actions.run(
        outputs = [ctx.outputs.out],
        executable = script,
        tools = [
            ctx.executable._bin,
        ],
    )

    return [DefaultInfo()]

kustomize_init = rule(
    attrs = {
        "_bin": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//kustomize:bin"),
        ),
        "out": attr.output(),
    },
    implementation = _kustomize_init_impl,
    executable = False,
)
