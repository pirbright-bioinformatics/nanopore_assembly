# Nanopore Assembly Pipeline

This repository contains a pipeline for assembling Nanopore sequencing data. Below are instructions for installation, configuration, and running the pipeline.

***

## Installation

Clone the repository from GitHub:

```bash
git clone https://github.com/pirbright-bioinformatics/nanopore_assembly.git
cd nanopore_assembly
```

All required pipeline files will be available within the `nanopore_assembly` directory.

***

## Running the Pipeline

To run the pipeline, you need to prepare two configuration files:

* `config.yml`
* `reference.csv`

***

## Configuration

### 1. `config.yml`

This file defines input and output locations.

#### Format:

```yaml
output_directory: /absolute/path/to/output
data_path: /absolute/path/to/nanopore/data
```

#### Description:

* `output_directory`  
  Absolute path where pipeline results will be written.

* `data_path`  
  Absolute path to Nanopore sequencing data. The expected structure is:

```
<data_path>/fastq_pass/barcodeXX/
```

Each `barcodeXX` directory contains reads for a sample.

***

### 2. `reference.csv`

A comma-separated file mapping samples to reference genomes.

#### Format:

```csv
Sample,Reference
barcode17,/absolute/path/to/reference.fasta
barcode18,/absolute/path/to/reference.fasta
```

#### Important Notes:

* `Sample` must match the barcode directory names under:

  ```
  <data_path>/fastq_pass/
  ```

* `Reference` must be the absolute path to a FASTA file.

#### Example:

```csv
Sample,Reference
barcode17,/ephemeral/tennakoon/Shaw/pipeline/fasta/UKG-26-2022_EPI_final.fas
barcode18,/ephemeral/tennakoon/Shaw/pipeline/fasta/UKG-26-2022_EPI_final.fas
```

***

## Output

Results will be generated in the specified `output_directory`, with one folder per sample:

```
output_directory/
├── barcode17/
├── barcode18/
├── barcode19/
└── ...
```

Each directory contains the results corresponding to that sample.

***
## Suggested Workflow

The pipeline code and configuration files do **not** need to be in the same location. A recommended approach is to create a dedicated analysis directory for each run, keeping inputs, configuration, and outputs organised in one place.

### Example Setup

1. Create a working directory for your analysis:

```bash
mkdir analysis
cd analysis
```

2. Place your configuration files inside this directory:

```
analysis/
├── config.yml
├── reference.csv
```

3. Edit `config.yml` so that the `output_directory` points to your desired output location (typically within this analysis directory):

```yaml
output_directory: /absolute/path/to/analysis/output
data_path: /absolute/path/to/nanopore/data
```

***

### Running the Pipeline

You **must** run the pipeline from the **directory where the configuration files are located**:

```bash
/path/to/nanopore_assembly/launch_pipeline.sh
```

This ensures the pipeline correctly detects `config.yml` and `reference.csv`.

***

### Example Directory Structure

After setup and execution, your project may look like this:

```
analysis/
├── config.yml
├── reference.csv
└── output/
    ├── barcode17/
    ├── barcode18/
    ├── barcode19/
    └── ...
```

***


## Summary

1. Clone the repository
2. Create an analysis directory
3. Add `config.yml` and `reference.csv`
4. Run `launch_pipeline.sh` from the analysis directory
5. Check outputs in your specified output directory

***

