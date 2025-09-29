# Debug Segmentation Fault Example

This example demonstrates debugging techniques for MPI applications that encounter segmentation faults.

## Prerequisites

**MPI (Message Passing Interface) is required** to compile and run this application.


## Building

Compile the application using the provided Makefile:

```bash
# Standard optimized build
make

# Debug build with symbols
make DEBUG=1

# Debug build with tracing (no optimization)
make DEBUG=trace
```

## Running

**On SLURM clusters:** Run the MPI application using `mpirun` or `srun`:

```bash
# Run within SLURM interactive mode using srun (SLURM systems)
srun --overlap build/segfault
```

Run on a local machine with `mpirun`:

```bash
# Run with 4 processes
mpirun -np 4 build/segfault
```

## Build Targets

- `make` - Standard optimized build (`-O3`)
- `make DEBUG=1` - Debug build with symbols (`-g -O1`)
- `make DEBUG=trace` - Debug build for tracing (`-g -O0`)
- `make clean` - Remove build artifacts
- `make help` - Show available targets

## Debugging

This example is designed to help learn debugging techniques for MPI segmentation faults. Use the debug builds with tools like `gdb` or `valgrind` for analysis.
