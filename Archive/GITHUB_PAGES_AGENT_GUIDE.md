# GitHub Pages Agent - Quick Start Guide

## Automated Setup Script

I've created `enable_github_pages.ps1` - an automated agent that will enable GitHub Pages for you via the GitHub API.

## How to Use:

### Step 1: Create a GitHub Token

1. Go to: https://github.com/settings/tokens/new
2. Give it a descriptive name: "GitHub Pages Setup"
3. Set expiration: Your choice (recommend 7-30 days for temporary use)
4. Check the **`repo`** scope (this gives full repository access)
5. Scroll down and click **"Generate token"**
6. **Copy the token immediately** (you won't see it again!)

### Step 2: Run the Agent

Open PowerShell in this directory and run:

```powershell
.\enable_github_pages.ps1 -Token YOUR_TOKEN_HERE
```

Replace `YOUR_TOKEN_HERE` with the token you just copied.

### Example:

```powershell
.\enable_github_pages.ps1 -Token ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## What the Agent Does:

✓ Connects to GitHub API with your credentials  
✓ Enables GitHub Pages automatically  
✓ Configures it to use the `main` branch and `/docs` folder  
✓ Shows you the URL where your site will be published  
✓ Handles errors and provides helpful feedback  

## Your Site Will Be Available At:

**https://bob10042.github.io/quantum/**

(Allow 2-3 minutes for GitHub to build and deploy)

## Security Note:

- The token is only used locally and never stored
- You can delete the token after use from: https://github.com/settings/tokens
- The script only makes one API call to enable Pages

## Troubleshooting:

If you get an error about execution policy, run:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run the enable script again.

## Alternative: Manual Setup

If you prefer not to use a token, follow the manual instructions in `ENABLE_GITHUB_PAGES.md`.
