#!/bin/bash
cd "$(dirname "$0")/.."
JAR=~/.m2/repository/org/antlr/antlr4-runtime/4.13.2/antlr4-runtime-4.13.2.jar

if [ ! -d output/classes ]; then
    echo "Run scripts/build.sh first"
    exit 1
fi

java -cp $JAR:output/classes Main "${1:-tests/valid/input.js}"