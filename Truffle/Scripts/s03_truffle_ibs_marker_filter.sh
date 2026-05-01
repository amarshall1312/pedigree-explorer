#!/bin/bash
#PBS -N truffle_ibs_optimization
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=03:00:00
#PBS -q three_hour
#PBS -j oe
#PBS -m abe
#PBS -M your.email@example.com

# =====================================================================
# Script:       truffle_ibs_marker_filter.sh
# Purpose:      Run TRUFFLE with optimized IBS marker thresholds for
#               distant relationship detection (e.g., first cousins,
#               second cousins). Default TRUFFLE parameters often fail
#               to detect IBD in distant relatives — this script uses
#               relaxed IBS marker counts to capture genuine signal.
# Author:       Ajin Eazhava
# Usage:        qsub truffle_ibs_marker_filter.sh
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

# IBS marker thresholds (tune these for your dataset)
# - For close relatives (siblings, parent-child): use defaults (omit these flags)
# - For first cousins: ibs1=7000, ibs2=1500 (~5 Mb / 2 Mb minimum at WGS density)
# - For more distant relatives: try lower values (e.g., ibs1=5000, ibs2=800)
ibs1_markers=7000
ibs2_markers=1500
# =====================================================================
# DO NOT EDIT BELOW
# =====================================================================

mkdir -p ${output_dir}

echo "=========================================="
echo "TRUFFLE IBS Marker Optimization"
echo "=========================================="
date
echo ""
echo "Container:    ${container}"
echo "Input VCF:    ${input_vcf}"
echo "Output:       ${output_dir}"
echo ""
echo "IBS Thresholds:"
echo "  IBS1 markers: ${ibs1_markers}"
echo "  IBS2 markers: ${ibs2_markers}"
echo ""

singularity run --bind / ${container} truffle \
    --vcf ${input_vcf} \
    --segments \
    --ibs1markers ${ibs1_markers} \
    --ibs2markers ${ibs2_markers} \
    --out ${output_dir}/truffle_ibs${ibs1_markers}_${ibs2_markers}

echo ""
echo "=========================================="
echo "VALIDATION"
echo "=========================================="
output_file="${output_dir}/truffle_ibs${ibs1_markers}_${ibs2_markers}.segments"
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
