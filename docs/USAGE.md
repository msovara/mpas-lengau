# MPAS Usage Guide

This guide explains how to use MPAS after installation on Lengau cluster.

## Table of Contents

- [Loading MPAS Environment](#loading-mpas-environment)
  - [Option 1: Module System](#option-1-module-system)
  - [Option 2: Setup Script](#option-2-setup-script)
  - [Verify Installation](#verify-installation)
- [Running MPAS](#running-mpas)
  - [Important: MPAS Requires MPI](#important-mpas-requires-mpi)
  - [Getting Help](#getting-help)
  - [Running MPAS Simulations](#running-mpas-simulations)
- [Common Issues](#common-issues)
  - [Issue: MPI_Abort Error](#issue-mpi_abort-error)
  - [Issue: Executable Not Found](#issue-executable-not-found)
  - [Issue: Library Not Found](#issue-library-not-found)
  - [Issue: MPI Not Found](#issue-mpi-not-found)
- [Example Workflows](#example-workflows)
  - [Workflow 1: Quick Test](#workflow-1-quick-test)
  - [Workflow 2: Production Run](#workflow-2-production-run)
  - [Workflow 3: Debugging](#workflow-3-debugging)
- [MPAS Command Line Options](#mpas-command-line-options)
- [Environment Variables](#environment-variables)
- [Best Practices](#best-practices)
- [Getting Help](#getting-help)

## Loading MPAS Environment

### Option 1: Module System

```bash
module load chpc/earth/mpas-lengau
```

### Option 2: Setup Script

```bash
source /home/apps/chpc/earth/MPAS-8.3.1/setup_mpas_lengau.sh
```

### Verify Installation

```bash
# Check executable location
which mpas_atmosphere

# Should output:
# /home/apps/chpc/earth/MPAS-8.3.1/bin/mpas_atmosphere
```

## Running MPAS

### Important: MPAS Requires MPI

**MPAS is an MPI application** and must be run with `mpirun` or `mpiexec`, even for help commands.

### Getting Help

```bash
# ❌ This will fail with MPI_Abort error:
mpas_atmosphere --help

# ✅ Correct way:
mpirun -np 1 mpas_atmosphere --help

# Or:
mpiexec -n 1 mpas_atmosphere --help
```

### Running MPAS Simulations

#### Basic Run

```bash
# Single process (for testing)
mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere

# Multiple processes (recommended)
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

#### PBS Job Script Example

Create a file `run_mpas.pbs`:

```bash
#!/bin/bash
#PBS -N mpas_run
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=02:00:00
#PBS -q normal
#PBS -o mpas.out
#PBS -e mpas.err

# Load modules
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Set working directory
cd $PBS_O_WORKDIR

# Run MPAS
mpirun -np 24 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

Submit job:
```bash
qsub run_mpas.pbs
```

#### Interactive Run

```bash
# Request interactive node
qsub -I -l select=1:ncpus=4:mpiprocs=4 -l walltime=01:00:00 -q normal

# Once on compute node, load environment and run
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

## Common Issues

### Issue: MPI_Abort Error

**Error:**
```
application called MPI_Abort(MPI_COMM_WORLD, 0) - process 0
```

**Causes and Solutions:**

#### Cause 1: Missing Namelist/Streams Files

**Error:**
```
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
application called MPI_Abort(MPI_COMM_WORLD, 0) - process 0
```

**Solution:**
1. Check if files exist:
   ```bash
   ls -la namelist.atmosphere streams.atmosphere
   ```

2. Find example files:
   ```bash
   find /home/apps/chpc/earth/MPAS-8.3.1 -name "namelist.atmosphere" -o -name "streams.atmosphere"
   ```

3. Copy example files from MPAS installation:
   ```bash
   # Example files are usually in:
   cp /home/apps/chpc/earth/MPAS-8.3.1/share/MPAS/core_atmosphere/namelist.atmosphere .
   cp /home/apps/chpc/earth/MPAS-8.3.1/share/MPAS/core_atmosphere/streams.atmosphere .
   ```

4. Or download from MPAS repository:
   ```bash
   # On DTN node
   wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/develop/src/core_atmosphere/namelist.atmosphere
   wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/develop/src/core_atmosphere/streams.atmosphere
   ```

#### Cause 2: Incorrect File Paths

**Solution:**
```bash
# Use absolute paths or ensure files are in current directory
mpirun -np 1 mpas_atmosphere -n /full/path/to/namelist.atmosphere -s /full/path/to/streams.atmosphere
```

#### Cause 3: Missing Input Data

**Solution:**
- Ensure input data files specified in namelist/streams exist
- Check file paths in namelist.atmosphere
- Verify data files are accessible

#### Cause 4: MPI Environment Issues

**Solution:**
```bash
# Load Intel MPI first
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Then load MPAS
module load chpc/earth/mpas-lengau

# Test MPI
mpirun -np 1 hostname

# Test MPAS help
mpirun -np 1 mpas_atmosphere --help
```

#### Cause 5: Library Path Issues

**Solution:**
```bash
# Check library path
echo $LD_LIBRARY_PATH | grep MPAS

# If missing, add manually
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH
```

#### Debugging Steps

1. **Test with help first:**
   ```bash
   mpirun -np 1 mpas_atmosphere --help
   ```
   If this works, the issue is with namelist/streams files.

2. **Check file permissions:**
   ```bash
   ls -la namelist.atmosphere streams.atmosphere
   chmod 644 namelist.atmosphere streams.atmosphere
   ```

3. **Run with verbose output:**
   ```bash
   mpirun -np 1 -verbose mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
   ```

4. **Check for error messages:**
   - Look for specific error messages before MPI_Abort
   - Check stderr output
   - Review MPAS log files if created

### Issue: Executable Not Found

**Error:**
```
mpas_atmosphere: command not found
```

**Solution:**
1. Load MPAS module:
   ```bash
   module load chpc/earth/mpas-lengau
   ```

2. Or source setup script:
   ```bash
   source /home/apps/chpc/earth/MPAS-8.3.1/setup_mpas_lengau.sh
   ```

3. Verify:
   ```bash
   which mpas_atmosphere
   ```

### Issue: Library Not Found

**Error:**
```
error while loading shared libraries: libmpas_framework.so: cannot open shared object file
```

**Solution:**
1. Ensure MPAS module is loaded
2. Check LD_LIBRARY_PATH:
   ```bash
   echo $LD_LIBRARY_PATH | grep MPAS
   ```

3. Manually add if needed:
   ```bash
   export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH
   ```

### Issue: MPI Not Found

**Error:**
```
mpirun: command not found
```

**Solution:**
```bash
# Load Intel MPI
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Verify
which mpirun
```

## Example Workflows

### Workflow 1: Quick Test

```bash
# Load environment
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Test executable
mpirun -np 1 mpas_atmosphere --help

# Run with test configuration
mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

### Workflow 2: Production Run

```bash
# Create PBS script (see example above)
# Submit job
qsub run_mpas.pbs

# Monitor job
qstat -u msovara

# Check output
tail -f mpas.out
```

### Workflow 3: Debugging

```bash
# Request interactive node
qsub -I -l select=1:ncpus=4:mpiprocs=4 -l walltime=01:00:00

# Load environment
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Run with verbose output
mpirun -np 4 -verbose mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

## MPAS Command Line Options

```bash
mpirun -np 1 mpas_atmosphere --help
```

Common options:
- `-n <file>`: Namelist file (required)
- `-s <file>`: Streams file (required)
- `--help`: Show help message
- `--version`: Show version (if available)

## Environment Variables

After loading MPAS module:

- `MPAS_ROOT`: Installation root directory
- `PATH`: Includes `$MPAS_ROOT/bin`
- `LD_LIBRARY_PATH`: Includes MPAS libraries
- `NETCDF`: NetCDF root directory
- `HDF5_ROOT`: HDF5 root directory

## Best Practices

1. **Always use mpirun/mpiexec**: Even for help/version commands
2. **Load modules in order**: Intel MPI first, then MPAS
3. **Use PBS for production runs**: Better resource management
4. **Check output files**: Monitor `.out` and `.err` files
5. **Test with single process first**: Before running large jobs

## Getting Help

- Check installation log: `/home/apps/chpc/earth/MPAS-8.3.1/install_log.txt`
- See troubleshooting guide: `docs/TROUBLESHOOTING.md`
- MPAS documentation: https://mpas-dev.github.io/
- CHPC support: For cluster-specific issues

---

**Last Updated**: December 2025

