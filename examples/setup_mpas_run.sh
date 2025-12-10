#!/bin/bash
# Setup script for MPAS simulation directory
# Creates directory structure and copies template files

set -e

# Configuration
SIM_DIR="${1:-$HOME/mpas_simulation}"
GRID_RESOLUTION="${2:-x1.10242}"

echo "=== MPAS Simulation Setup ==="
echo "Simulation directory: ${SIM_DIR}"
echo "Grid resolution: ${GRID_RESOLUTION}"
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p ${SIM_DIR}/{input,output/{history,restart,diagnostics},logs}

# Check if MPAS is loaded
if ! command -v mpas_atmosphere &> /dev/null; then
    echo "Loading MPAS module..."
    module load chpc/earth/mpas-lengau 2>/dev/null || {
        echo "⚠ Warning: Could not load MPAS module"
        echo "Please load it manually: module load chpc/earth/mpas-lengau"
    }
fi

# Get MPAS_ROOT
if [ -z "$MPAS_ROOT" ]; then
    MPAS_ROOT="/home/apps/chpc/earth/MPAS-8.3.1"
fi

# Copy template files
echo "Copying template files..."
cd ${SIM_DIR}

# Copy namelist template
if [ -f "${MPAS_ROOT}/share/MPAS/core_atmosphere/namelist.atmosphere" ]; then
    cp ${MPAS_ROOT}/share/MPAS/core_atmosphere/namelist.atmosphere namelist.atmosphere
    echo "✓ Copied namelist.atmosphere"
else
    echo "⚠ namelist.atmosphere not found, creating from template"
    # Create minimal namelist
    cat > namelist.atmosphere << 'EOF'
&nhyd_model
    config_dt = 300.0
    config_start_time = '2025-01-01_00:00:00'
    config_run_duration = '0000-00-01_00:00:00'
/
&physics
    config_physics_suite = 'mesoscale_reference'
/
EOF
fi

# Copy streams template
if [ -f "${MPAS_ROOT}/share/MPAS/core_atmosphere/streams.atmosphere" ]; then
    cp ${MPAS_ROOT}/share/MPAS/core_atmosphere/streams.atmosphere streams.atmosphere
    echo "✓ Copied streams.atmosphere"
else
    echo "⚠ streams.atmosphere not found, creating from template"
    # Create minimal streams
    cat > streams.atmosphere << 'EOF'
<streams>
    <immutable_stream name="input"
                      type="input"
                      filename_template="input/init.nc"
                      input_interval="initial_only"/>
    <stream name="history"
            type="output"
            filename_template="output/history/history.$Y-$M-$D_$h.$m.$s.nc"
            output_interval="00:06:00"/>
</streams>
EOF
fi

# Create PBS script
cat > run_mpas.pbs << 'EOFPBS'
#!/bin/bash
#PBS -N mpas_simulation
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -o logs/mpas.out
#PBS -e logs/mpas.err

module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

cd $PBS_O_WORKDIR
mkdir -p output/{history,restart,diagnostics}

mpirun -np 48 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
EOFPBS
chmod +x run_mpas.pbs
echo "✓ Created run_mpas.pbs"

# Instructions
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit namelist.atmosphere for your simulation"
echo "2. Edit streams.atmosphere for output configuration"
echo "3. Place input files in input/ directory:"
echo "   - init.nc (initial conditions)"
echo "   - ${GRID_RESOLUTION}.grid.nc (grid file)"
echo "   - ${GRID_RESOLUTION}.static.nc (static fields)"
echo "4. Submit job: qsub run_mpas.pbs"
echo ""
echo "Directory structure:"
echo "${SIM_DIR}/"
echo "├── namelist.atmosphere"
echo "├── streams.atmosphere"
echo "├── run_mpas.pbs"
echo "├── input/"
echo "├── output/"
echo "└── logs/"
echo ""

