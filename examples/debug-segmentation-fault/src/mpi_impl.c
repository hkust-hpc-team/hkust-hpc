#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "constants.h"
#include "mpi_impl.h"

void initialize_array(unsigned long *array, int rank)
{
  const unsigned long base = (unsigned long)rank * PER_RANK_ARRAY_SIZE;
  for (int i = 0; i < PER_RANK_ARRAY_SIZE; i++)
  {
    // BUG: it should be array[i] = base + i;
    // This will cause a segmentation fault when rank > 1
    array[i * (rank + 1)] = base + i;
  }
}

unsigned long process_array_and_calculate_sum(int rank)
{
  unsigned long *array = malloc(PER_RANK_ARRAY_SIZE * sizeof(unsigned long));
  if (!array)
  {
    fprintf(stderr, "Rank %d: Memory allocation failed\n", rank);
    MPI_Abort(MPI_COMM_WORLD, 1);
  }

  initialize_array(array, rank);

  // Calculate local sum
  unsigned long local_sum = 0;
  for (int i = 0; i < PER_RANK_ARRAY_SIZE; i++)
  {
    local_sum += array[i];
  }

  // All reduce to get global sum
  unsigned long global_sum;
  MPI_Allreduce(&local_sum, &global_sum, 1, MPI_UNSIGNED_LONG, MPI_SUM, MPI_COMM_WORLD);

  free(array);
  return global_sum;
}
