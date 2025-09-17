# Recipe for Downloading from Huggingface

This example uses cpu partition and is currently free, please submit and try.

The tutorial takes ~5GB of space after downloading, the downloaded datafiles will be used for demonstration of preprocessing as well.

## Usage

1. Download this recipe folder

2. Create and activate virtualenv

   ```bash
   python3 -m venv --upgrade-deps .venv/
   . .venv/bin/activate
   ```

3. Install python requirements

   ```bash
   pip install -r requirements.txt
   ```

4. Read the examples, starting from `slurm-*.sh`

5. Run an example in cpu partition

   ```bash
   # requires ~1GB of space
   sbatch --account <your-group-account> slurm-hf-model-download.sh
   ```

   ```bash
   # requires ~3GB of space
   sbatch --account <your-group-account> slurm-hfcli-dataset-download.sh
   ```
