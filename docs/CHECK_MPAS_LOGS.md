# Checking MPAS Log Files

When MPAS runs, it creates log files that contain the actual error messages. Always check these files!

## Log File Locations

MPAS creates log files in the current working directory:
- `log.atmosphere.0000.out` - Standard output
- `log.atmosphere.0000.err` - Error output

## How to Check Logs

```bash
# Check error log first (most important)
cat log.atmosphere.0000.err

# Check output log
cat log.atmosphere.0000.out

# Or view both
cat log.atmosphere.0000.*
```

## Common Errors in Logs

### Missing Input Files
```
ERROR: Could not open file: init.nc
ERROR: File not found: x1.10242.grid.nc
```

### Configuration Errors
```
ERROR: Invalid namelist option
ERROR: config_dt must be positive
```

### Library Errors
```
ERROR: Could not load library
ERROR: Symbol not found
```

### Data Errors
```
ERROR: Invalid grid file
ERROR: Initial conditions missing
```

## Next Steps After Checking Logs

1. **Read the error log** - This contains the actual error message
2. **Fix the issue** - Based on the error message
3. **Re-run** - After fixing the issue

## Example

```bash
# Run MPAS
mpirun -np 1 mpas_atmosphere -n namelist.atmosphere -s streams.atmosphere

# Check logs
cat log.atmosphere.0000.err
# This will show the actual error!
```

