#ifndef UTIL_H
#define UTIL_H

unsigned long calculate_expected_sum(int num_ranks);
void write_file(const char *filename, int num_ranks, unsigned long expected_sum, unsigned long computed_sum, long difference);

#endif // UTIL_H
