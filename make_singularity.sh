export SINGULARITY_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export SINGULARITY_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
export APPTAINER_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export APPTAINER_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
singularity build --force evo.sif evo.def
