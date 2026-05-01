#!/bin/bash
#PBS -N truffle_L_sensitivity
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=03:00:00
#PBS -q three_hour
#PBS -j oe
#PBS -m abe
#PBS -M your.email@example.com

# =====================================================================
# Script:       truffle_L_sensitivity.sh
# Purpose:      Run TRUFFLE across multiple -L values to assess the
#               sensitivity of IBD detection to the length parameter.
#               Lower L values are more permissive (default L=1.0 uses
#               5 Mb minimum for IBD1, 2 Mb for IBD2); higher L values
#               apply progressively stricter length thresholds.
# Author:       Ajin Eazhava
# Usage:        qsub truffle_L_sensitivity.sh
# Dependencies: TRUFFLE v1.38 (in Singularity container), bgzipped VCF
# =====================================================================

cd $PBS_O_WORKDIR

# =====================================================================
# USER INPUTS — Edit these paths before submitting
# =====================================================================
base_folder="/path/to/your/project"                       # Root project directory
container="${base_folder}/containers/truffle.sif"         # Path to TRUFFLE Singularity container
input_vcf="${base_folder}/data/processed/clean_vcf/input.vcf.gz"  # Multi-sample VCF (bgzipped + tabix-indexed)
output_dir="${base_folder}/results/truffle/L_sensitivity" # Output directory

# L values to test (1.0 = default; higher = more stringent)
L_values=(1.0 1.5 2.0 2.5 3.0)
# =====================================================================
# DO NOT EDIT BELOW
# =====================================================================

mkdir -p ${output_dir}

echo "=========================================="
echo "TRUFFLE L Parameter Sensitivity Analysis"
echo "=========================================="
date
echo ""
echo "Container:  ${container}"
echo "Input VCF:  ${input_vcf}"
echo "Output:     ${output_dir}"
echo ""
echo "Testing L values: ${L_values[@]}"
echo ""

# Run TRUFFLE for each L value
for L in "${L_values[@]}"; do
    echo "------------------------------------------"
    echo "Running TRUFFLE with L=${L}..."
    echo "------------------------------------------"
    
    singularity run --bind / ${container} truffle \
        --vcf ${input_vcf} \
        --segments \
        --L ${L} \
        --out ${output_dir}/truffle_L${L}
    
    echo "Completed L=${L}"
    echo ""
done

echo "=========================================="
echo "VALIDATION"
echo "=========================================="
echo ""
echo "Summary of segments detected:"
echo ""
printf "%-10s %s\n" "L value" "Segments"
printf "%-10s %s\n" "-------" "--------"

for L in "${L_values[@]}"; do
    output_file="${output_dir}/truffle_L${L}.segments"
    if [ -f "${output_file}" ]; then
        count=$(tail -n +2 ${output_file} | wc -l)
        printf "%-10s %s\n" "L=${L}" "${count}"
    else
        printf "%-10s %s\n" "L=${L}" "FAILED"
    fi
done

echo ""
echo "Output files:"
ls -lh ${output_dir}/truffle_L*.segments 2>/dev/null
echo ""
date
echo "=========================================="
