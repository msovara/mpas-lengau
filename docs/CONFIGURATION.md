# Configuration Guide

This guide explains how to configure and customize the MPAS installation for your needs.

## Installation Paths

### Default Paths

The installation uses these default paths:

```bash
INSTALL_DIR="/home/apps/chpc/earth/MPAS-8.3.1"
BUILD_DIR="${INSTALL_DIR}/build"
```

### Customizing Installation Directory

Edit `install_mpas_lengau.sh`:

```bash
# Change to your preferred location
INSTALL_DIR="/mnt/lustre/users/YOUR_USERNAME/SoftwareBuilds/MPAS"
BUILD_DIR="${INSTALL_DIR}/build"
```

**Note**: Ensure you have write permissions to the directory.

## MPAS Version

### Current Version

Default: `v8.3.1`

### Changing Version

Edit both `download_mpas_source.sh` and `install_mpas_lengau.sh`:

```bash
MPAS_VERSION="v8.2.0"  # Change to desired version
```

**Available Versions**: Check [MPAS Releases](https://github.com/MPAS-Dev/MPAS-Model/releases)

## Compiler Configuration

### Intel Compiler Version

The script tries Intel 2016 first, then falls back to 2018:

```bash
# Preferred (for NetCDF compatibility)
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Fallback
module load chpc/parallel_studio_xe/18.0.2/2018.2.046
```

### Forcing Specific Compiler

Edit `install_mpas_lengau.sh`:

```bash
# Force Intel 2018
if module load chpc/parallel_studio_xe/18.0.2/2018.2.046 2>/dev/null; then
    INTEL_VERSION="18.0.2"
else
    echo "✗ Intel 2018 not available"
    exit 1
fi
```

## Module Selection

### NetCDF Version

Default: `chpc/netcdf/4.7.4`

To use different version, edit script:

```bash
if module load chpc/netcdf/4.6.0 2>/dev/null; then
    echo "✓ Loaded chpc/netcdf/4.6.0"
    # ...
fi
```

### HDF5 Version

Default: `chpc/hdf5/1.12.0`

### CMake Version

Default: `chpc/cmake/3.14.4/intel-19.0.4`

## Build Options

### CMake Build Type

Default: `Release`

Options:
- `Release`: Optimized build (default)
- `Debug`: Debug symbols, no optimization
- `RelWithDebInfo`: Optimized with debug symbols

Edit script:

```bash
-DCMAKE_BUILD_TYPE=Debug  # Change to Debug or RelWithDebInfo
```

### OpenMP Support

Default: Enabled

To disable, edit script:

```bash
# Remove or comment out:
# -DENABLE_OPENMP=ON
```

### PIO Support

Default: Disabled (`-DMPAS_USE_PIO=OFF`)

To enable:

```bash
-DMPAS_USE_PIO=ON
```

**Note**: Requires PIO library installation

## PnetCDF Configuration

### Automatic Detection

Script automatically searches:
- Module-loaded PnetCDF
- Common installation paths:
  - `/apps/chpc/earth/WRF-4.0-pnc-impi/LIBRARIES/pnetcdf`
  - `/apps/chpc/earth/WRF-3.8-pnc-impi/LIBRARIES/pnetcdf`
  - `/apps/libs/pnetcdf`

### Manual PnetCDF Path

Edit script to add custom path:

```bash
# Add to search list
for pnetcdf_path in \
    "/your/custom/pnetcdf/path" \
    "/apps/chpc/earth/WRF-4.0-pnc-impi/LIBRARIES/pnetcdf" \
    # ...
```

## Intel Runtime Libraries

### Library Path

Default: `/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64`

### Libraries Linked

- `libimf.so`: Intel Math Library
- `libintlc.so`: Intel C Runtime
- `libsvml.so`: Short Vector Math Library
- `libifcore.so`: Intel Fortran Core

### Custom Library Path

Edit script:

```bash
INTEL_LIB_DIR="/your/custom/intel/lib/path"
```

## Environment Variables

### Compiler Flags

Default Fortran flags: `-O2 -fopenmp`

To customize:

```bash
FORTRAN_OPT_FLAGS="-O3"  # Higher optimization
FORTRAN_OPENMP_FLAG="-fopenmp"
```

### Linker Flags

Default: Includes Intel runtime libraries

To add custom flags:

```bash
CMAKE_LINKER_FLAGS="${CMAKE_LINKER_FLAGS} -your-custom-flag"
```

## Module File Configuration

### Module File Location

Default: `${INSTALL_DIR}/modulefiles/mpas-lengau`

### Customizing Module File

After installation, edit:

```bash
nano /apps/chpc/scripts/modules/earth/mpas-lengau
```

Add/remove module dependencies:

```tcl
# Add custom module
module load chpc/your-module/version
```

## Build Parallelization

### Number of Cores

Default: Uses all available cores

To limit:

```bash
# Edit install_mpas_lengau.sh
make -j4  # Use 4 cores instead of all
```

## Installation Verification

### Test After Installation

```bash
# Load environment
module load /apps/chpc/scripts/modules/earth/mpas-lengau

# Verify executable
which mpas_atmosphere

# Check version
mpas_atmosphere --version  # If supported

# Test help
mpas_atmosphere --help
```

## Advanced Configuration

### Custom CMake Options

Add to `install_mpas_lengau.sh`:

```bash
CMAKE_CMD="${CMAKE_CMD} -DYOUR_CUSTOM_OPTION=value"
```

### Patch Customization

Patches are applied automatically. To modify:

1. Edit patch commands in `install_mpas_lengau.sh`
2. Or create custom patch files in `patches/` directory

### Git Configuration

For private repositories or SSH:

Edit `download_mpas_source.sh`:

```bash
# Use SSH instead of HTTPS
MPAS_SOURCE_URL="git@github.com:MPAS-Dev/MPAS-Model.git"
```

## Configuration Examples

### Minimal Installation

```bash
# Disable optional features
-DMPAS_USE_PIO=OFF
-DENABLE_OPENMP=OFF
```

### Full-Featured Installation

```bash
# Enable all features
-DMPAS_USE_PIO=ON
-DENABLE_OPENMP=ON
-DCMAKE_BUILD_TYPE=Release
```

### Debug Build

```bash
-DCMAKE_BUILD_TYPE=Debug
-DCMAKE_Fortran_FLAGS="-g -O0"
```

## Saving Configuration

### Create Config File

Create `config.sh`:

```bash
#!/bin/bash
export INSTALL_DIR="/home/apps/chpc/earth/MPAS-8.3.1"
export MPAS_VERSION="v8.3.1"
export CMAKE_BUILD_TYPE="Release"
# ... other settings
```

Source before running scripts:

```bash
source config.sh
./install_mpas_lengau.sh
```

## Best Practices

1. **Version Control**: Keep track of configuration changes
2. **Documentation**: Document custom configurations
3. **Testing**: Test after configuration changes
4. **Backup**: Keep working configurations backed up
5. **Incremental Changes**: Make one change at a time

