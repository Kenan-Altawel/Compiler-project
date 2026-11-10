//  Special case 1: single-line strings 
var a = 'It\'s a "beautiful" day';
var b = "abc\
def";
var c = "tab:\t unicode:\u0041 hex:\x41 braces:\u{1F600}";

// Special case 2: template literals
var t1 = `line one
line two`;
var t2 = `Hello ${name}, you are ${age + 1} years old`;
var t3 = `outer ${ `inner ${ x }` } done`;
var t4 = `object ${ {a: 1}.a } and cost $5`;

//  Special case 3: multi-line comments 
/* this comment
   spans several lines */
/** JSDoc comment
 * @param {number} x
 */
function f(x) { return x * 2; }

//  Numbers
var n1 = 42, n2 = 3.14, n3 = .5, n4 = 1e3, n5 = 0xFF, n6 = 0o17, n7 = 0b1010, n8 = 123n;

// Regex vs division 
var r1 = /ab+c/gi;
var r2 = /[/]/;
var d = a / b / c;
if (x) /re/.test(s);
a /= 2;
var m = "a1b22".match(/\d+/g);

// Operators 
x >>>= 1; y **= 2; z ??= 3; w ||= 4; q &&= 5; k &= 1; k |= 2; k ^= 3;
const g = (...args) => args?.length ?? 0;