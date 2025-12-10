# Quick Start: Push to GitHub

## Step 1: Create Repository on GitHub

**Go to**: https://github.com/new

**Settings**:
- Repository name: `mpas-lengau`
- Description: `MPAS installation scripts for CHPC Lengau cluster`
- Visibility: **Public** (recommended)
- ⚠️ **DO NOT** check "Add a README file"
- ⚠️ **DO NOT** add .gitignore or license
- Click **"Create repository"**

## Step 2: Push from Local Machine

### Option A: Use PowerShell Script (Windows)

```powershell
cd mpas-lengau
.\push_to_github.ps1
```

### Option B: Manual Commands

```powershell
cd mpas-lengau

# Verify everything is committed
git status

# Push to GitHub
git push -u origin main
```

### Option C: Using Git Bash or Linux/Mac

```bash
cd mpas-lengau

# Verify everything is committed
git status

# Push to GitHub
git push -u origin main
```

## Step 3: Verify

Visit: https://github.com/msovara/mpas-lengau

You should see all files including:
- ✅ README.md
- ✅ Installation scripts
- ✅ Documentation
- ✅ LICENSE

## Security Recommendation

After successful push, set up Git Credential Manager:

```bash
git config --global credential.helper manager-core
```

This will securely store your credentials for future pushes.

## Troubleshooting

### "Repository not found"
- Make sure you created the repository on GitHub first
- Check the repository name matches: `mpas-lengau`

### "Authentication failed"
- Verify your PAT token is valid
- Check token has `repo` scope

### "Permission denied"
- Ensure you're pushing to the correct repository
- Verify you have write access

## Next Steps

1. Add repository topics on GitHub
2. Enable Issues (if desired)
3. Share the repository link
4. Consider adding badges to README

---

**Repository URL**: https://github.com/msovara/mpas-lengau

