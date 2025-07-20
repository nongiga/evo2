# Evo2 Singularity Container Build and Test Guide (Manitou)

This guide explains how to build and test the Evo2 Singularity container on the Manitou cluster using the provided `evo.def` definition file and `make_singularity.sh` script.

## Prerequisites

### Manitou Environment
- **Cluster**: Manitou HPC cluster
- **Storage**: Use `/pmglocal/$USER/tmp` for temporary files and caching
- **Singularity**: Already available on the cluster

### Directory Structure
Ensure you have the following files in your working directory:
```
evo2/
├── evo.def                    # Singularity definition file
├── make_singularity.sh        # Build and test script
├── test/
│   └── test_evo2.py          # Test file to run
├── vortex/                    # Vortex submodule
└── ... (other evo2 files)
```

## Building the Container

### Using the Automated Script (Recommended)

The `make_singularity.sh` script automates the entire build and test process:

```bash
# Make the script executable
chmod +x make_singularity.sh

# Run the build and test process
./make_singularity.sh
```

This script will:
1. Set up proper temporary and cache directories in `/pmglocal/$USER/tmp`
2. Build the container with the name `evo.sif`
3. Run the evo2 tests automatically after successful build

### Manual Build

If you prefer to build manually:

```bash
# Set up environment variables for Manitou
export SINGULARITY_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export APPTAINER_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export SINGULARITY_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
export APPTAINER_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"

# Build the container
singularity build --force evo.sif evo.def
```

## Understanding the Container

### Base Image
The container uses NVIDIA's CUDA 12.4.1 development image:
```dockerfile
From: nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
```

### What Gets Installed
1. **System packages**: git, python3-pip, python3-tomli
2. **Python dependencies**: Extracted from `vortex/pyproject.toml`
3. **Evo2 dependencies**: setuptools, biopython, huggingface_hub, packaging, wheel
4. **Vortex ops**: CUDA kernels for attention mechanisms
5. **Evo2 package**: Main evo2 package

### Environment Setup
- CUDA paths and libraries configured
- Python path includes vortex and evo2 modules

## Testing the Container

### Automated Testing
The script automatically runs tests after building:
```bash
singularity run evo.sif python3 test/test_evo2.py -v
```

### Manual Testing

#### Interactive Shell
```bash
# Start an interactive shell in the container
singularity shell evo.sif

# Test imports
python3 -c "import evo2; print('Evo2 imported successfully')"
python3 -c "import vortex; print('Vortex imported successfully')"
```

#### Run Tests Manually
```bash
# Run the test suite
singularity run evo.sif python3 test/test_evo2.py -v

# Check CUDA availability
singularity run evo.sif python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Troubleshooting

### Common Issues

#### 1. Insufficient Disk Space
```bash
# Check available space
df -h /pmglocal/$USER

# Clean up cache
rm -rf /pmglocal/$USER/tmp/.apptainer_cache/*
```

#### 2. Memory Issues During Build
```bash
# Reduce parallel jobs in evo.def
# Change MAX_JOBS=32 to MAX_JOBS=8 in the %post section
```

#### 3. Import Errors
```bash
# Check if packages are installed
singularity run evo.sif python3 -c "import pkg_resources; print([d.project_name for d in pkg_resources.working_set])"
```

#### 4. CUDA Issues
```bash
# Verify CUDA installation
singularity run evo.sif nvcc --version
singularity run evo.sif python3 -c "import torch; print(torch.cuda.is_available())"
```

## Usage Examples

### Basic Usage
```bash
# Run a Python script
singularity run evo.sif python3 your_script.py

# Interactive development
singularity shell evo.sif
```

### With Data
```bash
# Bind mount data directories
singularity run --bind /path/to/data:/data evo.sif python3 your_script.py
```

## Maintenance

### Updating Dependencies
1. Modify requirements in `evo.def`
2. Rebuild the container
3. Run tests to ensure compatibility

### Version Control
- Keep `evo.def` in version control
- Document any changes to the build process

## Conclusion

This guide provides everything needed to build and test the Evo2 Singularity container on Manitou. The automated script simplifies the process, while manual methods offer more control when needed.

For additional support:
- [Singularity Documentation](https://docs.sylabs.io/)
- [Evo2 Repository](https://github.com/ArcInstitute/evo2)
- [Vortex Repository](https://github.com/Zymrael/vortex) 