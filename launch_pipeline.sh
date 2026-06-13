module load medaka
module load katuali
module load snakemake
module load R/cuttingedge

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_PATH="$(dirname $SCRIPT_PATH)"

snakemake -s $SCRIPT_PATH/Snakefile --cluster "sbatch " --jobs 100 --keep-going --show-failed-logs --quiet 2>&1 | grep --color=always "Error" |grep -v "rule\|echo"
