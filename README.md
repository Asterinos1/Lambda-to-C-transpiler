# Lambda-to-C transpiler (2024) Theory of Computation

- A transpiler that converts an imaginary language 'lambda' into executable C source code. 

## Current build
- The current build works perfectly without conflicts/shift reduce warnings. (except for 1, look at commit message)
- The **comp** structure is not implemented.
- Final Grade: 9/10

## How to Set Up

1. **Download all necessary files**:
    - `mylexer.l`
    - `myanalyzer.y`
    - `cgen.c`
    - `cgen.h`
    - `lambdalib.h`
    - `build.sh`

2. **Build the Compiler**:
    - Open a terminal.
    - Navigate to the directory containing the downloaded files.
    - Run the build script with the following command:
      ```bash
      chmod +x build.sh
      ```
      ```bash
      ./build.sh
      ```
    - This script will automatically create the compiler named `mycomp`.

## How to test a file

To test the compiler with an input file, follow these steps:

1. **Prepare your input file**:
    - Ensure you have a valid input file with the extension `.la` (e.g., `input.la`).

2. **Run the Compiler**:
    - Use the following command to compile your input file:
      ```bash
      ./mycomp <input.la> ex.c
      ```
    - This command will take `input.la` as the input and generate a C source file named `ex.c`.

3. **Compile the Generated C Source Code**:
    - Use a C compiler (e.g., `gcc`) to compile the generated C source file:
      ```bash
      gcc ex.c -o output
      ```
    - Replace `output` with the desired name for your executable.

## Additional Information

- Make sure you have the necessary build tools installed (e.g., `flex`, `bison`, `gcc`).
- This transpiler only checks for correct syntax. It doesn't check for further code clarity and will transfer mistakes to the output C code.
