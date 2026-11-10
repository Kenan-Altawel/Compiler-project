import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.Interval;

import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.*;

/**
 * Phase 1 driver: runs JavaScriptLexer on a .js file and prints
 *   --- Tokens Found ---
 *   Text: [lexeme] -> Type: NAME (line:column)
 *   --- Total Tokens: N ---
 *   --- Lexical Errors: N ---
 *   Error at line:column message
 *
 * A whole template literal (from the opening backtick to the closing one,
 * including any ${...} parts and nested templates) is printed as ONE token
 * of type TEMPLATE_LITERAL.
 */
public class Main {

    // false -> 1:9  (line:column)      true -> 9:1  (column:line)
    private static final boolean COLUMN_FIRST = false;

    private static final String TEMPLATE_LITERAL_NAME = "TEMPLATE_LITERAL";

    private static String pos(int line, int col) {
        return COLUMN_FIRST ? col + ":" + line : line + ":" + col;
    }

    private static class Err {
        final int line, col;
        final String msg;
        Err(int line, int col, String msg) { this.line = line; this.col = col; this.msg = msg; }
    }

    public static void main(String[] args) throws Exception {
        String path = args.length > 0 ? args[0] : "input.js";
        JavaScriptLexer lexer =
                new JavaScriptLexer(CharStreams.fromPath(Paths.get(path), StandardCharsets.UTF_8));

        // Messages that the lexer reports by itself (e.g. invalid escape inside a string).
        // Key = "line:column" (column starts at 1).
        Map<String, String> reported = new LinkedHashMap<String, String>();
        lexer.removeErrorListeners();
        lexer.addErrorListener(new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> r, Object sym, int line, int col,
                                    String msg, RecognitionException e) {
                String key = line + ":" + (col + 1);
                if (!reported.containsKey(key)) reported.put(key, msg);
            }
        });

        CharStream input = lexer.getInputStream();
        Vocabulary vocab = lexer.getVocabulary();
        List<String> found = new ArrayList<String>();
        List<Err> errors = new ArrayList<Err>();
        Set<String> used = new HashSet<String>();
        // Every open backtick: {line, column, startIndex}. The bottom of the stack is the outermost one.
        Deque<int[]> templateStarts = new ArrayDeque<int[]>();

        for (Token t = lexer.nextToken(); t.getType() != Token.EOF; t = lexer.nextToken()) {
            int line = t.getLine();
            int col = t.getCharPositionInLine() + 1;

            // ---- template literal: merge everything between the outer backticks into one token ----
            boolean closedOuterTemplate = false;
            int[] outer = null;
            if (t.getType() == JavaScriptLexer.TEMPLATE_START) {
                templateStarts.push(new int[]{line, col, t.getStartIndex()});
            } else if (t.getType() == JavaScriptLexer.TEMPLATE_END && !templateStarts.isEmpty()) {
                outer = templateStarts.pop();
                closedOuterTemplate = templateStarts.isEmpty();
            }

            if (closedOuterTemplate) {
                String text = input.getText(Interval.of(outer[2], t.getStopIndex()));
                found.add("Text: [" + show(text) + "] -> Type: " + TEMPLATE_LITERAL_NAME
                        + " (" + pos(outer[0], outer[1]) + ")");
                continue;
            }

            if (t.getChannel() == JavaScriptLexer.ERRORS) {
                String key = line + ":" + col;
                String msg = reported.get(key);
                if (msg != null) used.add(key); else msg = describe(t);
                if (t.getType() == JavaScriptLexer.UNTERMINATED_TEMPLATE && !templateStarts.isEmpty()) {
                    int[] start = templateStarts.peek();      // point at the opening backtick
                    line = start[0];
                    col = start[1];
                    templateStarts.clear();
                }
                errors.add(new Err(line, col, msg));
            } else if (templateStarts.isEmpty()) {
                // a normal token, outside of any template literal
                String name = vocab.getSymbolicName(t.getType());
                found.add("Text: [" + show(t.getText()) + "] -> Type: " + name
                        + " (" + pos(line, col) + ")");
            }
            // else: a piece inside a template literal -> already part of the merged token
        }

        for (Map.Entry<String, String> e : reported.entrySet()) {
            if (used.contains(e.getKey())) continue;
            String[] p = e.getKey().split(":");
            errors.add(new Err(Integer.parseInt(p[0]), Integer.parseInt(p[1]), e.getValue()));
        }
        Collections.sort(errors, new Comparator<Err>() {
            public int compare(Err a, Err b) {
                return a.line != b.line ? Integer.compare(a.line, b.line) : Integer.compare(a.col, b.col);
            }
        });

        System.out.println("--- Tokens Found ---");
        for (String s : found) System.out.println(s);
        System.out.println("--- Total Tokens: " + found.size() + " ---");
        System.out.println("--- Lexical Errors: " + errors.size() + " ---");
        for (Err e : errors) System.out.println("Error at " + pos(e.line, e.col) + " " + e.msg);
    }

    /** Message for an error token that the lexer did not describe itself. */
    private static String describe(Token t) {
        switch (t.getType()) {
            case JavaScriptLexer.UNTERMINATED_STRING:
                return "Invalid or unexpected token: unterminated string literal";
            case JavaScriptLexer.UNTERMINATED_TEMPLATE:
                return "Invalid or unexpected token: unterminated template literal";
            case JavaScriptLexer.UNTERMINATED_COMMENT:
                return "Invalid or unexpected token: unterminated multi-line comment";
            case JavaScriptLexer.UNTERMINATED_REGEX:
                return "Invalid or unexpected token: unterminated regular expression literal";
            case JavaScriptLexer.INVALID_ESCAPE:
                return "Invalid or unexpected token: invalid escape sequence";
            default:
                return "Invalid or unexpected token '" + show(t.getText()) + "'";
        }
    }

    /** Make new lines / tabs visible so every token stays on one output line. */
    private static String show(String s) {
        return s.replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t");
    }
}