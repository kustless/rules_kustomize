def _kustomize_build_impl(ctx):
    # build the directory
    build = " ".join([
        ctx.executable.bin.path,
        "build",
        "--output %s" % ctx.outputs.manifests.path,
    ])

    cp_cmds = []
    for f in ctx.files.srcs:
        suffix = f.path[len(ctx.label.package) + 1:]
        cp_cmds.append("mkdir -p $STACK && cp %s $STACK/%s" % (f.path, suffix))

    ctx.action(
        inputs = ctx.files.srcs + ctx.files.bin,
        outputs = [ctx.outputs.manifests],
        command = "\n".join([
            "set -e",
            "TMP=`mktemp -d`",
            "STACK=$TMP/%s" % (ctx.attr.name,),
            "\n".join(cp_cmds),
            "%s $STACK" % (build,),
            "rm -r $TMP",
        ]),
    )

kustomize_build = rule(
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "bin": attr.label(
            default = Label("//kustomize:bin"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
    },
    outputs = {"manifests": "%{name}.out.yaml"},
    implementation = _kustomize_build_impl,
    executable = False,
)
