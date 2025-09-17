# Recipe for Downloading from Huggingface

This example uses cpu partition and is currently free, please submit and try.

The tutorial takes ~5GB of space after downloading, the downloaded datafiles will be used for demonstration of preprocessing as well.

## Usage

#. Download this recipe folder

#. Create and activate virtualenv

```bash
python3 -m venv --upgrade-deps .venv/
. .venv/bin/activate
```

#. Install python requirements

```bash
pip install -r requirements.txt
```

#. Read the examples, starting from `slurm-*.sh`

#. Run an example in cpu partition

```bash
# requires ~1GB of space
sbatch --account <your-group-account> slurm-hf-model-download.sh
```

```bash
# requires ~3GB of space
sbatch --account <your-group-account> slurm-hfcli-dataset-download.sh
```
