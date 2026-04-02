#!/usr/bin/env bash

# =========================
# INPUT
# =========================
# One file (illumina) OR multiple (pacbio)
INPUT_FILES=(
  "/path/to/file1.vcf.gz"
  "/path/to/file2.vcf.gz"
)

# =========================
# PLATFORM
# =========================
# Options: illumina | pacbio
DATA="pacbio"

# =========================
# TOOL
# =========================
# Options: ibis | rapid
TOOL="rapid"

# =========================
# RESOURCES
# =========================
THREADS=8
CONTAINER="/path/to/container"
MAPPING_SCRIPT="/path/to/perl_script"
GENETIC_MAP="/path/to/map"


# =========================
# OUTPUT
# =========================
OUTDIR="/path/to/output"
RUN_NAME="test_run"
