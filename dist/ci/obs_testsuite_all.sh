#!/bin/sh
#
# This script runs all build service test suites and calculates code coverage
#

###############################################################################
# Job configuration template
###############################################################################
#
# Project name: obs_testsuite_coverage
# Description:
#   OBS testsuites of git master branch.
#
#   Updates source code repository and runs all testsuites.
#
# Source Code Management:
#   Git:
#     Repositories: git://github.com/openSUSE/open-build-service.git
#     Branches to build: master
#     Repository browser: githubweb
#       URL: https://github.com/openSUSE/open-build-service
#     Excluded Regions:
#       docs
#
# Build Triggers:
#    Manual
#
# Build:
#   Execute shell:
#     Command: sh dist/ci/obs_testsuite_all.sh
#

###############################################################################
# Script content for 'Build' step
###############################################################################
#
# Either invoke as described above or copy into an 'Execute shell' 'Command'.
#

set -xe
. `dirname $0`/obs_testsuite_common.sh

setup_git
setup_api

echo "Enter API rails root and running rcov"
cd src/api
rake --trace test || ret=1
cd ../..

echo "Enter WebUI rails root and running rcov"
setup_api
setup_webui

cd src/webui
rake --trace test || ret=1
cd ../..

cd src/webui-testsuite
# FIXME there is no point in running this at the moment because we need to add means of starting
# webui and api server under code coverage (easy part) _and_ have jenkins merge the results
ruby ./run_acceptance_tests.rb || ret=1
cd ../..

echo "Contents of src/api/log/test.log:"
cat src/api/log/test.log
echo

echo "Contents of src/webui/log/test.log:"
cat src/webui/log/test.log
echo

cleanup
exit $ret

