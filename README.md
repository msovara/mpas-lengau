# MPAS Installation for Lengau Cluster

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CHPC Lengau](https://img.shields.io/badge/Cluster-Lengau-blue)](https://www.chpc.ac.za/)

Comprehensive installation guide and scripts for building and installing **MPAS (Model for Prediction Across Scales)** on the Centre for High Performance Computing (CHPC) Lengau cluster.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation Guide](#installation-guide)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## 🎯 Overview

This repository provides automated installation scripts for MPAS v8.3.1 on the Lengau HPC cluster. The installation process handles:

- **Compiler Compatibility**: Intel Parallel Studio XE 2016/2018 with GCC 4.8.5 via MPI wrappers
- **Dependency Management**: NetCDF, HDF5, PnetCDF, CMake
- **Network Constraints**: Separate DTN node downloads (compute nodes have no internet)
- **Fortran Compatibility**: Patches for GCC 4.8.5 compatibility issues
- **Linking Issues**: Intel runtime library integration for mixed compiler environments

### Key Features

✅ **Automated Installation**: Single-command installation process  
✅ **Cluster-Optimized**: Configured specifically for Lengau cluster architecture  
✅ **Error Handling**: Comprehensive error checking and informative messages  
✅ **Module System**: Creates Lengau-compatible module files  
✅ **Documentation**: Detailed troubleshooting and configuration guides  

## 🔧 Prerequisites

### Cluster Access

- Access to Lengau cluster (CHPC account)
- SSH access to DTN node (`dtn.chpc.ac.za`)
- SSH access to compute nodes

### Required Modules

The installation script automatically loads these modules, but ensure they're available:

- `chpc/parallel_studio_xe/16.0.1/2016.1.150` (or 18.0.2/2018.2.046)
- `chpc/netcdf/4.7.4` (or compatible version)
- `chpc/hdf5/1.12.0` (or compatible version)
- `chpc/cmake/3.14.4/intel-19.0.4`
- `chpc/pnetcdf` (optional, but recommended)

### Disk Space

- **Source Code**: ~500 MB
- **Build Directory**: ~2-3 GB
- **Installation**: ~500 MB
- **Total**: ~4 GB recommended

## 🚀 Quick Start

### 1. Clone This Repository

```bash
git clone https://github.com/msovara/mpas-lengau.git
cd mpas-lengau
```

### 2. Download Source Code (DTN Node)

**Important**: Compute nodes have no internet access. Download must be done on DTN node.

```bash
# SSH to DTN node
ssh msovara@dtn.chpc.ac.za

# Navigate to your workspace
cd /home/apps/chpc/earth/MPAS-8.3.1

# Copy scripts from repository
cp ~/mpas-lengau/download_mpas_source.sh .
cp ~/mpas-lengau/install_mpas_lengau.sh .

# Make executable
chmod +x download_mpas_source.sh install_mpas_lengau.sh

# Download MPAS source code
./download_mpas_source.sh
```

### 3. Install MPAS (Compute Node)

```bash
# SSH to compute node
ssh msovara@cnode0025.chpc.ac.za

# Navigate to workspace
cd /home/apps/chpc/earth/MPAS-8.3.1

# Run installation
./install_mpas_lengau.sh
```

### 4. Verify Installation

```bash
# Load MPAS module
module load chpc/earth/mpas-lengau

# Or source setup script
source /home/apps/chpc/earth/setup_mpas_lengau.sh

# Test executable
/home/apps/chpc/earth/bin/mpas_atmosphere --help
```

## 📖 Installation Guide

### Detailed Installation Steps

#### Step 1: Prepare Repository

```bash
# Clone repository locally (on your machine)
git clone https://github.com/msovara/mpas-lengau.git

# Transfer to cluster
scp -r mpas-lengau msovara@lengau.chpc.ac.za:/home/apps/chpc/
```

#### Step 2: Download Source Code (DTN Node)

The `download_mpas_source.sh` script:

1. Clones MPAS-Model repository (v8.3.1)
2. Initializes git submodules (ESMF, etc.)
3. Clones optional repositories:
   - MMM-physics
   - UGWP (Unified Gravity Wave Physics)
   - MPAS-Data (required by CMake FetchContent)

```bash
ssh msovara@dtn.chpc.ac.za
cd /home/apps/chpc/earth/MPAS-8.3.1
./download_mpas_source.sh
```

**Expected Output:**
```
=== MPAS Source Download Script ===
Build directory: /home/apps/chpc/earth/build
MPAS version: v8.3.1

Cloning MPAS-Model...
✓ MPAS-Model cloned successfully
Initializing git submodules...
✓ Git submodules initialized
Cloning MMM-physics...
✓ MMM-physics cloned successfully
Cloning MPAS-Data...
✓ MPAS-Data cloned successfully
```

#### Step 3: Install MPAS (Compute Node)

The `install_mpas_lengau.sh` script:

1. Loads required modules (Intel, NetCDF, HDF5, CMake)
2. Configures CMake build system
3. Handles PnetCDF detection and configuration
4. Applies Fortran compatibility patches
5. Builds MPAS with Intel runtime library linking
6. Installs to specified directory
7. Creates module files and setup scripts

```bash
ssh msovara@cnode0025.chpc.ac.za
cd /home/apps/chpc/earth/MPAS-8.3.1
./install_mpas_lengau.sh
```

**Expected Build Time**: 30-60 minutes depending on cluster load

## ⚙️ Configuration

### Customizing Installation Path

Edit `install_mpas_lengau.sh`:

```bash
INSTALL_DIR="/home/apps/chpc/earth/MPAS-8.3.1"
BUILD_DIR="${INSTALL_DIR}/build"
```

### Changing MPAS Version

Edit both scripts:

```bash
MPAS_VERSION="v8.3.1"  # Change to desired version
```

### Compiler Selection

The script automatically detects and uses:
- Intel Parallel Studio XE 2016 (preferred for NetCDF compatibility)
- Falls back to Intel 2018 if 2016 unavailable
- Uses GCC 4.8.5 via MPI wrappers (`mpif90`, `mpicc`)

## 🔍 Troubleshooting

### Common Issues

#### 1. Source Code Not Found

**Error:**
```
✗ MPAS source code not found at /home/apps/chpc/earth/build/MPAS-Model
```

**Solution:**
- Ensure `download_mpas_source.sh` was run on DTN node
- Verify source code exists: `ls -la /home/apps/chpc/earth/build/MPAS-Model`

#### 2. PnetCDF Not Found

**Error:**
```
⚠ PnetCDF not found or CMake can't detect it properly
```

**Solution:**
- Load PnetCDF module: `module load chpc/pnetcdf`
- Or install PnetCDF separately
- The script will attempt to find PnetCDF in common locations

#### 3. Linking Errors (Intel Symbols)

**Error:**
```
undefined reference to '__intel_sse2_strdup'
undefined reference to '_intel_fast_memcpy'
```

**Solution:**
- This is automatically handled by the script
- Intel runtime libraries are added to linker flags
- If issue persists, check Intel library path in script

#### 4. Fortran Compilation Errors

**Error:**
```
Error: Argument 'c_attname' to 'c_loc' at (1) must be an associated scalar POINTER
```

**Solution:**
- Script automatically patches `mpas_stream_inquiry.F` for GCC 4.8.5 compatibility
- If patch fails, manually apply patches in `patches/` directory

#### 5. CMake FetchContent Fails

**Error:**
```
CMake FetchContent failed to clone MPAS-Data.git
```

**Solution:**
- Ensure `download_mpas_source.sh` cloned MPAS-Data
- Verify `MPAS-Data` exists in build directory
- Script sets `FETCHCONTENT_SOURCE_DIR_MPAS_DATA` to use local copy

### Debug Mode

Enable verbose output:

```bash
bash -x install_mpas_lengau.sh
```

### Check Installation Log

```bash
cat /home/apps/chpc/earth/install_log.txt
```

## 💻 Usage

### Loading MPAS Environment

**Option 1: Module System**
```bash
module load chpc/earth/mpas-lengau
```

**Option 2: Setup Script**
```bash
source /home/apps/chpc/earth/setup_mpas_lengau.sh
```

### Running MPAS

**Important**: MPAS is an MPI application and must be run with `mpirun` or `mpiexec`, even for help commands.

```bash
# Check executable
which mpas_atmosphere

# Get help (must use mpirun)
mpirun -np 1 mpas_atmosphere --help

# Example run (adjust paths as needed)
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

**Note**: See [docs/USAGE.md](docs/USAGE.md) for detailed usage instructions and examples.

### Environment Variables

After loading module/setup script:

- `MPAS_ROOT`: Installation root directory
- `PATH`: Includes `$MPAS_ROOT/bin`
- `LD_LIBRARY_PATH`: Includes MPAS and dependency libraries
- `NETCDF`: NetCDF root directory
- `HDF5_ROOT`: HDF5 root directory

## 📁 Repository Structure

```
mpas-lengau/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── .gitignore                  # Git ignore rules
├── download_mpas_source.sh     # Source code download script (DTN node)
├── install_mpas_lengau.sh      # Main installation script (compute node)
├── CHANGELOG.md                # Version history
├── CONTRIBUTING.md             # Contribution guidelines
└── docs/                       # Additional documentation
    ├── TROUBLESHOOTING.md     # Detailed troubleshooting guide
    ├── CONFIGURATION.md        # Configuration options
    └── EXAMPLES.md            # Usage examples
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow existing code style
- Add comments for complex logic
- Update documentation for new features
- Test on Lengau cluster before submitting

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **CHPC Lengau**: Centre for High Performance Computing for cluster access
- **MPAS Development Team**: For the MPAS model and documentation
- **NCAR**: For MMM-physics package
- **NOAA-GSL**: For UGWP package

## 📧 Contact

- **Author**: Mthetho Vuyo Sovara
- **GitHub**: [@msovara](https://github.com/msovara)
- **ORCID**: [0000-0002-0498-0179](https://orcid.org/0000-0002-0498-0179)
- **Institution**: Centre for High Performance Computing, South Africa

## 📚 References

- [MPAS Official Documentation](https://mpas-dev.github.io/)
- [MPAS GitHub Repository](https://github.com/MPAS-Dev/MPAS-Model)
- [CHPC Lengau Documentation](https://www.chpc.ac.za/)
- [Intel Parallel Studio XE Documentation](https://software.intel.com/content/www/us/en/develop/tools/parallel-studio-xe.html)

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

**Current Version**: 1.0.0  
**MPAS Version**: v8.3.1  
**Last Updated**: December 2024

---

**Note**: This installation guide is specific to the Lengau cluster. For other HPC systems, modifications may be required.

