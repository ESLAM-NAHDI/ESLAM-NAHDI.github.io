#!/bin/bash
# Manual deploy: Build Flutter web and push to gh-pages branch
set -e

echo "Bumping version..."
bash scripts/bump_version.sh

echo "Building Flutter web..."
flutter build web --base-href "/"

echo "Pushing to gh-pages..."
cd build/web
git init
git add -A
git commit -m "Deploy: Nahdi API Dashboard"
git branch -M main
git remote add origin git@github.com-eslam-nahdi:ESLAM-NAHDI/ESLAM-NAHDI.github.io.git 2>/dev/null || true
git push -f origin main:gh-pages
cd ../..
rm -rf build/web/.git

echo "Committing version bump..."
git add pubspec.yaml
git diff --staged --quiet || git commit -m "chore: bump version [skip ci]"
git push || true

echo ""
echo "Done! Site should update at https://ESLAM-NAHDI.github.io/ in 1-2 minutes."
echo ""
echo "IMPORTANT: In GitHub repo Settings -> Pages, set:"
echo "  Source: Deploy from a branch"
echo "  Branch: gh-pages"
echo "  Folder: / (root)"
