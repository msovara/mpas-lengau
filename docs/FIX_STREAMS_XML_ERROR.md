# Fixing "stream xml get attribute failed" Error

## Error

```
CRITICAL ERROR: stream xml get attribute failed: streams.atmosphere
```

## Cause

The streams file is too minimal or has invalid XML structure. MPAS requires at least basic stream definitions, even for minimal test runs.

## Solution

Create a proper minimal streams file:

```bash
cat > streams.atmosphere << 'EOF'
<streams>
  <immutable_stream name="initial_conditions"
                    type="input"
                    filename_template="init.nc"
                    input_interval="initial_only"/>
  <immutable_stream name="grid_data"
                    type="input"
                    filename_template="x1.10242.grid.nc"
                    input_interval="initial_only"/>
  <immutable_stream name="static_data"
                    type="input"
                    filename_template="x1.10242.static.nc"
                    input_interval="initial_only"/>
</streams>
EOF
```

## For Testing Without Input Files

If you just want to test the executable (without actual input files), you can use a minimal but valid streams file:

```bash
cat > streams.atmosphere << 'EOF'
<streams>
  <stream name="test"
          type="output"
          filename_template="test.nc"
          output_interval="initial_only">
    <var name="xtime"/>
  </stream>
</streams>
EOF
```

## Complete Minimal Test Setup

```bash
# Create test directory
mkdir -p ~/mpas_test
cd ~/mpas_test

# Create minimal namelist
cat > namelist.atmosphere << 'EOF'
&nhyd_model
    config_dt = 300.0
    config_start_time = '2025-01-01_00:00:00'
    config_run_duration = '0000-00-00_00:00:00'
/
EOF

# Create proper minimal streams file
cat > streams.atmosphere << 'EOF'
<streams>
  <stream name="test"
          type="output"
          filename_template="test.nc"
          output_interval="initial_only">
    <var name="xtime"/>
  </stream>
</streams>
EOF

# Load modules
module purge
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Try running
mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere --help
```

## Note

Even with a valid streams file, MPAS may still require input files (init.nc, grid files, etc.) to run a full simulation. The `--help` flag should work with a valid streams file, but actual runs will need proper input data.

