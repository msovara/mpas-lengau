# Quick Start: Running Your First MPAS Simulation

This guide helps you run your first MPAS simulation after installation.

## Prerequisites

- MPAS installed (see main README.md)
- Namelist and streams files
- Input data files (if required)

## Step 1: Get Example Configuration Files

### Option A: Copy from Installation

```bash
# Load MPAS module
module load chpc/earth/mpas-lengau

# Find example files
find $MPAS_ROOT -name "namelist.atmosphere" -o -name "streams.atmosphere"

# Copy to your working directory
cp $MPAS_ROOT/share/MPAS/core_atmosphere/namelist.atmosphere .
cp $MPAS_ROOT/share/MPAS/core_atmosphere/streams.atmosphere .
```

### Option B: Download from MPAS Repository

**On DTN node (has internet):**
```bash
cd /mnt/lustre/users/msovara/SoftwareBuilds
mkdir -p mpas_run
cd mpas_run

# Download example files
wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/develop/src/core_atmosphere/namelist.atmosphere
wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/develop/src/core_atmosphere/streams.atmosphere
```

### Option C: Use MPAS Test Cases

MPAS provides test cases with complete configurations. Check:
- MPAS documentation: https://mpas-dev.github.io/
- MPAS test cases repository

## Step 2: Verify Files

```bash
# Check files exist
ls -la namelist.atmosphere streams.atmosphere

# Verify they're readable
head -20 namelist.atmosphere
head -20 streams.atmosphere
```

## Step 3: Load Environment

```bash
# Load Intel MPI
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Load MPAS
module load chpc/earth/mpas-lengau

# Verify
which mpas_atmosphere
mpirun -np 1 mpas_atmosphere --help
```

## Step 4: Test Run

### Test with Help (No Files Needed)

```bash
mpirun -np 1 mpas_atmosphere --help
```

This should work without errors. If it fails, see troubleshooting below.

### Test with Configuration Files

```bash
# Single process test
mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere

# If successful, run with multiple processes
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

## Step 5: Submit as PBS Job

Create `run_mpas.pbs`:

```bash
#!/bin/bash
#PBS -N mpas_test
#PBS -l select=1:ncpus=4:mpiprocs=4
#PBS -l walltime=01:00:00
#PBS -q normal
#PBS -o mpas.out
#PBS -e mpas.err

# Load modules
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Set working directory (where namelist/streams are)
cd $PBS_O_WORKDIR

# Run MPAS
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

Submit:
```bash
qsub run_mpas.pbs
```

Monitor:
```bash
qstat -u msovara
tail -f mpas.out
```

## Troubleshooting

### Error: MPI_Abort

**If `--help` works but run fails:**

1. **Check namelist/streams files exist:**
   ```bash
   ls -la namelist.atmosphere streams.atmosphere
   ```

2. **Check file paths in namelist:**
   ```bash
   grep -i "filename\|path" namelist.atmosphere
   ```

3. **Verify input data files exist:**
   - Check paths in namelist.atmosphere
   - Ensure data files are accessible
   - Check file permissions

4. **Run with single process for better error messages:**
   ```bash
   mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere 2>&1 | tee mpas_error.log
   ```

### Error: File Not Found

**If namelist/streams not found:**

1. Use absolute paths:
   ```bash
   mpirun -np 1 mpas_atmosphere -n /full/path/to/namelist.atmosphere -s /full/path/to/streams.atmosphere
   ```

2. Check current directory:
   ```bash
   pwd
   ls -la *.atmosphere
   ```

### Error: Library Not Found

```bash
# Check library path
echo $LD_LIBRARY_PATH

# Add if missing
export LD_LIBRARY_PATH=/home/apps/chpc/earth/lib64:$LD_LIBRARY_PATH
```

## Next Steps

Once your test run works:

1. **Configure for your simulation:**
   - Edit `namelist.atmosphere` for your domain/resolution
   - Edit `streams.atmosphere` for output configuration
   - Prepare input data files

2. **Run production simulation:**
   - Use appropriate number of processes
   - Submit as PBS job
   - Monitor output

3. **Process results:**
   - Check output files
   - Use visualization tools
   - Analyze results

## Resources

- **MPAS Documentation**: https://mpas-dev.github.io/
- **MPAS Repository**: https://github.com/MPAS-Dev/MPAS-Model
- **Usage Guide**: See `docs/USAGE.md`
- **Troubleshooting**: See `docs/TROUBLESHOOTING.md`

---

**Note**: This is a quick start guide. For detailed configuration, see MPAS official documentation.

