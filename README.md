# Pedigree Explorer

## Overview

A framework for detection and visualisation of identical-by-descent regions in human familial sequencing data, supporting the analysis of both phased and un-phased data.

![Platinum Pedigree Tree](https://github.com/amarshall1312/pedigree-explorer/blob/main/images/platinum-pedigree-tree.png "Platinum Pedigree Tree")

---

## Data Preparation

## IBD Analysis

### Prerequisites

### Running analysis

---

## GUI and Visualisations

### Setup

### Use

---

## Expected Output Directory Structure

After running all scripts, your `data/processed/` directory will contain:

```
data/processed/
├── Illumina_Preprocessing/
│   ├── clean_vcf/
│   ├── plink/
│   │   ├── final_plink_files/
│   │   ├── mapped_plink_files/
│   │   └── mapped_plink_vcf/
│   ├── genetic_map/
│   └── stats/
└── PacBio_Preprocessing/
    ├── clean_vcf/
    ├── merged_vcf/
    ├── filtered_for_split/
    ├── split/
    ├── counts/
    └── stats/
```

---

## Notes

- All scripts print a **VALIDATION** section at the end of each job. Check the scheduler output logs (`.o<jobid>` for PBS-style schedulers) to confirm steps completed successfully. Example logs are provided in `Preprocessing_Pipeline/examples/`.
- `add-map-plink.pl` is sourced from the [IBIS repository](https://github.com/williamslab/ibis) and is included here for convenience.
- Scripts use `--bind /mnt/beegfs` for Singularity/Apptainer. Replace this with your HPC storage path (e.g. `/scratch`, `/data`, `/home`) if different.

---

## Institution Details

Cranfield University  
Supervisor: Dr Alexey Larionov  
Course Lead: Dr Maria Anastasiadi  
Support staff: Sajad Falsafi Zadeh  
Course: MSc Applied Bioinformatics 2025-26

---

## License

MIT License — see [LICENSE](LICENSE).
