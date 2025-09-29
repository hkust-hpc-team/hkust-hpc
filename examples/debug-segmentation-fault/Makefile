# Makefile for segfault simulation MPI program

# Check for required MPI tools
MPICC ?= mpicc

# Verify MPI tools are available
ifeq ($(shell which $(MPICC) 2>/dev/null),)
$(error ERROR: $(MPICC) not found. Please 'module load' a compiler and MPI, or set MPICC variable)
endif

# Optimization flags and target name based on DEBUG setting
ifeq ($(DEBUG),trace)
OPTFLAGS = -g -O0
TARGET = segfault-trace
else ifdef DEBUG
OPTFLAGS = -g -O1
TARGET = segfault-debug
else
OPTFLAGS = -O3
TARGET = segfault
endif

CFLAGS = -Wall -Wextra $(OPTFLAGS)
SOURCES = $(wildcard src/*.c)
OBJECTS = $(SOURCES:src/%.c=$(BUILD_DIR)/%.o)
BUILD_DIR = build
OUTDIR = out

# Default target
all: $(BUILD_DIR)/$(TARGET)

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Create output directory if it doesn't exist
$(OUTDIR):
	mkdir -p $(OUTDIR)

# Compile the program
$(BUILD_DIR)/$(TARGET): $(OBJECTS) Makefile | $(BUILD_DIR) $(OUTDIR)
	$(MPICC) $(CFLAGS) -o $@ $(OBJECTS)

# Compile object files
$(BUILD_DIR)/%.o: src/%.c $(wildcard src/%.h) | $(BUILD_DIR)
	$(MPICC) $(CFLAGS) -c -o $@ $<

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(OUTDIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build the program (default)"
	@echo "  clean        - Remove build directory"
	@echo "  help         - Show this help message"

.PHONY: all clean help

build/main.o: src/util.h src/mpi_impl.h
build/mpi_impl.o: src/constants.h
build/util.o: src/constants.h
