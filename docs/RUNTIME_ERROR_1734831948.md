# Fixing Runtime Error 1734831948

## Error

```
mpirun -np 1 mpas_atmosphere --help
application called MPI_Abort(MPI_COMM_WORLD, 1734831948) - process 0
```

## Diagnosis

This error occurs when MPAS fails during initialization. The error code `1734831948` is a specific MPAS error code indicating a runtime failure.

## Common Causes and Solutions

### 1. Missing Shared Libraries

**Check:**
```bash
ldd /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | grep "not found"
```

**Fix:**
```bash
# Ensure lib64 is in LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH

# Verify libraries exist
ls -la /home/apps/chpc/earth/MPAS-8.3.1/lib64/*.so
```

### 2. Library Path Issues

**Check:**
```bash
echo $LD_LIBRARY_PATH | grep lib64
```

**Fix:**
```bash
# Update module file to include lib64
nano /home/apps/chpc/earth/MPAS-8.3.1/modulefiles/mpas-lengau

# Add this line:
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib64
```

### 3. Missing Runtime Dependencies

**Check for missing Intel runtime libraries:**
```bash
ldd /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | grep -E 'libimf|libintlc|libsvml|libifcore'
```

**Fix:**
```bash
# Add Intel runtime libraries
export LD_LIBRARY_PATH=/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH
```

### 4. Try Running from Build Directory

Sometimes the installed executable has issues. Try running directly from build:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Model/build_cmake
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
mpirun -np 1 ./bin/mpas_atmosphere --help
```

### 5. Check Executable Size

The executable should be small (13KB) as it's a wrapper that loads libmpas_atmosphere.so:

```bash
ls -lh /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere
# Should be around 13KB
```

If it's much larger, there might be an issue with the installation.

### 6. Verify Library Loading

```bash
# Check if library can be loaded
ldd /home/apps/chpc/earth/MPAS-8.3.1/lib64/libmpas_atmosphere.so | head -20
```

### 7. Run with Debug Output

```bash
# Enable verbose MPI output
export I_MPI_DEBUG=5
mpirun -np 1 mpas_atmosphere --help 2>&1 | head -50
```

### 8. Check for Core Dump

```bash
# Enable core dumps
ulimit -c unlimited
mpirun -np 1 mpas_atmosphere --help
# Check for core file
ls -la core.*
```

## Complete Fix Script

Run this on the cluster:

```bash
#!/bin/bash
# Fix MPAS runtime environment

# Load Intel MPI
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Load MPAS
module load chpc/earth/mpas-lengau

# Add all necessary paths
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH

# Verify
echo "Library path:"
echo $LD_LIBRARY_PATH | tr ':' '\n' | grep MPAS

# Test
mpirun -np 1 mpas_atmosphere --help
```

## If All Else Fails

1. **Reinstall MPAS** - The installation script has been updated to properly handle lib64
2. **Use build directory directly** - Run from build_cmake/bin/ with proper LD_LIBRARY_PATH
3. **Check MPAS logs** - Look for any error messages before the abort
4. **Contact support** - This might be a cluster-specific issue

## Related Documentation

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting
- [USAGE.md](USAGE.md) - Usage guide
- [FIX_MODULE.md](../FIX_MODULE.md) - Module file fixes

