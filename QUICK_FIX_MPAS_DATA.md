# Quick Fix: MPAS-Data Not Found

## Problem

```
ls: cannot access /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Data: No such file or directory
```

## Solution: Clone MPAS-Data on DTN Node

MPAS-Data must be cloned on the DTN node (which has internet access) before running the installation script.

### Step 1: SSH to DTN Node

```bash
ssh msovara@dtn.chpc.ac.za
```

### Step 2: Navigate and Clone MPAS-Data

```bash
# Navigate to installation directory
cd /home/apps/chpc/earth/MPAS-8.3.1

# Create build directory if it doesn't exist
mkdir -p build

# Clone MPAS-Data directly
cd build
git clone https://github.com/MPAS-Dev/MPAS-Data.git MPAS-Data

# Verify it was cloned
ls -la MPAS-Data
```

### Step 3: Alternative - Run Full Download Script

If you haven't run the download script yet:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
./download_mpas_source.sh
```

This will clone:
- MPAS-Model (if not already done)
- MPAS-Data (required)
- Optional repositories (MMM-physics, UGWP, etc.)

### Step 4: Verify on Compute Node

After cloning on DTN node, verify from compute node:

```bash
# On compute node
ls -la /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Data

# Should show:
# drwxrwsr-x ... MPAS-Data
#   - .git/
#   - atmosphere/
#   - etc.
```

### Step 5: Run Installation

Once MPAS-Data exists, run the installation:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
./install_mpas_lengau.sh
```

## Manual Clone (If Download Script Fails)

If the download script doesn't work, manually clone:

```bash
# On DTN node
cd /home/apps/chpc/earth/MPAS-8.3.1
mkdir -p build
cd build

# Clone MPAS-Data
git clone https://github.com/MPAS-Dev/MPAS-Data.git MPAS-Data

# Verify
ls -la MPAS-Data/.git
```

## Troubleshooting

### Git Clone Fails

If git clone fails with SSL errors:

```bash
export GIT_SSL_NO_VERIFY=1
git clone https://github.com/MPAS-Dev/MPAS-Data.git MPAS-Data
```

### Directory Permissions

If you get permission errors:

```bash
# Check permissions
ls -ld /home/apps/chpc/earth/MPAS-8.3.1/build

# Fix if needed (adjust as appropriate for your setup)
chmod 755 /home/apps/chpc/earth/MPAS-8.3.1/build
```

### Verify MPAS-Data Structure

MPAS-Data should contain:

```bash
ls /home/apps/chpc/earth/MPAS-8.3.1/build/MPAS-Data
# Should show:
# - atmosphere/
# - ocean/
# - .git/
# - README.md
# etc.
```

