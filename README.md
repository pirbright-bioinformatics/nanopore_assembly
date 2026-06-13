# Nanopore Assembly Pipeline

This repository contains a pipeline for assembling Nanopore sequencing data. Below are instructions for installation, configuration, and running the pipeline.

***

## Installation

Clone the repository from GitHub:

```bash
git clone https://github.com/pirbright-bioinformatics/nanopore_assembly.git
cd nanopore_assembly
```

All required files will be available within the `nanopore_assembly` directory.

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
          barcode19,/ephemeral/tennakoon/Shaw/pipeline/fasta/UKG-26-2022_EPI_final.fas
          barcode20,/ephemeral/tennakoon/Shaw/pipeline/fasta/UKG-26-2022_EPI_final.fas
          barcode21,/ephemeral/tennakoon/Shaw/pipeline/fasta/UKG-26-2022_EPI_final.fas
          ```

          ***

          ## Execution

          Once the configuration files are prepared, run the pipeline:

          ```bash
          /path/to/nanopore_assembly/launch_pipeline.sh
          ```

          Make sure that:

          * `config.yml` and `reference.csv` are correctly set up.
          * Paths are absolute and accessible.

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

          ## Summary

          1. Clone the repository
          2. Prepare `config.yml` and `reference.csv`
          3. Run `launch_pipeline.sh`
          4. Check outputs in your specified directory

