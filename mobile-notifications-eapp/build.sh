#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
set -Eeuo pipefail

# Build this Mule app
# either as a standalone (student-like) build using pom.xml (default) or as a CI build using pom-ci.xml (only relevant as part of course development)
# including running all (unit) tests (can be skipped, but only if running CI build, default is false, i.e., don't skip if not provided), and
# beforehand install (which may include: build) all required local dependencies (those in the same monorepo)
#
# Usage  : build.sh <secure-props-key>   [ci-build] [skip-tests]
# Example: build.sh securePropsCryptoKey false      false

ENCRYPTKEY=$1          # Mule app secure properties en/decryption key
CI_BUILD=${2:-false}   # whether to run CI build using pom-ci.xml, if not set default to false (meaning standalone build using pom.xml)
SKIP_TESTS=${3:-false} # whether to skip (MUnit) tests, if not set default to false

scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd $scriptdir

pom=pom.xml
pomci=pom-ci.xml
pomtmp=pom.xml.tmp-during-build

sts="$scriptdir/../settings.xml"
mvns="mvn -s $sts -ff -U"

UNIT="$(basename $scriptdir)"
WTDIR="$(basename $(dirname $scriptdir))"

# build local dependencies, skipping tests
../apps-commons/build.sh "$ENCRYPTKEY" "$CI_BUILD" true

if [ "$CI_BUILD" != "true" ]; then
	# run standalone (student-like) build using pom.xml
	# install the parent POM this app depends on
	../install-parent-poms.sh
	echo "Building like a student $UNIT in $WTDIR"
	$mvns verify -Dencrypt.key=$ENCRYPTKEY
else
	# run CI build using pom-ci.xml
	# install the parent POM this app depends on
	../../../../../install-parent-poms.sh
	# work around limitation in Mule Maven plugin in that POM must always be called pom.xml
	mv $pom $pomtmp; cp $pomci $pom
	echo "Building $UNIT in $WTDIR"
	if [ "$SKIP_TESTS" == "true" ]; then skipTests="-DskipTests"; else skipTests=""; fi
	$mvns verify -Dencrypt.key=$ENCRYPTKEY $skipTests
	# undo workaround for limitation in Mule Maven plugin
	mv $pomtmp $pom
fi
