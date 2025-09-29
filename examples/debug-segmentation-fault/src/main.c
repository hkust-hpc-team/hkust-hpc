#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "util.h"
#include "mpi_impl.h"

int main(int argc, char *argv[])
{
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);

  double start_time;
  if (rank == 0)
    start_time = MPI_Wtime();

  unsigned long expected_sum = calculate_expected_sum(size);
  unsigned long global_sum = process_array_and_calculate_sum(rank);

  MPI_Barrier(MPI_COMM_WORLD);

  if (rank == 0)
  {
    long difference = (long)(expected_sum - global_sum);
    printf("Sum: Expected = %lu, Computed = %lu, difference = %ld\n", expected_sum, global_sum, difference);
    write_file("out/result.log", size, expected_sum, global_sum, difference);

    double end_time = MPI_Wtime();
    double elapsed_time = end_time - start_time;
    printf("Total elapsed time = %.6f seconds\n", elapsed_time);
  }

  MPI_Finalize();
  return 0;
}
