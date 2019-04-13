SCRIPT_TEMPLATE = """\
#!/bin/sh
{bin} version > {out}
"""

def _kustomize_version_impl(ctx):
    script = ctx.actions.declare_file("%s-run.sh" % ctx.label.name)
    script_content = SCRIPT_TEMPLATE.format(
        bin = ctx.executable._bin.basename,
        out = ctx.outputs.out or "%s.lock" % ctx.label.name,
    )
    ctx.actions.write(script, script_content, is_executable = True)

    runfiles = ctx.runfiles(files = [ctx.executable._bin])

    return [DefaultInfo(executable = script, runfiles = runfiles)]

kustomize_version = rule(
    attrs = {
        "_bin": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//kustomize:bin"),
        ),
        "out": attr.output(),
    },
    implementation = _kustomize_version_impl,
    executable = True,
)
