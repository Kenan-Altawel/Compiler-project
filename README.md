# Compiler-project

Initial JavaScript lexer project structure. Source and script files are empty placeholders; implementation will be added later.

- `grammar/JavaScriptLexer.g4`: lexer grammar.
- `driver/`: Node.js entry point, token printer, and lexical error classes/listener.
- `generated/`: generated ANTLR files; do not edit manually.
- `lib/`: ANTLR tool jar used to generate the lexer.
- `scripts/`: build and run scripts.
- `tests/valid/`, `tests/errors/`, and `tests/expected/`: lexer test fixtures.
- `output/`: runtime results.
- `package.json`: Node.js project metadata and ANTLR runtime dependency.
