#!/bin/bash
#SBATCH -A wmu101
#SBATCH --job-name="train-mods"
#SBATCH --output="comet-out/train-mods-256.%j.%N.out"
#SBATCH --partition=gpu-shared
#SBATCH --mem=25G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=7
#SBATCH --constraint=exclusive
#SBATCH --no-requeue
#SBATCH --wait=0
#SBATCH --gres=gpu:p100:1
#SBATCH -t 48:00:00


##SLURM_JOB_ID=34292521
#CUDA_VISIBLE_DEVICES=1

IN_FOLDER=no_deepnovo_mods_free_train_lstm_hcd
time (echo "Copying data."
cp  /oasis/projects/nsf/wmu101/mtari008/DeepSNAP/data/$IN_FOLDER.tar.gz /scratch/$USER/$SLURM_JOB_ID/$IN_FOLDER.tar.gz
echo "Copied!"
echo "Extracting files."
tar xzf /scratch/$USER/$SLURM_JOB_ID/$IN_FOLDER.tar.gz -C /scratch/$USER/$SLURM_JOB_ID/
echo "Extraction done!"
ls /scratch/$USER/$SLURM_JOB_ID/$IN_FOLDER/
module load singularity
singularity exec --nv --bind /oasis/projects/nsf/wmu101/mtari008/DeepSNAP/:/DeepSNAP --bind /scratch/$USER/$SLURM_JOB_ID/:/scratch /oasis/projects/nsf/wmu101/mtari008/containers/cuda-sing.sif python3 /DeepSNAP/main.py -s comet)

