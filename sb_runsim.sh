#!/bin/bash
#SBATCH --job-name='wcov'
#SBATCH --partition=all
#SBATCH --array=1-1000
#SBATCH --time=24:00:00

module load R
Rscript runsim.R $SLURM_ARRAY_TASK_ID
