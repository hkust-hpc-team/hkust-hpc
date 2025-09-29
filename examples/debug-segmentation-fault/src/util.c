#include <stdio.h>
#include <stdlib.h>
#include "constants.h"
#include "util.h"

unsigned long calculate_expected_sum(int num_ranks)
{
  unsigned long arr_len = (unsigned long)num_ranks * PER_RANK_ARRAY_SIZE;
  unsigned long total_sum = (arr_len % 2 == 0) ? (arr_len / 2) * (arr_len - 1) : arr_len * ((arr_len - 1) / 2);

  return total_sum;
}

void write_file(const char *filename, int num_ranks, unsigned long expected_sum, unsigned long computed_sum, long difference)
{
  FILE *file = fopen(filename, "w");
  if (file != NULL)
  {
    fprintf(file, "%d,%lu,%lu,%ld\n", num_ranks, expected_sum, computed_sum, difference);
    fclose(file);
  }
  else
  {
    fprintf(stderr, "Warning - Could not open %s for writing\n", filename);
  }
}
