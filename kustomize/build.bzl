SCRIPT_TEMPLATE = """\
#!/bin/sh
set -e
TMP=`mktemp -d`
STACK=$TMP/{name}
{cp_cmds}
{bin} build $STACK/{path} > {out}
rm -r $TMP
"""

def _kustomize_build_impl(ctx):
    cp_each = "mkdir -p $STACK/{dirname} && cp {path} $STACK/{dirname}"
    cp_cmds = [cp_each.format(dirname = f.dirname, path = f.path) for f in ctx.files.srcs]

    script = ctx.actions.declare_file("%s-run.sh" % ctx.label.name)
    script_content = SCRIPT_TEMPLATE.format(
        name = ctx.label.name,
        cp_cmds = cp_cmds,
        bin = ctx.executable._bin.basename,
        path = ctx.attr.path,
        out = ctx.outputs.out or "%s.out.yaml" % ctx.label.name,
    )
    ctx.actions.write(script, script_content, is_executable = True)

    runfiles = ctx.runfiles(files = [ctx.executable._bin] + ctx.files.srcs)

    return [DefaultInfo(executable = script, runfiles = runfiles)]

kustomize_build = rule(
    attrs = {
        "path": attr.string(
            default = ".",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "_bin": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//kustomize:bin"),
        ),
        "out": attr.output(),
    },
    implementation = _kustomize_build_impl,
    executable = False,
)
