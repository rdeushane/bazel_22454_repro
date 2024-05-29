"""
This module contains implementation for creating a library of mocks with gtest
"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _cc_custom_rule_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    print("Compiler: " + cc_toolchain.compiler)
    print("CcToolchainInfo methods: \n" + " ".join(dir(cc_toolchain)))
    print("cc_toolchain.compiler_files {}".format(cc_toolchain.compiler_files))
    print("cc_toolchain.compiler_files methods {}".format(dir(cc_toolchain.compiler_files)))
    fail("End debug dump.")

    (__, compile_outputs) = cc_common.compile(
        name = ctx.label.name,
        srcs = ctx.files.srcs,
        cc_toolchain = cc_toolchain,
        actions = ctx.actions,
        feature_configuration = cc_common.configure_features(
            ctx = ctx,
            cc_toolchain = cc_toolchain,
            requested_features = ctx.features,
        ),
    )

    (link_outputs) = cc_common.link(
        actions = ctx.actions,
        feature_configuration = cc_common.configure_features(
            ctx = ctx,
            cc_toolchain = cc_toolchain,
            requested_features = ctx.features,
        ),
        cc_toolchain = cc_toolchain,
        name = ctx.attr.name,
        compilation_outputs = compile_outputs,
    )

    return DefaultInfo(executable = link_outputs.executable)

cc_custom_rule = rule(
    implementation = _cc_custom_rule_impl,
    executable = True,
    attrs = dict(
        srcs = attr.label_list(allow_files = True),
        _cc_toolchain = attr.label(default = "@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
)
