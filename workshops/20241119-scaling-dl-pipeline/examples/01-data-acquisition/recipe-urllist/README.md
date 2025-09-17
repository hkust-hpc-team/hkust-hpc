# Recipe for URL list download

This example uses cpu partition and is currently free, please submit and try.

## Usage

#. Download this recipe folder

#. Read the examples, starting from `slurm-*.sh`

#. Run an example in cpu partition

```bash
# requires ~1GB of space
sbatch --account <your-group-account> slurm-url-list-download.sh
```

Note: it is normal to get `401 Unauthorized`, as the urls just for demonstration
