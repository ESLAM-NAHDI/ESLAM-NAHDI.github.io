# Deploy Nahdi API Dashboard to GitHub Pages

## Your setup
- **Repository**: ESLAM-NAHDI
- **Live URL** (after deploy): `https://<your-github-username>.github.io/ESLAM-NAHDI/`

## Step 1: Push to GitHub

```bash
cd /Users/eslamwaheedrafat/StudioProjects/nahdi_api_dashboard

# Initialize git (if not already)
git init

# Add all files
git add .
git commit -m "Initial commit: Nahdi API Dashboard"

# Add your GitHub remote (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/ESLAM-NAHDI.git

# Push to main
git branch -M main
git push -u origin main
```

## Step 2: Enable GitHub Pages

1. Go to your repo: **https://github.com/YOUR_USERNAME/ESLAM-NAHDI**
2. Click **Settings** → **Pages**
3. Under **Build and deployment**:
   - **Source**: Deploy from a branch
   - **Branch**: `gh-pages` (select **root**)
4. Click **Save**

## Step 3: Automatic deploy

On every push to `main` or `master`, the GitHub Action will:

1. Build the Flutter web app with `base-href: /ESLAM-NAHDI/`
2. Deploy it to the `gh-pages` branch
3. Serve it from the URL above

## Local build

To build locally:

```bash
flutter build web --base-href "/ESLAM-NAHDI/"
```

Output is in `build/web/`.

## Custom domain (optional)

To use a custom domain, add a `CNAME` file in `build/web/` before deploy or set the `cname` option in `.github/workflows/deploy.yml`.
