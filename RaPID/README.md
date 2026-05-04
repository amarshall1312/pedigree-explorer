# RaPID IBD DETECTION PIPELINE

IBD (Identity-by-Descent) segment detection using RaPID v1.7 (Naseri et al.,2019), a fast haplotype based IBD detector designed for phased genotype data.

This pipeline was developed as part of the **Pedigree Explorer** project for detection and visualisation of shared chromosomal regions in pedigree sequencing. It runs RaPID
across three window size configurations (strict w = 75, default w = 250, and lenient w = 500) on phased VCF input data then merges per-chromosome outputs for downstream 
analysis.

---

## Overview

RaPID uses a randomised path cover algorithm over positional Burrows-Wheeler transform (PBWT) based window approach. A segment is called when a sufficient number of independent
random projections covers the agreed region.

**Key features:**
- Phased


## Repository Structure

```
RaPID/
├── README.md                # This file
└── Scripts/
    └── s01_map_interpolating.sh             # Step 1: Interpolate genetic map to VCF sites
```

---
