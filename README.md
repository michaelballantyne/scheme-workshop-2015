

## Running

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

