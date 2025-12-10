# Deploying MPAS Installation Scripts to Cluster

The installation scripts need to be copied to the cluster before use. Here are several methods:

## Method 1: Clone from GitHub (Recommended)

On the cluster (DTN node or login node):

```bash
# Create the directory
mkdir -p /home/apps/chpc/earth/MPAS-8.3.1
cd /home/apps/chpc/earth/MPAS-8.3.1

# Clone the repository
git clone https://github.com/msovara/mpas-lengau.git .

# Or clone to a temp location and copy
git clone https://github.com/msovara/mpas-lengau.git /tmp/mpas-lengau
cp /tmp/mpas-lengau/*.sh /home/apps/chpc/earth/MPAS-8.3.1/
chmod +x /home/apps/chpc/earth/MPAS-8.3.1/*.sh
```

## Method 2: Download Scripts Directly from GitHub

On the cluster (DTN node has internet access):

```bash
# Create the directory
mkdir -p /home/apps/chpc/earth/MPAS-8.3.1
cd /home/apps/chpc/earth/MPAS-8.3.1

# Download the scripts
wget https://raw.githubusercontent.com/msovara/mpas-lengau/main/install_mpas_lengau.sh
wget https://raw.githubusercontent.com/msovara/mpas-lengau/main/download_mpas_source.sh

# Make them executable
chmod +x install_mpas_lengau.sh download_mpas_source.sh
```

## Method 3: Copy from Local Machine

From your local machine (Windows):

```bash
# Using SCP
scp install_mpas_lengau.sh download_mpas_source.sh msovara@lengau.chpc.ac.za:/home/apps/chpc/earth/MPAS-8.3.1/

# Or using SFTP
sftp msovara@lengau.chpc.ac.za
cd /home/apps/chpc/earth/MPAS-8.3.1
put install_mpas_lengau.sh
put download_mpas_source.sh
exit
```

Then on the cluster:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
chmod +x *.sh
```

## Method 4: Create Scripts Manually

If you can't access GitHub, create the scripts manually by copying from the repository.

## Verify Scripts Are Ready

After copying, verify:

```bash
cd /home/apps/chpc/earth/MPAS-8.3.1
ls -lh *.sh
# Should show:
# -rwxr-xr-x 1 msovara rchpc ... download_mpas_source.sh
# -rwxr-xr-x 1 msovara rchpc ... install_mpas_lengau.sh

# Test that they're executable
./download_mpas_source.sh --help  # or just run to see usage
```

## Next Steps

Once scripts are in place:

1. **On DTN node** (has internet):
   ```bash
   cd /home/apps/chpc/earth/MPAS-8.3.1
   ./download_mpas_source.sh
   ```

2. **On compute node** (no internet):
   ```bash
   cd /home/apps/chpc/earth/MPAS-8.3.1
   ./install_mpas_lengau.sh
   ```

## Troubleshooting

### Scripts not found
- Verify the path: `ls -la /home/apps/chpc/earth/MPAS-8.3.1/`
- Check permissions: `chmod +x /home/apps/chpc/earth/MPAS-8.3.1/*.sh`

### Permission denied
- Make scripts executable: `chmod +x *.sh`
- Check directory permissions: `ls -ld /home/apps/chpc/earth/MPAS-8.3.1`

### Directory doesn't exist
- Create it: `mkdir -p /home/apps/chpc/earth/MPAS-8.3.1`
- Check parent directory permissions: `ls -ld /home/apps/chpc/earth`

