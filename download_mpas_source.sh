#!/bin/bash

# MPAS Source Download Script for Lengau Cluster
# This script downloads MPAS source code to the cluster
# IMPORTANT: Run this ON THE DTN NODE (dtn.chpc.ac.za) - compute nodes have no internet!
# After downloading, run install_mpas_lengau.sh on a compute node

set -e

# Configuration
BUILD_DIR="/mnt/lustre/users/msovara/SoftwareBuilds/MPAS/build"
MPAS_VERSION="v8.3.1"  # Latest version as of 2025. Update to desired version if needed
MPAS_SOURCE_URL="https://github.com/MPAS-Dev/MPAS-Model.git"

echo "=== MPAS Source Download Script ==="
echo "Build directory: ${BUILD_DIR}"
echo "MPAS version: ${MPAS_VERSION}"
echo ""
echo "NOTE: This script runs on the cluster"
echo ""

# Create directories
echo "Creating build directory..."
mkdir -p ${BUILD_DIR}

# Check if source already exists
if [ -d "${BUILD_DIR}/MPAS-Model" ]; then
    echo "✓ MPAS source code already exists at ${BUILD_DIR}/MPAS-Model"
    echo "Checking and updating optional repositories (MMM-physics, UGWP, etc.)..."
    cd ${BUILD_DIR}/MPAS-Model
    
    # Update submodules if any
    if [ -f ".gitmodules" ]; then
        echo "Updating git submodules..."
        git submodule update --init --recursive 2>/dev/null || echo "⚠ Submodule update had issues"
    fi
    
    # Update optional repositories that CMake might clone
    echo "Checking optional MPAS repositories..."
    
    # MMM-physics
    if [ -d "src/core_atmosphere/physics/physics_mmm/.git" ]; then
        echo "✓ MMM-physics exists, updating..."
        cd src/core_atmosphere/physics/physics_mmm
        git pull 2>/dev/null || echo "⚠ MMM-physics update had issues"
        cd ../../../../..
    elif [ ! -d "src/core_atmosphere/physics/physics_mmm" ] || [ -z "$(ls -A src/core_atmosphere/physics/physics_mmm 2>/dev/null)" ]; then
        echo "Cloning MMM-physics (required by CMake)..."
        # Remove empty directory if it exists
        rm -rf src/core_atmosphere/physics/physics_mmm
        mkdir -p src/core_atmosphere/physics
        git clone https://github.com/NCAR/MMM-physics.git src/core_atmosphere/physics/physics_mmm 2>&1 || {
            echo "⚠ MMM-physics clone failed"
            rmdir src/core_atmosphere/physics/physics_mmm 2>/dev/null || true
        }
        if [ -d "src/core_atmosphere/physics/physics_mmm" ] && [ -n "$(ls -A src/core_atmosphere/physics/physics_mmm 2>/dev/null)" ]; then
            echo "✓ MMM-physics cloned successfully"
        else
            echo "⚠ MMM-physics directory is still empty after clone attempt"
        fi
    else
        echo "✓ MMM-physics already exists and has content"
    fi
    
    # UGWP
    if [ -d "src/core_atmosphere/physics/physics_noaa/UGWP/.git" ]; then
        echo "✓ UGWP exists, updating..."
        cd src/core_atmosphere/physics/physics_noaa/UGWP
        git pull 2>/dev/null || echo "⚠ UGWP update had issues"
        cd ../../../../..
    elif [ ! -d "src/core_atmosphere/physics/physics_noaa/UGWP" ]; then
        echo "Cloning UGWP (optional)..."
        mkdir -p src/core_atmosphere/physics/physics_noaa
        git clone https://github.com/NOAA-GSL/UGWP.git src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || {
            echo "⚠ UGWP clone failed (optional, continuing)"
            rmdir src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || true
        }
    fi
    
    # ESMF (if it's a submodule)
    if [ -f ".gitmodules" ] && grep -q "esmf" .gitmodules 2>/dev/null; then
        if [ ! -d "src/external/esmf" ]; then
            echo "Initializing ESMF submodule..."
            git submodule update --init src/external/esmf 2>/dev/null || echo "⚠ ESMF submodule initialization had issues"
        fi
    fi
    
    # MPAS-Data (required by CMake FetchContent)
    # CMake FetchContent will clone this, but we can pre-populate it
    # Clone it to a location where CMake can find it
    echo "Checking for MPAS-Data (required by CMake FetchContent)..."
    MPAS_DATA_DIR="${BUILD_DIR}/MPAS-Data"
    if [ ! -d "${MPAS_DATA_DIR}" ]; then
        echo "Cloning MPAS-Data (required by CMake)..."
        cd ${BUILD_DIR}
        git clone https://github.com/MPAS-Dev/MPAS-Data.git MPAS-Data 2>/dev/null || {
            echo "⚠ MPAS-Data clone failed"
        }
        cd MPAS-Model
    else
        echo "✓ MPAS-Data already exists at ${MPAS_DATA_DIR}"
    fi
    
    echo ""
    echo "=== Optional Repositories Updated ==="
    echo "MPAS source code at: ${BUILD_DIR}/MPAS-Model"
    echo ""
    echo "Next step: Run install_mpas_lengau.sh to compile and install MPAS"
    exit 0
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo "✗ Git not available. Please install git or download MPAS source manually."
    exit 1
