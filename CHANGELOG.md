# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-09

### Added
- Initial release of MPAS installation scripts for Lengau cluster
- `download_mpas_source.sh`: Script for downloading MPAS source code on DTN node
- `install_mpas_lengau.sh`: Comprehensive installation script for compute nodes
- Support for MPAS v8.3.1
- Automatic module loading (Intel, NetCDF, HDF5, CMake, PnetCDF)
- PnetCDF detection and configuration
- Fortran compatibility patches for GCC 4.8.5:
  - `c_loc` fix in `mpas_stream_inquiry.F`
  - `ieee_arithmetic` fix in `mpas_atm_time_integration.F`
- Intel runtime library linking for mixed compiler environments
- MPAS-Data pre-population for CMake FetchContent
- Git submodule initialization (ESMF, MMM-physics, UGWP)
- Module file generation for Lengau module system
- Setup script generation for environment configuration
- Comprehensive error handling and informative messages
- Installation logging

### Fixed
- Resolved undefined Intel symbol errors (`__intel_sse2_strdup`, etc.)
- Fixed PnetCDF detection issues
- Resolved CMake FetchContent network failures on compute nodes
- Fixed MPI version consistency issues
- Resolved Fortran compilation errors with GCC 4.8.5

### Technical Details
- **MPAS Version**: v8.3.1
- **Intel Compiler**: Parallel Studio XE 2016.1.150 (primary), 2018.2.046 (fallback)
- **GCC Version**: 4.8.5 (via MPI wrappers)
- **CMake Version**: 3.14.4
- **NetCDF**: 4.7.4
- **HDF5**: 1.12.0
- **PnetCDF**: 1.11.0

## [Unreleased]

### Planned
- Support for additional MPAS versions
- Automated testing framework
- Docker/Singularity container support
- Integration with other CHPC software installations
- Performance benchmarking scripts

