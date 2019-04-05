# Coberon :sparkles:
A compiler front end for [Oberon-0](http://oberon07.com/). <br>
**NOTE**: Coberon is an Academic Project and it is still WIP.

## Compilation

> $ make all<br>

Where `in.txt` is the test input.

## Branches
`master` : A simple lexer and parser.<br>
`implement-ast` : Adds on to `master` by implementing a basic AST for a subset of the grammar along with a Symbol Table.

## Usage
`master` branch:
> $ ./parser [-t] -f <filename>
  
`implement-ast`
> $ ./parser [-t] [-a] [-s] -f <filename>
  
### Options
- `-t` Print the tokens extracted from the input by the lexer.
- `-a` Print the Abstract Syntax Tree.
- `-s` Print the contents of the Symbol Table.
- **`-f`** Input File (Mandatory)

## Future Goals
The project has a lot of scope for enhancements, namely:
- Extending support for the AST and Symbol Table to the entire Oberon-0 grammar.
- Implementing a Symbol Table for multiple scopes.
- Including better Error Recovery methods.
- Implementing a backend for the Compiler using LLVM.

## Contributing
I intend to make Coberon into a fully functional Oberon-0 compiler and all contributions are welcome.
