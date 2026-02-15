#!/bin/bash
# Deploy 11ty site with QA screenshots at multiple breakpoints

set -e

SITE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DEPLOY_DIR="/home/clawdbot/clawd/projects/yorba-linda-ortho-directory"
QA_DIR="$SITE_DIR/qa-screenshots"
BASE_URL="https://ortho.cb.robotarmy.cloud"

echo "🔨 Building site..."
cd "$SITE_DIR"
npx @11ty/eleventy --quiet

echo "📦 Deploying to nginx..."
cp -r _site/* "$DEPLOY_DIR/"

echo "✅ Deployed! Site live at $BASE_URL"

# Output pages for QA
echo ""
echo "📋 Pages to QA:"
find _site -name "index.html" | sed 's|_site||' | sed 's|/index.html||' | while read path; do
    if [ -z "$path" ]; then
        echo "  - $BASE_URL/"
    else
        echo "  - $BASE_URL$path/"
    fi
done

echo ""
echo "Run QA with: node $SITE_DIR/scripts/qa-screenshots.js"
