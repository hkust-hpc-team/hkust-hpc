#!/bin/bash

#SBATCH --job-name=url-list-download
#SBATCH --output=logs/url-list-download-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --partition=cpu

mkdir -p downloads/ logs/$SLURM_JOB_ID/

cat -b url-list.txt |
  head -n 13 |
  tail -n 7 |
  awk '{print $1,$2}' |
  tr '\n' '\0' |
  xargs -0 -P 2 -n 1 bash -c 'while IFS=" " read -r name url <<< "$1" && shift; do wget -o logs/$SLURM_JOB_ID/$name.log -O downloads/$name.bin "$url"; done' --

echo "Download completed"
