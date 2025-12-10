# Setting Up GitHub Repository

This guide will help you initialize and push this repository to GitHub.

## Prerequisites

- GitHub account ([github.com/msovara](https://github.com/msovara))
- Git installed locally
- SSH key configured for GitHub (or use HTTPS)

## Step 1: Initialize Git Repository

```bash
cd mpas-lengau
git init
git add .
git commit -m "Initial commit: MPAS installation scripts for Lengau cluster"
```

## Step 2: Create GitHub Repository

### Option A: Using GitHub Web Interface

1. Go to [GitHub](https://github.com/new)
2. Repository name: `mpas-lengau`
3. Description: "MPAS (Model for Prediction Across Scales) installation scripts for CHPC Lengau cluster"
4. Visibility: **Public** (recommended) or Private
5. **Do NOT** initialize with README, .gitignore, or license (we already have them)
6. Click "Create repository"

### Option B: Using GitHub CLI

```bash
gh repo create mpas-lengau --public --description "MPAS installation scripts for CHPC Lengau cluster"
```

## Step 3: Connect and Push

```bash
# Add remote (replace with your username if different)
git remote add origin https://github.com/msovara/mpas-lengau.git

# Or using SSH
git remote add origin git@github.com:msovara/mpas-lengau.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 4: Verify Repository

Visit: https://github.com/msovara/mpas-lengau

You should see:
- ✅ README.md with comprehensive documentation
- ✅ Installation scripts
- ✅ LICENSE file
- ✅ Documentation in `docs/` folder
- ✅ Proper .gitignore

## Step 5: Add Repository Topics

On GitHub, go to repository settings and add topics:
- `mpas`
- `lengau`
- `chpc`
- `hpc`
- `climate-modeling`
- `bash`
- `installation-script`

## Step 6: Enable GitHub Features

### Issues
- Enable Issues in repository settings
- Create issue templates if desired

### Actions
- CI workflow is already included (`.github/workflows/ci.yml`)
- Will run on push/PR

### Wiki
- Optional: Enable wiki for additional documentation

## Repository Structure

```
mpas-lengau/
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── .gitignore                  # Git ignore rules
├── CHANGELOG.md                # Version history
├── CONTRIBUTING.md             # Contribution guidelines
├── SETUP_GITHUB.md            # This file
├── download_mpas_source.sh     # Source download script
├── install_mpas_lengau.sh      # Installation script
├── docs/                       # Additional documentation
│   ├── TROUBLESHOOTING.md     # Troubleshooting guide
│   └── CONFIGURATION.md       # Configuration guide
└── .github/
    └── workflows/
        └── ci.yml             # CI workflow
```

## Next Steps

1. **Add Badges** (optional): Add badges to README.md
2. **Create Releases**: Tag versions for releases
3. **Add Examples**: Create examples directory with usage examples
4. **Documentation**: Keep documentation updated
5. **Community**: Respond to issues and PRs

## Badge Examples

Add to README.md after repository is created:

```markdown
[![GitHub release](https://img.shields.io/github/release/msovara/mpas-lengau.svg)](https://github.com/msovara/mpas-lengau/releases)
[![GitHub issues](https://img.shields.io/github/issues/msovara/mpas-lengau.svg)](https://github.com/msovara/mpas-lengau/issues)
[![GitHub stars](https://img.shields.io/github/stars/msovara/mpas-lengau.svg)](https://github.com/msovara/mpas-lengau/stargazers)
```

## Troubleshooting

### Authentication Issues

If you get authentication errors:

```bash
# Use personal access token instead of password
git remote set-url origin https://YOUR_TOKEN@github.com/msovara/mpas-lengau.git
```

### Large Files

If files are too large:

```bash
# Use Git LFS for large files
git lfs install
git lfs track "*.sh"
```

### Push Rejected

If push is rejected:

```bash
# Pull first
git pull origin main --allow-unrelated-histories
# Then push
git push -u origin main
```

## Collaboration

To allow others to contribute:

1. Go to repository Settings → Collaborators
2. Add collaborators
3. Or use GitHub's fork and PR workflow

## License

This repository uses MIT License. Make sure LICENSE file is present and correct.

---

**Ready to share!** 🚀

