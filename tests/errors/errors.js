// Lexical errors: every error is reported, and the lexer keeps going after it.

var s = "abc
var t = 5;

var a = "bad \q escape";
var b = "\u12";
var c = '\xZZ';
var d = 5 @ 3;

var r = /abc
var e = 1;

/* this comment is never closed
var f = 2;