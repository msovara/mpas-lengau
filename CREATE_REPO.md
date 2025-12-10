# Create GitHub Repository First

The repository needs to be created on GitHub before we can push to it.

## Option 1: Create via GitHub Web Interface (Recommended)

1. Go to: https://github.com/new
2. Repository name: **mpas-lengau**
3. Description: "MPAS installation scripts for CHPC Lengau cluster"
4. Visibility: **Public** (recommended) or Private
5. **IMPORTANT**: Do NOT check "Add a README file" (we already have one)
6. **IMPORTANT**: Do NOT add .gitignore or license (we already have them)
7. Click **"Create repository"**

## Option 2: Create via GitHub CLI

If you have GitHub CLI installed:

```bash
gh repo create mpas-lengau --public --description "MPAS installation scripts for CHPC Lengau cluster" --source=. --remote=origin --push
```

## After Creating Repository

Once the repository is created on GitHub, run:

```bash
cd mpas-lengau
git remote add origin https://github.com/msovara/mpas-lengau.git
git branch -M main
git push -u origin main
# When prompted, use your GitHub username and PAT token as password
```

## Security Note

⚠️ **Important**: After pushing, consider:
1. Removing the token from your command history
2. Using Git Credential Manager for future pushes
3. Or using SSH keys instead of PAT

To use Git Credential Manager:
```bash
git config --global credential.helper manager-core
```

Then you can use HTTPS without embedding the token.

