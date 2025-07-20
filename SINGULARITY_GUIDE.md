# Evo2 Singularity Container Build and Test Guide

This guide explains how to build and test the Evo2 Singularity container using the provided `evo.def` definition file and `make_singularity.sh` script.

## Prerequisites

### System Requirements
- **Operating System**: Linux (tested on Ubuntu 22.04)
- **Singularity/Apptainer**: Version 3.0 or later
- **CUDA**: Compatible with CUDA 12.4.1 (for GPU support)
- **Storage**: At least 20GB free space for building and caching
- **Memory**: Minimum 8GB RAM (16GB+ recommended for faster builds)

### Required Software
```bash
# Install Singularity/Apptainer (if not already installed)
# For Ubuntu/Debian:
sudo apt-get update && sudo apt-get install -y singularity-container

# For CentOS/RHEL:
sudo yum install -y singularity

# Verify installation
singularity --version
```

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

### Method 1: Using the Automated Script (Recommended)

The `make_singularity.sh` script automates the entire build and test process:

```bash
# Make the script executable
chmod +x make_singularity.sh

# Run the build and test process
./make_singularity.sh
```

This script will:
1. Set up proper temporary and cache directories
2. Build the container with the name `evo.sif`
3. Run the evo2 tests automatically after successful build

### Method 2: Manual Build

If you prefer to build manually:

```bash
# Set up environment variables
export SINGULARITY_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export APPTAINER_TMPDIR="/pmglocal/$USER/tmp/.apptainer_tmp"
export SINGULARITY_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"
export APPTAINER_CACHEDIR="/pmglocal/$USER/tmp/.apptainer_cache"

# Build the container
singularity build --force evo.sif evo.def
```

## Understanding the Container Definition

### Base Image
The container uses NVIDIA's CUDA 12.4.1 development image as the base:
```dockerfile
From: nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
```

### Installation Process
The `%post` section installs:

1. **System Dependencies**:
   - git, python3-pip, python3-tomli
   - Creates temporary directory structure

2. **Python Dependencies**:
   - Extracts requirements from `vortex/pyproject.toml`
   - Installs PyTorch first (for CUDA compatibility)
   - Installs all other Python packages

3. **Evo2-specific Dependencies**:
   - setuptools, biopython, huggingface_hub, packaging, wheel

4. **Vortex Operations**:
   - Compiles and installs CUDA kernels for attention mechanisms
   - Installs vortex package without dependencies

5. **Evo2 Package**:
   - Installs the main evo2 package

### Environment Setup
The `%environment` section configures:
- CUDA paths and libraries
- Python path to include vortex and evo2 modules

## Testing the Container

### Automated Testing
The `make_singularity.sh` script automatically runs tests after building:

```bash
singularity run evo.sif python3 -m pytest test/test_evo2.py -v
```

### Manual Testing

#### 1. Interactive Shell
```bash
# Start an interactive shell in the container
singularity shell evo.sif

# Within the container, you can:
python3 -c "import evo2; print('Evo2 imported successfully')"
python3 -c "import vortex; print('Vortex imported successfully')"
```

#### 2. Run Tests Manually
```bash
# Run the test suite
singularity run evo.sif python3 -m pytest test/test_evo2.py -v

# Run specific test functions
singularity run evo.sif python3 -m pytest test/test_evo2.py::test_specific_function -v
```

#### 3. Test GPU Functionality
```bash
# Check CUDA availability
singularity run evo.sif python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Check GPU count
singularity run evo.sif python3 -c "import torch; print(f'GPU count: {torch.cuda.device_count()}')"
```

## Troubleshooting

### Common Build Issues

#### 1. Insufficient Disk Space
```bash
# Check available space
df -h

# Clean up Singularity cache
rm -rf /pmglocal/$USER/tmp/.apptainer_cache/*
```

#### 2. Memory Issues During Build
```bash
# Reduce parallel jobs in evo.def
# Change MAX_JOBS=32 to MAX_JOBS=8 in the %post section
```

#### 3. CUDA Compatibility Issues
```bash
# Check your CUDA version
nvidia-smi

# If different from 12.4.1, you may need to modify evo.def
# Update the From: line to match your CUDA version
```

#### 4. Permission Issues
```bash
# Ensure you have write permissions to the build directory
chmod 755 /pmglocal/$USER/tmp

# Run with sudo if necessary (not recommended for security)
sudo singularity build --force evo.sif evo.def
```

### Common Runtime Issues

#### 1. Import Errors
```bash
# Check if packages are installed correctly
singularity run evo.sif python3 -c "import pkg_resources; print([d.project_name for d in pkg_resources.working_set])"
```

#### 2. CUDA Runtime Errors
```bash
# Verify CUDA installation in container
singularity run evo.sif nvcc --version

# Check CUDA libraries
singularity run evo.sif ls -la /usr/local/cuda/lib64/
```

#### 3. Test Failures
```bash
# Run tests with more verbose output
singularity run evo.sif python3 -m pytest test/test_evo2.py -v -s

# Check test logs for specific error messages
```

## Performance Optimization

### Build Optimization
1. **Use SSD storage** for faster I/O during build
2. **Increase available RAM** to reduce swap usage
3. **Use multiple CPU cores** by adjusting MAX_JOBS in evo.def

### Runtime Optimization
1. **Bind mount data directories** for faster access
2. **Use GPU passthrough** for CUDA operations
3. **Optimize memory usage** by adjusting batch sizes

## Advanced Usage

### Customizing the Container
You can modify `evo.def` to:
- Add additional packages
- Change the base CUDA version
- Include custom scripts or configurations

### Running with Data
```bash
# Bind mount data directories
singularity run --bind /path/to/data:/data evo.sif python3 your_script.py

# Use overlay for persistent changes
singularity run --overlay overlay.img evo.sif python3 your_script.py
```

### Integration with Workflow Managers
The container can be integrated with:
- SLURM job schedulers
- Nextflow workflows
- Snakemake pipelines

## Support and Maintenance

### Updating Dependencies
To update Python packages:
1. Modify the requirements extraction in `evo.def`
2. Rebuild the container
3. Run tests to ensure compatibility

### Version Control
- Keep `evo.def` in version control
- Tag container versions for reproducibility
- Document any changes to the build process

### Monitoring
Monitor container performance and resource usage:
```bash
# Check container size
ls -lh evo.sif

# Monitor resource usage during execution
singularity run evo.sif python3 -c "import psutil; print(psutil.virtual_memory())"
```

## Conclusion

This guide provides a comprehensive approach to building and testing the Evo2 Singularity container. The automated script (`make_singularity.sh`) simplifies the process, while manual methods offer more control for advanced users.

For additional support or questions, refer to:
- [Singularity Documentation](https://docs.sylabs.io/)
- [Evo2 Repository](https://github.com/ArcInstitute/evo2)
- [Vortex Repository](https://github.com/Zymrael/vortex) 