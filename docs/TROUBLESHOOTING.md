# Troubleshooting Guide

This guide addresses common issues encountered during MPAS installation on Lengau cluster.

## Table of Contents

- [Pre-Installation Issues](#pre-installation-issues)
- [Download Issues](#download-issues)
- [Compilation Issues](#compilation-issues)
- [Linking Issues](#linking-issues)
- [Runtime Issues](#runtime-issues)
- [Module System Issues](#module-system-issues)

## Pre-Installation Issues

### Issue: Cannot Access DTN Node

**Symptoms:**
```
ssh: Could not resolve hostname dtn.chpc.ac.za
```

**Solutions:**
1. Ensure you're on CHPC network or using VPN
2. Check SSH configuration
3. Contact CHPC support for network access

### Issue: Insufficient Disk Space

**Symptoms:**
```
No space left on device
```

**Solutions:**
1. Check available space: `df -h /mnt/lustre/users/msovara`
2. Clean up old builds: `rm -rf /home/apps/chpc/earth/build/build_*`
3. Request quota increase from CHPC

## Download Issues

### Issue: Git Clone Fails on DTN Node

**Symptoms:**
```
fatal: unable to access 'https://github.com/...': SSL certificate problem
```

**Solutions:**
1. Use `GIT_SSL_NO_VERIFY=1` (already in script)
2. Check network connectivity: `ping github.com`
3. Try using SSH instead of HTTPS (modify script)

### Issue: Submodule Update Fails

**Symptoms:**
```
fatal: clone of 'https://github.com/...' into submodule path failed
```

**Solutions:**
1. Manually clone submodules:
   ```bash
   cd MPAS-Model
   git submodule update --init --recursive
   ```
2. Check network connectivity
3. Retry with `GIT_SSL_NO_VERIFY=1`

### Issue: MPAS-Data Not Found

**Symptoms:**
```
CMake Error: file INSTALL cannot find MPAS-Data/atmosphere/physics_wrf/files
```

**Solutions:**
1. Ensure `download_mpas_source.sh` cloned MPAS-Data
2. Verify location: `ls -la /home/apps/chpc/earth/build/MPAS-Data`
3. Re-run download script if missing

## Compilation Issues

### Issue: Module Not Found

**Symptoms:**
```
module: command not found
```

**Solutions:**
1. Source module system:
   ```bash
   source /etc/profile.d/modules.sh
   ```
2. Check module system: `module avail`

### Issue: Intel Compiler Not Found

**Symptoms:**
```
ifort: command not found
```

**Solutions:**
1. Load Intel module:
   ```bash
   module load chpc/parallel_studio_xe/16.0.1/2016.1.150
   ```
2. Verify: `which ifort`
3. Check module availability: `module avail parallel_studio_xe`

### Issue: NetCDF Not Found

**Symptoms:**
```
CMake Error: Could not find NetCDF
```

**Solutions:**
1. Load NetCDF module:
   ```bash
   module load chpc/netcdf/4.7.4
   ```
2. Set NETCDF environment variable:
   ```bash
   export NETCDF=/apps/libs/netcdf/4.4.0
   ```
3. Check NetCDF location: `find /apps -name "libnetcdf.a" 2>/dev/null`

### Issue: PnetCDF Not Found

**Symptoms:**
```
⚠ PnetCDF not found or CMake can't detect it properly
```

**Solutions:**
1. Load PnetCDF module:
   ```bash
   module load chpc/pnetcdf
   ```
2. Verify pnetcdf-config exists:
   ```bash
   find /apps -name "pnetcdf-config" 2>/dev/null
   ```
3. Check common locations (script searches automatically)

### Issue: Fortran Compilation Error (c_loc)

**Symptoms:**
```
Error: Argument 'c_attname' to 'c_loc' at (1) must be an associated scalar POINTER
```

**Solutions:**
- Script automatically patches this
- If patch fails, manually edit:
  ```bash
  cd src/framework
  sed -i 's/c_loc(c_attname)/c_loc(c_attname(1))/' mpas_stream_inquiry.F
  ```

### Issue: Fortran Compilation Error (ieee_arithmetic)

**Symptoms:**
```
Fatal Error: Can't open module file 'ieee_arithmetic.mod'
```

**Solutions:**
- Script automatically patches this
- If patch fails, manually edit:
  ```bash
  cd src/core_atmosphere/dynamics
  sed -i '/use ieee_arithmetic/d' mpas_atm_time_integration.F
  sed -i 's/ieee_is_nan(\([^)]*\))/(\1 .ne. \1)/g' mpas_atm_time_integration.F
  ```

## Linking Issues

### Issue: Undefined Intel Symbols

**Symptoms:**
```
undefined reference to '__intel_sse2_strdup'
undefined reference to '_intel_fast_memcpy'
```

**Solutions:**
1. Script automatically adds Intel runtime libraries
2. If issue persists, manually add to linker:
   ```bash
   export LDFLAGS="-L/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64 -limf -lintlc -lsvml -lifcore"
   ```
3. Verify Intel libraries exist:
   ```bash
   ls -la /apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64/libimf.so
   ```

### Issue: MPI Symbol Lookup Error

**Symptoms:**
```
symbol lookup error: undefined symbol: MPII_F_TRUE
```

**Solutions:**
1. Ensure consistent MPI version:
   ```bash
   export MPI_ROOT=/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/mpi
   ```
2. Check MPI library path:
   ```bash
   echo $LD_LIBRARY_PATH | grep mpi
   ```

### Issue: Library Not Found at Runtime

**Symptoms:**
```
error while loading shared libraries: libmpas_framework.so: cannot open shared object file
```

**Solutions:**
1. Add library path:
   ```bash
   export LD_LIBRARY_PATH=$MPAS_ROOT/lib64:$LD_LIBRARY_PATH
   ```
2. Use module file or setup script (automatically sets this)

## Runtime Issues

### Issue: Executable Not Found

**Symptoms:**
```
mpas_atmosphere: command not found
```

**Solutions:**
1. Load MPAS module:
   ```bash
   module load /home/apps/chpc/earth/modulefiles/mpas-lengau
   ```
2. Or source setup script:
   ```bash
   source /home/apps/chpc/earth/setup_mpas_lengau.sh
   ```
3. Check installation:
   ```bash
   ls -la /home/apps/chpc/earth/bin/mpas_atmosphere
   ```

### Issue: Permission Denied

**Symptoms:**
```
Permission denied: mpas_atmosphere
```

**Solutions:**
1. Check permissions:
   ```bash
   chmod +x /home/apps/chpc/earth/bin/mpas_atmosphere
   ```
2. Verify file ownership

## Module System Issues

### Issue: Module File Not Found

**Symptoms:**
```
module: ERROR:105: Unable to locate a modulefile
```

**Solutions:**
1. Check module file exists:
   ```bash
   ls -la /home/apps/chpc/earth/modulefiles/mpas-lengau
   ```
2. Re-run installation script to regenerate module file
3. Use setup script instead:
   ```bash
   source /home/apps/chpc/earth/setup_mpas_lengau.sh
   ```

### Issue: Module Conflicts

**Symptoms:**
```
module: ERROR:102: Tcl command execution failed
```

**Solutions:**
1. Purge modules before loading:
   ```bash
   module purge
   module load chpc/parallel_studio_xe/16.0.1/2016.1.150
   module load /home/apps/chpc/earth/modulefiles/mpas-lengau
   ```

## Getting Help

If issues persist:

1. Check installation log:
   ```bash
   cat /home/apps/chpc/earth/install_log.txt
   ```

2. Enable debug mode:
   ```bash
   bash -x install_mpas_lengau.sh
   ```

3. Open an issue on GitHub with:
   - Error messages
   - Installation log
   - System information
   - Steps to reproduce

4. Contact CHPC support for cluster-specific issues

