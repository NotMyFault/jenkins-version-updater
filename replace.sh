#!/usr/bin/env bash

set -e

if [ "$(uname)" == "Darwin" ]; then
    sed=gsed
fi

find . -name 'pom.xml' -type f -exec $sed -i'' -e '
    /<artifactId>bom-2.361.x<\/artifactId>/{
        N
        /<artifactId>[^<]*<\/artifactId>/{
            s/<artifactId>[^<]*<\/artifactId>/<artifactId>bom-2.387.x<\/artifactId>/
        }
    }
    /<jenkins.version>2.361.4<\/jenkins.version>/{
        N
        /<jenkins.version>[^<]*<\/jenkins.version>/{
            s/<jenkins.version>[^<]*<\/jenkins.version>/<jenkins.version>2.387.3<\/jenkins.version>/
        }
    }
' {} +

if git diff --exit-code > /dev/null
then
    echo "No replacements required"
    exit
fi

if grep -q '<artifactId>plugin</artifactId>' pom.xml
then
    mvn versions:update-parent -DparentVersion=4.64
    rm -f pom.xml.versionsBackup
fi

spotless_disabled=$(mvn help:evaluate -Dexpression=spotless.check.skip -q -DforceStdout)
if ! $spotless_disabled; then
    mvn spotless:apply
fi

git status
echo "Replacement completed."
