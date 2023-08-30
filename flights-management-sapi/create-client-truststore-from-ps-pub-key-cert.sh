#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
set -Eeuo pipefail

# create PKCS12 keystore, to be used as client truststore, containing public key certificate

PASS="$1" # password for both key and keystore (following PKCS12)

PS=tngaa-nonprod-public # non-prod PS name
PUBCERT="src/test/resources/certs/$PS-pub-key-cert.pem"
TRUSTSTORE="src/main/resources/certs/$PS-client-trust.p12"

echo $'\n'"Creating (after removing) keystore $TRUSTSTORE with public key to be used as client truststore:"$'\n'
rm -f "$TRUSTSTORE"
keytool -v -noprompt -importcert -file "$PUBCERT" -alias server -keystore "$TRUSTSTORE" -storetype pkcs12 -storepass "$PASS"
