#!/bin/bash

#SBATCH --job-name=model_download
#SBATCH --output=logs/model_download-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --partition=cpu

. .venv/bin/activate

# will download to $HOME/.cache/huggingface
python3 hf_model_download.py