fi

# Download MPAS source
echo "Downloading MPAS source code from GitHub..."
cd ${BUILD_DIR}

# Check if already cloned
if [ -d "MPAS-Model" ] && [ -d "MPAS-Model/.git" ]; then
    echo "✓ MPAS repository already exists, updating..."
    cd MPAS-Model
    git fetch --all --tags 2>/dev/null || echo "⚠ Git fetch had issues"
    
    # Checkout specific version if specified
    if [ -n "${MPAS_VERSION}" ]; then
        echo "Checking out version ${MPAS_VERSION}..."
        git checkout ${MPAS_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${MPAS_VERSION}, using current branch"
            echo "Available tags:"
            git tag | tail -10
        }
    fi
    
    # Update submodules if any
    if [ -f ".gitmodules" ]; then
        echo "Updating git submodules..."
        git submodule update --init --recursive 2>/dev/null || echo "⚠ Submodule update had issues"
    fi
    
    # Update optional repositories that CMake might clone
    echo "Updating optional MPAS repositories..."
    
    # MMM-physics
    if [ -d "src/core_atmosphere/physics/physics_mmm/.git" ]; then
        echo "Updating MMM-physics..."
        cd src/core_atmosphere/physics/physics_mmm
        git pull 2>/dev/null || echo "⚠ MMM-physics update had issues"
        cd ../../../../..
    elif [ ! -d "src/core_atmosphere/physics/physics_mmm" ]; then
        echo "Cloning MMM-physics..."
        mkdir -p src/core_atmosphere/physics/physics_mmm
        git clone https://github.com/NCAR/MMM-physics.git src/core_atmosphere/physics/physics_mmm 2>/dev/null || {
            echo "⚠ MMM-physics clone failed, but continuing (it's optional)"
            rmdir src/core_atmosphere/physics/physics_mmm 2>/dev/null || true
        }
    fi
    
    # UGWP
    if [ -d "src/core_atmosphere/physics/physics_noaa/UGWP/.git" ]; then
        echo "Updating UGWP..."
        cd src/core_atmosphere/physics/physics_noaa/UGWP
        git pull 2>/dev/null || echo "⚠ UGWP update had issues"
        cd ../../../../..
    elif [ ! -d "src/core_atmosphere/physics/physics_noaa/UGWP" ]; then
        echo "Cloning UGWP..."
        mkdir -p src/core_atmosphere/physics/physics_noaa
        git clone https://github.com/NOAA-GSL/UGWP.git src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || {
            echo "⚠ UGWP clone failed, but continuing (it's optional)"
            rmdir src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || true
        }
    fi
    
    cd ..
