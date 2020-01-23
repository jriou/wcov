#!/bin/bash
#SBATCH --job-name='wcov'
#SBATCH --partition=all
#SBATCH --array=1-100
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=64G

module load R
Rscript postprocessing.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_JOB_ID
