#!/bin/bash
# s01_Illumina_Clean_v3
#
# Cameron Brown 30Mar2026

# Crescent2 script
# Note: this script should be run on a compute node
# qsub s01_Illumina_Clean_v3

# PBS directives
#---------------

#PBS -N s01_illumina_clean_v3
#PBS -l nodes=1:ncpus=16
#PBS -l walltime=01:00:00
#PBS -q one_hour
#PBS -m abe
#PBS -M cameron.brown.944@cranfield.ac.uk
#PBS -j oe
#PBS -v "CUDA_VISIBLE_DEVICES="
#PBS -W sandbox=PRIVATE
#PBS -k n

ln -s "$PWD" "$PBS_O_WORKDIR/$PBS_JOBID"

# Change to working directory
cd "$PBS_O_WORKDIR"

# Calculate number of threads
threads="${PBS_NCPUS:-${NCPUS:-1}}"

# Stop at runtime errors
set -e 

# Folders and files
base_folder="/mnt/beegfs/project/Alexey_Larionov/IBD-2026"

# Main Illumina preprocessing folder
pipeline_folder="${base_folder}/data/processed/Illumina_Preprocessing"

# Subfolders
clean_vcf_folder="${pipeline_folder}/clean_vcf"
plink_folder="${pipeline_folder}/plink"
plink_files_folder="${plink_folder}/final_plink_files"
plink_vcf_folder="${plink_folder}/plink_converted_vcf"
log_folder="${pipeline_folder}/logs"


# Inputs
container="${base_folder}/containers/plink.sif"
input_vcf="${base_folder}/data/raw/illumina/CEPH1463.GRCh38.illumina-dragen.oa.vcf.gz"

# Outputs
output_vcf="${clean_vcf_folder}/illumina.clean.vcf.gz"
log_file="${log_folder}/s01_illumina_clean_$(date +%Y%m%d_%H%M%S).log"

# Autosomes only
autosomes="chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22"

# Log to file and screen
exec > >(tee -i "${log_file}")
exec 2>&1

mkdir -p \
  "${clean_vcf_folder}" \
  "${plink_files_folder}" \
  "${plink_vcf_folder}" \
  "${log_folder}"
  
# Log to file and screen
exec > >(tee -i "${log_file}")
exec 2>&1

# Check inputs exist
if [ ! -f "${input_vcf}" ]; then
  echo "ERROR: Input VCF not found: ${input_vcf}"
  exit 1
fi

if [ ! -f "${container}" ]; then
  echo "ERROR: Container not found: ${container}"
  exit 1
fi

# Start message
echo "----------------------------------------"
echo "STEP: Illumina VCF cleaning started"
date
echo "Input VCF: ${input_vcf}"
echo "Output VCF: ${output_vcf}"
echo "Container: ${container}"
echo "PBS_NODEFILE: ${PBS_NODEFILE}"
echo "PBS_NCPUS: ${PBS_NCPUS}"
echo "NCPUS: ${NCPUS}"
echo "Threads used: ${threads}"
echo "----------------------------------------"
echo ""

# Filter to:
# - PASS variants only (-f PASS)
# - biallelic sites only (-m2 -M2)
# - SNPs only (-v snps)
# - autosomes only (chr1–chr22 via -r)
# - filters out quality below 20
# - ensure coordinate-sorted output (bcftools sort)
# - output as compressed VCF (.vcf.gz, -Oz)
# - index the final file for downstream tools
singularity exec --bind /mnt/beegfs "${container}" bash -c "
  bcftools view \
    --threads ${threads} \
    -m2 -M2 \
    -f PASS \
    -v snps \
    -r ${autosomes} \
    -Ou ${input_vcf} | \
  bcftools filter \
    --threads ${threads} \
    -i 'QUAL>=20' \
    -Ou | \
  bcftools sort \
    -Oz -o ${output_vcf} && \
  bcftools index -t ${output_vcf}
"

echo ""
echo "Filtering, sorting and indexing complete"
date
echo ""

# Final confirmation
echo "----------------------------------------"
echo "STEP COMPLETE: Illumina VCF cleaned successfully"
echo "Output file:"
echo "${output_vcf}"
echo "----------------------------------------"
date
echo ""

echo "========================================"
echo "VALIDATION: Checking filtered VCF"
date
echo "========================================"
echo ""

echo "Checking for indels (should be 0)..."
singularity exec --bind /mnt/beegfs "${container}" \
bcftools view -H -v indels "${output_vcf}" | wc -l

echo ""

echo "Checking for multiallelic sites (should be 0)..."
singularity exec --bind /mnt/beegfs "${container}" \
bcftools view -H -m3 "${output_vcf}" | wc -l

echo ""

echo "Checking chromosomes present (should be chr1 to chr22 only)..."
singularity exec --bind /mnt/beegfs "${container}" \
bcftools query -f '%CHROM\n' "${output_vcf}" | sort -u

echo ""

echo "Checking FILTER distribution Before ..."
singularity exec --bind /mnt/beegfs "${container}" \
  bcftools query -f '%FILTER\n' "${input_vcf}" | sort | uniq -c
  
echo "Checking FILTER distribution After ..."
singularity exec --bind /mnt/beegfs "${container}" \
  bcftools query -f '%FILTER\n' "${output_vcf}" | sort | uniq -c
  
echo "Checking number of QUAL < 20 (should be 0)..."
singularity exec --bind /mnt/beegfs "${container}" \
  bcftools view -H -i 'QUAL<20' "${output_vcf}" | wc -l
  

echo "========================================"
echo "VALIDATION COMPLETE"
date
echo "========================================"
echo ""

# Clean-up
rm -f "$PBS_O_WORKDIR/$PBS_JOBID"