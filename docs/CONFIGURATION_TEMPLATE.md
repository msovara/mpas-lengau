# MPAS Configuration Template

This guide provides a comprehensive configuration template for running MPAS-Atmosphere simulations on the Lengau cluster.

## Table of Contents

- [Quick Setup](#quick-setup)
- [Directory Structure](#directory-structure)
- [Configuration Files](#configuration-files)
  - [Namelist.atmosphere Template](#namelistatmosphere-template)
  - [Streams.atmosphere Template](#streamsatmosphere-template)
- [Input Data](#input-data)
  - [Required Input Files](#required-input-files)
  - [Getting Input Data](#getting-input-data)
- [Example Templates](#example-templates)
  - [Complete Example: Basic Simulation](#complete-example-basic-simulation)
- [Running Simulations](#running-simulations)
  - [PBS Job Script Template](#pbs-job-script-template)
  - [Interactive Run](#interactive-run)
- [Resources](#resources)
  - [Official MPAS Resources](#official-mpas-resources)
  - [Example Configurations](#example-configurations)
  - [Getting Help](#getting-help)
- [Next Steps](#next-steps)

## Quick Setup

### Step 1: Get Example Configuration Files

```bash
# Load MPAS module
module load chpc/earth/mpas-lengau

# Create working directory
mkdir -p ~/mpas_simulation
cd ~/mpas_simulation

# Copy example files from installation
cp $MPAS_ROOT/share/MPAS/core_atmosphere/namelist.atmosphere .
cp $MPAS_ROOT/share/MPAS/core_atmosphere/streams.atmosphere .
```

### Step 2: Download from MPAS Repository (Alternative)

**On DTN node:**
```bash
cd ~/mpas_simulation

# Download latest example files
wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/v8.3.1/src/core_atmosphere/namelist.atmosphere
wget https://raw.githubusercontent.com/MPAS-Dev/MPAS-Model/v8.3.1/src/core_atmosphere/streams.atmosphere
```

## Directory Structure

Recommended directory structure for MPAS simulations:

```
~/mpas_simulation/
├── namelist.atmosphere          # Main configuration file
├── streams.atmosphere           # I/O streams configuration
├── run_mpas.pbs                # PBS job script
├── input/                       # Input data directory
│   ├── init.nc                 # Initial conditions
│   ├── x1.10242.grid.nc        # Grid file
│   └── x1.10242.static.nc      # Static fields
├── output/                      # Output directory
│   ├── history/                 # History files
│   └── restart/                # Restart files
└── logs/                        # Log files
```

## Configuration Files

### Namelist.atmosphere Template

Create `namelist.atmosphere` with the following structure:

```fortran
&nhyd_model
    config_time_integration = 'split_explicit'
    config_dt = 300.0
    config_start_time = '2025-01-01_00:00:00'
    config_run_duration = '0000-00-01_00:00:00'
    config_split_dynamics_transport = .true.
    config_split_dynamics_transport_subcycle = 3
/

&data_sources
    config_geog_data_path = '/path/to/geog/data/'
    config_landuse_data = 'MODIFIED_IGBP_MODIS_NOAH'
    config_topo_data = 'GMTED2010'
    config_vegfrac_data = 'MODIS'
    config_albedo_data = 'MODIS'
    config_maxsnowalbedo_data = 'MODIS'
    config_supersample_factor = 3
/

&preproc_stages
    config_static_interp = .true.
    config_native_gwd_static = .true.
    config_vertical_grid = .false.
    config_met_interp = .false.
    config_input_sst = .false.
    config_frac_seaice = .false.
/

&io
    config_pio_num_iotasks = 0
    config_pio_stride = 1
/

&decomposition
    config_block_decomp_file_prefix = 'x1.10242.graph.info.part.'
/

&restart
    config_do_restart = .false.
    config_start_time = '2025-01-01_00:00:00'
/

&physics
    config_physics_suite = 'mesoscale_reference'
    config_microp_scheme = 'mp_thompson'
    config_convection_scheme = 'cu_tiedtke'
    config_lsm_scheme = 'noah'
    config_pbl_scheme = 'bl_ysu'
    config_radt_cld_lw = 30
    config_radt_cld_sw = 30
/

&diagnostics
    config_AM_globalStats_enable = .true.
    config_AM_globalStats_compute_interval = '00:10:00'
/
```

### Streams.atmosphere Template

Create `streams.atmosphere` with the following structure:

```xml
<streams>
    <!-- Input stream for initial conditions -->
    <immutable_stream name="input"
                      type="input"
                      filename_template="input/init.nc"
                      input_interval="initial_only"/>

    <!-- Input stream for grid -->
    <immutable_stream name="grid"
                      type="input"
                      filename_template="input/x1.10242.grid.nc"
                      input_interval="initial_only"/>

    <!-- Input stream for static fields -->
    <immutable_stream name="static"
                      type="input"
                      filename_template="input/x1.10242.static.nc"
                      input_interval="initial_only"/>

    <!-- Output stream for history -->
    <stream name="history"
            type="output"
            filename_template="output/history/history.$Y-$M-$D_$h.$m.$s.nc"
            filename_interval="none"
            output_interval="00:06:00"
            clobber_mode="overwrite">
        <var name="xtime"/>
        <var name="pressure"/>
        <var name="temperature"/>
        <var name="uReconstructZonal"/>
        <var name="uReconstructMeridional"/>
        <var name="w"/>
        <var name="qv"/>
        <var name="qc"/>
        <var name="qr"/>
        <var name="qi"/>
        <var name="qs"/>
        <var name="qg"/>
    </stream>

    <!-- Output stream for restart -->
    <stream name="restart"
            type="output"
            filename_template="output/restart/restart.$Y-$M-$D_$h.$m.$s.nc"
            filename_interval="none"
            output_interval="00:06:00"
            clobber_mode="overwrite">
        <var name="xtime"/>
        <var name="pressure"/>
        <var name="temperature"/>
        <var name="uReconstructZonal"/>
        <var name="uReconstructMeridional"/>
        <var name="w"/>
        <var name="qv"/>
        <var name="qc"/>
        <var name="qr"/>
        <var name="qi"/>
        <var name="qs"/>
        <var name="qg"/>
    </stream>

    <!-- Output stream for diagnostics -->
    <stream name="diagnostics"
            type="output"
            filename_template="output/diagnostics/diag.$Y-$M-$D_$h.$m.$s.nc"
            filename_interval="none"
            output_interval="00:01:00"
            clobber_mode="overwrite">
        <var name="xtime"/>
        <var name="precipitationRate"/>
        <var name="surfacePrecipitationRate"/>
        <var name="accumulatedPrecipitation"/>
    </stream>
</streams>
```

## Input Data

### Required Input Files

1. **Grid File** (`x1.10242.grid.nc` or similar)
   - Defines the MPAS mesh/grid
   - Available from MPAS-Data repository

2. **Initial Conditions** (`init.nc`)
   - Atmospheric initial conditions
   - Can be generated using `init_atmosphere_model` or from reanalysis

3. **Static Fields** (`x1.10242.static.nc`)
   - Topography, land use, etc.
   - Generated from geographical data

### Getting Input Data

**Option 1: Use MPAS-Data Repository**

```bash
# On DTN node
cd ~/mpas_simulation/input

# Clone MPAS-Data (if not already available)
git clone https://github.com/MPAS-Dev/MPAS-Data.git /tmp/MPAS-Data

# Copy grid files
cp /tmp/MPAS-Data/atmosphere/x1.10242.grid.nc .
cp /tmp/MPAS-Data/atmosphere/x1.10242.static.nc .
```

**Option 2: Download from MPAS Website**

- Visit: https://mpas-dev.github.io/
- Download grid files for your desired resolution
- Common resolutions: x1.10242, x1.2562, x1.40962

**Option 3: Generate Initial Conditions**

Use `init_atmosphere_model` to create initial conditions from:
- GFS analysis
- ERA5 reanalysis
- Other global datasets

## Example Templates

### Complete Example: Basic Simulation

**Directory Setup:**
```bash
mkdir -p ~/mpas_simulation/{input,output/{history,restart,diagnostics},logs}
cd ~/mpas_simulation
```

**Namelist Configuration:**
```fortran
&nhyd_model
    config_time_integration = 'split_explicit'
    config_dt = 300.0
    config_start_time = '2025-01-01_00:00:00'
    config_run_duration = '0000-00-01_00:00:00'
/

&data_sources
    config_geog_data_path = '/path/to/geog/data/'
/

&io
    config_pio_num_iotasks = 0
    config_pio_stride = 1
/

&physics
    config_physics_suite = 'mesoscale_reference'
/
```

**Streams Configuration:**
```xml
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
```

## Running Simulations

### PBS Job Script Template

Create `run_mpas.pbs`:

```bash
#!/bin/bash
#PBS -N mpas_simulation
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -o logs/mpas.out
#PBS -e logs/mpas.err

# Load modules
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau

# Set working directory
cd $PBS_O_WORKDIR

# Create output directories
mkdir -p output/{history,restart,diagnostics}

# Run MPAS
mpirun -np 48 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

### Interactive Run

```bash
# Request interactive node
qsub -I -l select=1:ncpus=4:mpiprocs=4 -l walltime=01:00:00 -q normal

# Once on compute node
module load chpc/parallel_studio_xe/16.0.1/2016.1.150
module load chpc/earth/mpas-lengau
cd ~/mpas_simulation
mpirun -np 4 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere
```

## Resources

### Official MPAS Resources

- **MPAS Documentation**: https://mpas-dev.github.io/
- **MPAS Repository**: https://github.com/MPAS-Dev/MPAS-Model
- **MPAS-Data Repository**: https://github.com/MPAS-Dev/MPAS-Data
- **User's Guide**: https://mpas-dev.github.io/atmosphere/atmosphere.html

### Example Configurations

- **MPAS Test Cases**: Check `$MPAS_ROOT/share/MPAS/core_atmosphere/`
- **MPAS Tutorial**: https://mpas-dev.github.io/tutorials/
- **MPAS Examples**: https://github.com/MPAS-Dev/MPAS-Model/tree/develop/src/core_atmosphere

### Getting Help

- **MPAS Forum**: Check MPAS documentation for community support
- **MPAS Issues**: https://github.com/MPAS-Dev/MPAS-Model/issues

## Next Steps

1. **Customize Configuration**: Edit namelist and streams for your specific needs
2. **Prepare Input Data**: Obtain or generate initial conditions and grid files
3. **Test Run**: Start with a short test simulation
4. **Production Run**: Scale up to full simulation with appropriate resources

