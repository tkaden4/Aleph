# Aleph #

Aleph is a high level programming language intended for use in
systems and embedded development. It features static typing,
generics, first class functions, and an ANSI C99 output.
It emphasizes ease of use, C compatibility, and efficiency.

## Features ##
- First-Class Functions
- Template Programming
- Rich Standard Library
- C99 Output

## Examples ##

### Hello, World! ###
<pre>
// Import the C IO library
import std.c.stdio;
// Main procedure definition
proc main() -> int = {
    // call the C puts(const char *) function
    puts("Hello, World!");
    // return 0
    0
}
</pre>

### Type Inference ###
<pre>
import std.c.stdio

proc hello = "Hello";   // Semicolon is optional, type inferred as const char *

proc main = {       // Parameters and return type optional
    puts(hello())
    0
}
</pre>

### First-Class Functions ###
<pre>
proc add\_two(a: int) = a + 2

proc map\_sum(a: int, b: int, fn: (int) -> int) = {
    if a == b fn(b)
    else fn(a) + map\_sum(a+1, b, fn)
}

import std.c.stdio;

proc main = {
    printf("%d\n", map\_sum(0, 3, add\_two))
    0
}
</pre>
