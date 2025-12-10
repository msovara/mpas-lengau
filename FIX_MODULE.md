# Fix MPAS Module File

## Issue

The MPAS module file is setting `LD_LIBRARY_PATH` to `lib` but libraries are in `lib64`.

## Quick Fix

Edit the module file on the cluster:

```bash
nano /apps/chpc/scripts/modules/earth/mpas-lengau
```

Change this line:
```tcl
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib
```

To:
```tcl
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib64
prepend-path LD_LIBRARY_PATH ${mpas_root}/lib
```

Or manually add lib64:

```bash
# After loading module, add lib64
module load chpc/earth/mpas-lengau
export LD_LIBRARY_PATH=/home/apps/chpc/earth/MPAS-8.3.1/lib64:$LD_LIBRARY_PATH
```

## Permanent Fix

The installation script has been updated to include both `lib64` and `lib` in the module file. Re-run the installation or manually update the module file.