else
    # Fresh clone
    echo "Cloning MPAS from GitHub (this may take a few minutes)..."
    git clone ${MPAS_SOURCE_URL} MPAS-Model || {
        echo "✗ GitHub clone failed"
        echo "Please download MPAS source code manually and place it in ${BUILD_DIR}/MPAS-Model"
        echo "You can obtain MPAS from: https://github.com/MPAS-Dev/MPAS-Model"
        exit 1
    }
    
    # Checkout specific version if specified
    if [ -n "${MPAS_VERSION}" ]; then
        cd MPAS-Model
        echo "Checking out version ${MPAS_VERSION}..."
        git checkout ${MPAS_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${MPAS_VERSION}, using default branch"
            echo "Available tags:"
            git tag | tail -10
        }
        cd ..
    fi
    
    # Initialize submodules if any
    cd MPAS-Model
    if [ -f ".gitmodules" ]; then
        echo "Initializing git submodules..."
        git submodule update --init --recursive 2>/dev/null || echo "⚠ Submodule initialization had issues"
    fi
    
    # MPAS v8.3.1 CMake may try to clone optional repositories during configuration
    # Pre-clone them here on DTN (where internet is available)
    echo "Pre-cloning optional MPAS repositories (MMM-physics, UGWP, etc.)..."
    
    # MMM-physics (optional physics package)
    if [ ! -d "src/core_atmosphere/physics/physics_mmm" ] || [ -z "$(ls -A src/core_atmosphere/physics/physics_mmm 2>/dev/null)" ]; then
        echo "Cloning MMM-physics..."
        # Remove empty directory if it exists
        rm -rf src/core_atmosphere/physics/physics_mmm
        mkdir -p src/core_atmosphere/physics
        git clone https://github.com/NCAR/MMM-physics.git src/core_atmosphere/physics/physics_mmm 2>&1 || {
            echo "⚠ MMM-physics clone failed, but continuing (it's optional)"
            rmdir src/core_atmosphere/physics/physics_mmm 2>/dev/null || true
        }
        if [ -d "src/core_atmosphere/physics/physics_mmm" ] && [ -n "$(ls -A src/core_atmosphere/physics/physics_mmm 2>/dev/null)" ]; then
            echo "✓ MMM-physics cloned successfully"
        else
            echo "⚠ MMM-physics directory is still empty after clone attempt"
        fi
    else
        echo "✓ MMM-physics already exists and has content"
    fi
    
    # UGWP (Unified Gravity Wave Physics)
    if [ ! -d "src/core_atmosphere/physics/physics_noaa/UGWP" ]; then
        echo "Cloning UGWP..."
        mkdir -p src/core_atmosphere/physics/physics_noaa
        git clone https://github.com/NOAA-GSL/UGWP.git src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || {
            echo "⚠ UGWP clone failed, but continuing (it's optional)"
            rmdir src/core_atmosphere/physics/physics_noaa/UGWP 2>/dev/null || true
        }
    else
        echo "✓ UGWP already exists"
    fi
    
    # ESMF (Earth System Modeling Framework) - may be cloned as submodule
    if [ ! -d "src/external/esmf" ] && [ -f ".gitmodules" ] && grep -q "esmf" .gitmodules 2>/dev/null; then
        echo "Initializing ESMF submodule..."
        git submodule update --init src/external/esmf 2>/dev/null || echo "⚠ ESMF submodule initialization had issues"
    fi
    
    cd ..
fi

echo ""
echo "=== Download Complete ==="
echo "MPAS source code downloaded to: ${BUILD_DIR}/MPAS-Model"
echo ""
echo "Next step: Run install_mpas_lengau.sh to compile and install MPAS"

