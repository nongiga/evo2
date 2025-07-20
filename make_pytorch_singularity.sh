export SINGULARITY_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export APPTAINER_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export SINGULARITY_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
export APPTAINER_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"

echo "Building evo2 PyTorch Singularity container..."
singularity build --force evo_pytorch.sif evo_pytorch.def

if [ $? -eq 0 ]; then
    echo "✅ PyTorch container built successfully!"
    echo "Running evo2 tests within the container..."
    singularity run evo_pytorch.sif python3 test/test_evo2.py -v
else
    echo "❌ PyTorch container build failed!"
    exit 1
fi 