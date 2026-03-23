#!/bin/bash
# s01_Illumina_Clean
#
# Cameron Brown 20Mar2026

# Crescent2 script
# Note: this script should be run on a compute node
# qsub s01_Illumina_Clean

# PBS directives
#---------------

#PBS -N s01_illumina_clean
#PBS -l nodes=1:ncpus=8
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
container="${base_folder}/containers/plink.sif"
input_vcf="${base_folder}/data/raw/illumina/CEPH1463.GRCh38.illumina-dragen.oa.vcf.gz"
output_folder="${base_folder}/data/processed/illumina/clean"
output_vcf="${output_folder}/illumina.clean.vcf.gz"

# Autosomes only
autosomes="chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22"

# Make output folder if needed
mkdir -p "${output_folder}"

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
# - biallelic sites only (-m2 -M2)
# - SNPs only (-v snps)
# - autosomes only (chr1-chr22)
# Output as compressed VCF (-Oz)
singularity exec \
  --bind /mnt/beegfs \
  "${container}" bcftools view \
  --threads "${threads}" \
  -m2 -M2 \
  -v snps \
  -r "${autosomes}" \
  -Oz \
  -o "${output_vcf}" \
  "${input_vcf}"

echo ""
echo "Filtering complete"
date
echo ""

# Indexing
echo "Indexing VCF..."
singularity exec --bind /mnt/beegfs "${container}" bcftools index \
  --threads "${threads}" \
  -t "${output_vcf}"

echo "Indexing complete"
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

echo "========================================"
echo "VALIDATION COMPLETE"
date
echo "========================================"
echo ""

# Clean-up
rm -f "$PBS_O_WORKDIR/$PBS_JOBID"