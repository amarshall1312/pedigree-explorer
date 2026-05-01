#!/bin/bash
#PBS -N truffle_to_bed
#PBS -l nodes=1:ncpus=1
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -j oe
#PBS -m abe
#PBS -M your.email@example.com

# =====================================================================
# Script:       truffle_to_bed.sh
# Purpose:      Convert TRUFFLE .segments output files to BED format
#               for visualization in genome browsers or the Pedigree
#               Explorer GUI. Optionally filters segments by minimum
#               length (e.g., >= 2 Mb) to remove low-confidence calls.
# Author:       Ajin Eazhava
# Usage:        qsub truffle_to_bed.sh
# Dependencies: awk (standard Linux utility)
# =====================================================================

cd $PBS_O_WORKDIR

# =====================================================================
# USER INPUTS — Edit these paths before submitting
# =====================================================================
base_folder="/path/to/your/project"                # Root project directory
input_dir="${base_folder}/results/truffle"         # Folder containing .segments files
output_dir="${input_dir}/bed"                      # Output folder for BED files

# File patterns to convert:
# Set "input_pattern" to match the .segments files you want converted.
# Example patterns:
#   "truffle_L*.segments"                — all L-value sensitivity outputs
#   "truffle_default.segments"           — single default run
#   "truffle_ibs*.segments"              — IBS marker optimization outputs
input_pattern="truffle_L*.segments"

# Minimum segment length filter (in Mb)
# Set to 0 to keep all segments; recommended >= 2 Mb to remove noise
min_length_mb=2.0
# =====================================================================
# DO NOT EDIT BELOW
# =====================================================================

mkdir -p ${output_dir}

echo "=========================================="
echo "TRUFFLE Segments to BED Converter"
echo "=========================================="
date
echo ""
echo "Input directory:  ${input_dir}"
echo "Output directory: ${output_dir}"
echo "File pattern:     ${input_pattern}"
echo "Minimum length:   ${min_length_mb} Mb"
echo ""

# Loop through all matching .segments files
shopt -s nullglob
input_files=(${input_dir}/${input_pattern})
shopt -u nullglob

if [ ${#input_files[@]} -eq 0 ]; then
    echo "ERROR: No files found matching pattern: ${input_dir}/${input_pattern}"
    exit 1
fi

total_input=0
total_output=0

for input_file in "${input_files[@]}"; do
    filename=$(basename "${input_file}" .segments)
    output_file="${output_dir}/${filename}.bed"
    
    echo "------------------------------------------"
    echo "Processing: ${filename}"
    echo "------------------------------------------"
    echo "  Input:  ${input_file}"
    echo "  Output: ${output_file}"
    
    # Count input segments (excluding header)
    input_count=$(tail -n +2 "${input_file}" | wc -l)
    
    # Convert .segments to BED format
    # Columns in TRUFFLE .segments file:
    #   $1 = TYPE (IBD1/IBD2)
    #   $2 = ID1 (sample 1)
    #   $3 = ID2 (sample 2)
    #   $4 = CHROM
    #   $7 = POS Mbp (start position in Mb)
    #   $9 = LENGTH Mbp (segment length in Mb)
    #
    # BED columns produced:
    #   col1 = chromosome
    #   col2 = start position (bp)
    #   col3 = end position (bp)
    #   col4 = sample pair name (ID1_ID2)
    #   col5 = IBD type (IBD1/IBD2)
    awk -v min_len="${min_length_mb}" 'NR > 1 && $9 >= min_len {
        start = int($7 * 1000000)
        end = int(($7 + $9) * 1000000)
        print $4"\t"start"\t"end"\t"$2"_"$3"\t"$1
    }' "${input_file}" > "${output_file}"
    
    output_count=$(wc -l < "${output_file}")
    filtered_out=$((input_count - output_count))
    
    echo "  Input segments:    ${input_count}"
    echo "  Output segments:   ${output_count}"
    echo "  Filtered out:      ${filtered_out} (length < ${min_length_mb} Mb)"
    echo ""
    
    total_input=$((total_input + input_count))
    total_output=$((total_output + output_count))
done

echo "=========================================="
echo "VALIDATION"
echo "=========================================="
echo ""
echo "Files processed:        ${#input_files[@]}"
echo "Total input segments:   ${total_input}"
echo "Total output segments:  ${total_output}"
echo "Filtered out (< ${min_length_mb} Mb): $((total_input - total_output))"
echo ""
echo "Output files:"
ls -lh ${output_dir}/*.bed 2>/dev/null
echo ""
date
echo "=========================================="
