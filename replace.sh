#!/usr/bin/env bash

set -e

if [ "$(uname)" == "Darwin" ]; then
    sed=gsed
fi

find . -name 'pom.xml' -type f -exec $sed -i'' -e '
    /<artifactId>hamcrest-core<\/artifactId>/{
        N
        /<artifactId>[^<]*<\/artifactId>/{
            s/<artifactId>[^<]*<\/artifactId>/<artifactId>hamcrest<\/artifactId>/
        }
    }
    /<artifactId>hamcrest-all<\/artifactId>/{
        N
        /<artifactId>[^<]*<\/artifactId>/{
            s/<artifactId>[^<]*<\/artifactId>/<artifactId>hamcrest<\/artifactId>/
        }
    }
    /<artifactId>hamcrest-library<\/artifactId>/{
        N
        /<artifactId>[^<]*<\/artifactId>/{
            s/<artifactId>[^<]*<\/artifactId>/<artifactId>hamcrest<\/artifactId>/
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
