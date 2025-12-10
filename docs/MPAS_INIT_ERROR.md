# MPAS Initialization Error (Error Code 0)

## Error

```
mpirun -np 1 mpas_atmosphere --help
application called MPI_Abort(MPI_COMM_WORLD, 0) - process 0
```

## Diagnosis

- ✅ MPI initializes correctly
- ✅ No missing libraries (ldd shows all libraries found)
- ✅ Intel runtime libraries accessible
- ❌ MPAS aborts during its own initialization (`__mpas_subdriver_MOD_mpas_init`)

## Possible Causes

### 1. MPAS Requires Input Files Even for --help

Some versions of MPAS require namelist/streams files even for help. Try:

```bash
# Create minimal namelist
cat > test_namelist.atmosphere << EOF
&nhyd_model
 config_dt = 300.0
/
EOF

# Create minimal streams
cat > test_streams.atmosphere << EOF
<streams>
</streams>
EOF

# Try running
mpirun -np 1 mpas_atmosphere -n test_namelist.atmosphere -s test_streams.atmosphere
```

### 2. Environment Variable Issues

MPAS might check for specific environment variables. Try:

```bash
# Set common MPAS environment variables
export MPAS_ROOT=/home/apps/chpc/earth
export MPAS_CORE=atmosphere

# Try again
mpirun -np 1 mpas_atmosphere --help
```

### 3. Library Loading Order

Try setting library path explicitly:

```bash
export LD_LIBRARY_PATH=/home/apps/chpc/earth/lib64:/home/apps/chpc/earth/build/MPAS-Model/build_cmake/lib:/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH

mpirun -np 1 mpas_atmosphere --help
```

### 4. Run from Build Directory

The installed executable might have issues. Try running directly from build:

```bash
cd /home/apps/chpc/earth/build/MPAS-Model/build_cmake
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
mpirun -np 1 ./bin/mpas_atmosphere --help
```

### 5. Check MPAS Version/Configuration

The executable might be configured to require certain files. Check:

```bash
# Check what MPAS expects
strings /home/apps/chpc/earth/bin/mpas_atmosphere | grep -i 'namelist\|streams\|required\|error' | head -20
```

### 6. Try with Minimal Namelist

MPAS might require at least a minimal configuration:

```bash
# Create absolute minimal namelist
echo "&nhyd_model" > minimal_namelist.atmosphere
echo " config_dt = 300.0" >> minimal_namelist.atmosphere
echo "/" >> minimal_namelist.atmosphere

# Create minimal streams
echo "<streams>" > minimal_streams.atmosphere
echo "</streams>" >> minimal_streams.atmosphere

# Try running
mpirun -np 1 mpas_atmosphere -n minimal_namelist.atmosphere -s minimal_streams.atmosphere
```

## Workaround: Use Build Directory

If the installed version has issues, you can use the build directory directly:

```bash
# Create alias or script
cat > ~/run_mpas.sh << 'EOF'
#!/bin/bash
cd /home/apps/chpc/earth/build/MPAS-Model/build_cmake
export LD_LIBRARY_PATH=./lib:/home/apps/chpc/earth/lib64:/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/lib/intel64:$LD_LIBRARY_PATH
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
mpirun -np $1 ./bin/mpas_atmosphere "${@:2}"
EOF

chmod +x ~/run_mpas.sh

# Use it
~/run_mpas.sh 1 --help
~/run_mpas.sh 4 -n namelist.atmosphere -s streams.atmosphere
```

## Next Steps

1. **Try with minimal namelist/streams files** (most likely solution)
2. **Check MPAS documentation** for version-specific requirements
3. **Use build directory** as workaround
4. **Check MPAS source code** for initialization requirements

## Related Issues

- This might be expected behavior if MPAS v8.3.1 requires configuration files
- Some scientific models don't support --help and require input files
- The installation is successful - this is a runtime/usage issue

## Verification

The build completed successfully, so the issue is likely:
- MPAS requires input files even for help
- Version-specific behavior
- Configuration requirement

Try running with actual namelist/streams files to confirm MPAS works.

