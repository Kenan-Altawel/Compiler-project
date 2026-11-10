#!/bin/bash
cd "$(dirname "$0")/.."
JAR=~/.m2/repository/org/antlr/antlr4-runtime/4.13.2/antlr4-runtime-4.13.2.jar

mkdir -p gen output/classes

# 1) توليد بنفس إصدار المكتبة (4.13.2)
java -jar lib/antlr-4.13.2-complete.jar -Dlanguage=Java -Xexact-output-dir -o gen grammar/JavaScriptLexer.g4 &&

# 2) كمبايل
javac --release 17 -cp $JAR -d output/classes gen/*.java driver/Main.java &&

echo "Build OK"