load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@com_github_kustless_rules_kustomize//kustomize:version.bzl", "kustomize_version")

# ==== Check the provider contents ====

def _provider_contents_test_impl(ctx):
    # Analysis-time test logic; place assertions here. Always begins with begin()
    # and ends with returning end(). If you forget to return end(), you will get an
    # error about an analysis test needing to return an instance of AnalysisTestResultInfo.
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)

    asserts.false(env, target_under_test[DefaultInfo].files_to_run == None)

    return analysistest.end(env)

# Create the testing rule to wrap the test logic. Note that this must be bound
# to a global variable due to restrictions on how rules can be defined. Also,
# its name must end with "_test".
provider_contents_test = analysistest.make(_provider_contents_test_impl)

# Macro to setup the test.
def test_provider_contents():
    # Rule under test.
    kustomize_version(
        name = "provider_contents_subject",
    )

    # Testing rule.
    provider_contents_test(
        name = "provider_contents",
        target_under_test = ":provider_contents_subject",
    )
    # Note the target_under_test attribute is how the test rule depends on
    # the real rule target.

# Entry point from the BUILD file; macro for running each test case's macro and
# declaring a test suite that wraps them together.
def build_test_suite():
    # Call all test functions and wrap their targets in a suite.
    test_provider_contents()
    # ...

    native.test_suite(
        name = "version_test",
        tests = [
            ":provider_contents",
            # ...
        ],
    )
