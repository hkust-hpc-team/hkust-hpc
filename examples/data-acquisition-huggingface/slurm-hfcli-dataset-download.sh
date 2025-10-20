#!/bin/bash

#SBATCH --job-name=dataset-download
#SBATCH --output=logs/dataset-download-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --partition=cpu

. .venv/bin/activate

mkdir -p datasets/

# Zhang, Ge., et al. (2024) MAP-Neo: Highly Capable and Transparent Bilingual Large Language Model Series. DOI:10.48550/arXiv.2405.1932
huggingface-cli download --repo-type dataset --local-dir "datasets/" \
  --cache-dir datasets/.cache/ --include "book_tutorial*" "book_review*" \
  --max-workers 20 "m-a-p/Matrix"

echo "Download completed"
