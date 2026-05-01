#!/bin/bash
#PBS -N truffle_default
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=03:00:00
#PBS -q three_hour
#PBS -j oe
#PBS -m abe
#PBS -M your.email@example.com

# =====================================================================
# Script:       truffle_default.sh
# Purpose:      Run TRUFFLE with default parameters (-L 1.0) on a
#               multi-sample VCF for baseline IBD detection. Suitable
#               as a first pass before running parameter optimization.
# Author:       Ajin Eazhava
# Usage:        qsub truffle_default.sh
# Dependencies: TRUFFLE v1.38 (in Singularity container), bgzipped VCF
# =====================================================================

cd $PBS_O_WORKDIR

# =====================================================================
# USER INPUTS — Edit these paths before submitting
# =====================================================================
base_folder="/path/to/your/project"                    # Root project directory
container="${base_folder}/containers/truffle.sif"      # Path to TRUFFLE Singularity container
input_vcf="${base_folder}/data/processed/clean_vcf/input.vcf.gz"  # Multi-sample VCF (bgzipped + tabix-indexed)
output_dir="${base_folder}/results/truffle"            # Output directory
output_prefix="truffle_default"                        # Prefix for output files
# =====================================================================
# DO NOT EDIT BELOW
# =====================================================================

mkdir -p ${output_dir}

echo "=========================================="
echo "TRUFFLE Default Run"
echo "=========================================="
date
echo ""
echo "Container:  ${container}"
echo "Input VCF:  ${input_vcf}"
echo "Output:     ${output_dir}/${output_prefix}"
echo ""

singularity run --bind / ${container} truffle \
    --vcf ${input_vcf} \
    --segments \
    --out ${output_dir}/${output_prefix}

echo ""
echo "=========================================="
echo "VALIDATION"
echo "=========================================="
output_file="${output_dir}/${output_prefix}.segments"
if [ -f "${output_file}" ]; then
    count=$(tail -n +2 ${output_file} | wc -l)
    echo "Output file:    ${output_file}"
    echo "Segments found: ${count}"
    echo "Status:         SUCCESS"
else
    echo "Status:         FAILED — output file not created"
fi

echo ""
date
echo "=========================================="
