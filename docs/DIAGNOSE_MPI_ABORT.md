# Diagnosing MPI_Abort Error 1734831948

## Error

```
mpirun -np 1 mpas_atmosphere --help
application called MPI_Abort(MPI_COMM_WORLD, 1734831948) - process 0
```

## Step-by-Step Diagnosis

### Step 1: Check Library Dependencies

```bash
# Check for missing libraries
ldd /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | grep "not found"

# Check main library
ldd /home/apps/chpc/earth/MPAS-8.3.1/lib64/libmpas_atmosphere.so | grep "not found"
```

### Step 2: Verify Library Path

```bash
# Check if lib64 is in LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH | grep -E "MPAS|lib64"

# Should show:
# /home/apps/chpc/earth/MPAS-8.3.1/lib64
```

### Step 3: Check Module File

```bash
# Verify module is loaded
module list | grep mpas

# Check module file content
cat /apps/chpc/scripts/modules/earth/mpas-lengau

# Should include:
# prepend-path LD_LIBRARY_PATH ${mpas_root}/lib64
# prepend-path LD_LIBRARY_PATH ${mpas_root}/lib
```

### Step 4: Manual Library Path Setup

```bash
# Unload and reload modules
module purge
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Manually add all required paths
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH

# Verify paths
echo "MPAS lib64: $(ls -d /home/apps/chpc/earth/MPAS-8.3.1/lib64 2>/dev/null || echo 'NOT FOUND')"
echo "MPAS lib: $(ls -d /home/apps/chpc/earth/MPAS-8.3.1/lib 2>/dev/null || echo 'NOT FOUND')"
```

### Step 5: Test Library Loading

```bash
# Try loading the main library directly
ldd /home/apps/chpc/earth/MPAS-8.3.1/lib64/libmpas_atmosphere.so | head -20

# Check if Intel runtime libraries are accessible
ls -la /apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64/libimf.so
ls -la /apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64/libintlc.so.5
```

### Step 6: Run with Strace (if available)

```bash
# Check what files MPAS is trying to access
strace -e trace=open,openat mpirun -np 1 mpas_atmosphere --help 2>&1 | grep -E "ENOENT|Error|failed" | head -20
```

### Step 7: Check MPAS Executable

```bash
# Verify executable is correct
file /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere

# Check if it's a wrapper or actual binary
head -5 /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere

# Should show ELF header, not shell script
```

### Step 8: Try Running from Build Directory

```bash
# Run directly from build directory
cd /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Model/build_cmake

# Set library path explicitly
export LD_LIBRARY_PATH=./lib:/home/apps/chpc/earth/MPAS-8.3.1/lib64:/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH

# Try running
mpirun -np 1 ./bin/mpas_atmosphere --help
```

## Common Fixes

### Fix 1: Update Module File

```bash
# Edit module file
nano /apps/chpc/scripts/modules/earth/mpas-lengau

# Ensure it has:
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib64
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib
```

### Fix 2: Check Library Installation

```bash
# Verify libraries exist
ls -la /home/apps/chpc/earth/MPAS-8.3.1/lib64/*.so
ls -la /home/apps/chpc/earth/MPAS-8.3.1/lib/*.so 2>/dev/null

# Should show:
# libmpas_atmosphere.so
# libmpas_framework.so
# libmpas_operators.so
# libesmf.so
# etc.
```

### Fix 3: Reinstall if Libraries Missing

If libraries are missing, the installation may have been incomplete:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
./install_mpas_lengau.sh
```

## Error Code 1734831948

This specific error code suggests MPAS is failing during initialization, likely due to:
1. Missing shared libraries
2. Incorrect library paths
3. Missing required data files
4. Configuration issues

## Complete Diagnostic Script

Run this to gather all diagnostic information:

```bash
#!/bin/bash
echo "=== MPAS Diagnostic Information ==="
echo ""

echo "1. Executable location:"
which mpas_atmosphere
echo ""

echo "2. Library path:"
echo $LD_LIBRARY_PATH | tr ':' '\n' | grep -E "MPAS|lib64"
echo ""

echo "3. Missing libraries:"
ldd $(which mpas_atmosphere) 2>&1 | grep "not found"
echo ""

echo "4. MPAS libraries:"
ls -la /home/apps/chpc/earth/MPAS-8.3.1/lib64/*.so 2>/dev/null | head -10
echo ""

echo "5. Module file:"
cat /apps/chpc/scripts/modules/earth/mpas-lengau 2>/dev/null | grep -E "LD_LIBRARY_PATH|PATH"
echo ""

echo "6. Intel runtime libraries:"
ls -la /apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64/libimf.so 2>/dev/null
echo ""

echo "7. Test library loading:"
ldd /home/apps/chpc/earth/MPAS-8.3.1/lib64/libmpas_atmosphere.so 2>&1 | head -5
```

Save this as `diagnose_mpas.sh` and run it to gather diagnostic information.

