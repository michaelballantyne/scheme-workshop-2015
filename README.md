# https://github.com/michaelballantyne/scheme-workshop-2015

## What's Here

- `scheme.scm` and `scheme-tests.scm`: a relational interpreter for a Scheme-like language and some nifty examples of running scheme code relationally.
- `state-machine.scm`: examples of relationally querying a state machine written as mutually recursive Scheme functions
- `synthesis.scm`: relational interpreter for a small typed language and examples of program synthesis, inspired by http://dl.acm.org/citation.cfm?id=2738007
- `while.scm` and `while-tests.scm`: relational interpreter for an imperative language and examples of symbolic execution and program synthesis

## The interpreted Scheme-like language

### Core language

- lambda and function call with multiple arguments, but not variadic.
- letrec, restricted to bind only lambdas
- if

### Literals
- #t
- #f
- numbers
- quote (no quasiquote)

### Primitives
Primitives are all special forms, not first class procedures. Wrap in a lambda if needed. (These could be first class, but it makes things slower and certain answers more difficult to read)

- cons, car, cdr, list, null?
- equal?
- symbol?
- and, or, not

### Pattern Matching

Pattern matching is a small subset of the syntax supported by Racket's matcher. Here's a rough grammar:

```
(match <expr>
  [<toppattern> <expr>] ...)

toppattern ::= <selfevalliteral> | <pattern> | (quasiquote <quasipattern>)
pattern ::= <var> | (? <pred> <var>)
quasipattern ::= <literal> | (<quasipattern> . <quasipattern>) | (unquote <pattern>)
selfevalliteral ::= <number> | #t | #f
literal ::= <selfevalliteral> | <symbol> | ()
var ::= <symbol>
pred ::= symbol? | number?
```

## Running the code

The included implementation of miniKanren has been tested in Racket, Petite Chez, and Vicare. It might work in other Schemes as well, or might require a little shim.
There's an older, compatible, but slower miniKanren implementation at https://github.com/webyrd/miniKanren-with-symbolic-constraints with shims for guile and chicken.
We'd appreciate contributions adding support for other Schemes!

All commands assume the repository root as the current working directory.

### Racket

```
(require "mk/mk.rkt")
```

then load your test or interpreter:

```
(load "scheme-tests.scm")
```

### Chez and Vicare

```
(load "mk/mk-vicare.scm")
(load "mk/mk.scm")
```

then load your test or interpreter:

```
(load "scheme-tests.scm")
```

I have a homebrew tap for installing Vicare on Mac OS X here: https://github.com/michaelballantyne/homebrew-vicare
