export SINGULARITY_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export SINGULARITY_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
export APPTAINER_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export APPTAINER_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"

echo "Building evo2 Singularity container..."
singularity build --force evo.sif evo.def

if [ $? -eq 0 ]; then
    echo "✅ Container built successfully!"
    echo "Running evo2 tests within the container..."
    singularity run evo.sif python3 test/test_evo2.py -v
else
    echo "❌ Container build failed!"
    exit 1
fi
