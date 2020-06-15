#!/bin/bash
#SBATCH -A wmu101
#SBATCH --job-name="train-mods"
#SBATCH --output="train-mods.%j.%N.out"
#SBATCH --partition=gpu
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --constraint=exclusive
#SBATCH --no-requeue
#SBATCH --wait=0
#SBATCH --gres=gpu:p100:4
#SBATCH -t 06:00:00

time (echo "Copying data."
cp  /oasis/projects/nsf/wmu101/mtari008/DeepSNAP/data/train_lstm.tar.gz /scratch/$USER/$SLURM_JOB_ID/
echo "Copied!"
echo "Extracting files."
tar xzf /scratch/$USER/$SLURM_JOB_ID/train_lstm.tar.gz -C /scratch/$USER/$SLURM_JOB_ID/
echo "Extraction done!"
ls /scratch/$USER/$SLURM_JOB_ID/train_lstm/
module load singularity
singularity exec --nv --bind /oasis/projects/nsf/wmu101/mtari008/DeepSNAP/:/DeepSNAP --bind /scratch/$USER/$SLURM_JOB_ID/:/scratch /oasis/projects/nsf/wmu101/mtari008/containers/cuda-sing.sif python3 /DeepSNAP/main.py)