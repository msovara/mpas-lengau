# Fixing MPI_Abort Error 1734831948

## Diagnostic Results

✅ **Libraries**: All present and accessible  
✅ **Library Path**: Both `lib64` and `lib` are in `LD_LIBRARY_PATH`  
✅ **Module File**: Correctly configured  
❌ **Runtime**: Still aborting with error code 1734831948

## Error Code Analysis

Error code `1734831948` (0x67726974 in hex) suggests MPAS is failing during early initialization, possibly:
- Missing required data files
- Configuration file issues
- Runtime environment problems
- MPI initialization failure

## Solution Steps

### Step 1: Check MPAS Executable Integrity

```bash
# Verify executable is valid
file /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere

# Check if it's actually a binary (not a script)
head -1 /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | od -c | head -5

# Should show ELF header, not shell script
```

### Step 2: Try Running with Verbose MPI Output

```bash
# Enable MPI debug output
export I_MPI_DEBUG=5
mpirun -np 1 mpas_atmosphere --help 2>&1 | head -50

# Or try with different MPI settings
export I_MPI_FABRICS=shm
mpirun -np 1 mpas_atmosphere --help
```

### Step 3: Check if MPAS Requires Input Files Even for --help

Some MPAS versions require namelist/streams files even for `--help`. Try creating minimal files:

```bash
# Create minimal namelist
cat > /tmp/test_namelist.atmosphere << 'EOF'
&nhyd_model
    config_dt = 300.0
/
EOF

# Create minimal streams
cat > /tmp/test_streams.atmosphere << 'EOF'
<streams>
</streams>
EOF

# Try running with these files
cd /tmp
mpirun -np 1 /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere -n test_namelist.atmosphere -s test_streams.atmosphere --help
```

### Step 4: Check for Required Data Files

MPAS might be looking for data files during initialization:

```bash
# Check if MPAS is looking for specific files
strace -e trace=open,openat,stat mpirun -np 1 mpas_atmosphere --help 2>&1 | grep -E "ENOENT|Error|failed" | head -20

# Or use ldd to see all dependencies
ldd /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | wc -l
```

### Step 5: Try Running from Build Directory

Sometimes running from the build directory works better:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Model/build_cmake

# Set library path explicitly
export LD_LIBRARY_PATH=./lib:./lib64:/home/apps/chpc/earth/MPAS-8.3.1/lib64:/home/apps/chpc/earth/MPAS-8.3.1/lib:/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH

# Try running
mpirun -np 1 ./bin/mpas_atmosphere --help
```

### Step 6: Check MPAS Version/Configuration

```bash
# Try to get version info (if available)
strings /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | grep -i "version\|mpas\|8.3" | head -10

# Check build configuration
strings /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere | grep -i "build\|compile\|gcc\|intel" | head -10
```

### Step 7: Check MPI Environment

```bash
# Verify MPI is working
mpirun -np 1 hostname
mpirun -np 1 echo "MPI works"

# Check MPI version
mpirun --version

# Try with mpiexec instead
mpiexec -n 1 /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere --help
```

### Step 8: Check for Core Dump or Log Files

```bash
# Check for core dumps
ls -la core* 2>/dev/null

# Check for MPAS log files
ls -la log.* 2>/dev/null

# Check system logs (if accessible)
dmesg | tail -20
```

### Step 9: Try Different MPI Settings

```bash
# Try with different MPI fabric
export I_MPI_FABRICS=shm:tcp
mpirun -np 1 mpas_atmosphere --help

# Or disable some MPI features
export I_MPI_PIN=0
export I_MPI_DEBUG=0
mpirun -np 1 mpas_atmosphere --help
```

### Step 10: Check Installation Log

```bash
# Review installation log for any warnings
grep -i "error\|warning\|fail" /home/apps/chpc/earth/MPAS-8.3.1/install_log.txt 2>/dev/null | tail -20
```

## Alternative: Rebuild MPAS

If all else fails, the build might have an issue. Try rebuilding:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
# Backup current build
mv build/MPAS-Model/build_cmake build/MPAS-Model/build_cmake.backup

# Rebuild
./install_mpas_lengau.sh
```

## Most Likely Solution

Based on the error code and symptoms, try this first:

```bash
# 1. Create minimal configuration files
mkdir -p ~/mpas_test
cd ~/mpas_test

cat > namelist.atmosphere << 'EOF'
&nhyd_model
    config_dt = 300.0
    config_start_time = '2025-01-01_00:00:00'
    config_run_duration = '0000-00-00_00:00:00'
/
EOF

cat > streams.atmosphere << 'EOF'
<streams>
</streams>
EOF

# 2. Try running with these files
module purge
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere --help
```

## Contact Information

If none of these solutions work, please provide:
1. Full output of `ldd /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere`
2. Output of `strace` command (if available)
3. Any error messages before the MPI_Abort
4. Installation log file

