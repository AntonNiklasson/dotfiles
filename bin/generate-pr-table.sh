#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate PR before/after table
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📸
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.author Anton Niklasson
# @raycast.authorURL www.github.com/antonniklasson

# Read the configuration file
SCREENSHOT_FOLDER=$(defaults read com.apple.screencapture location)

# Change into the screenshot folder
cd "$SCREENSHOT_FOLDER"

# Get the last two screenshot file paths
screenshot_before=$(find . -type f -name 'screenshot-*.png' | head -n 1 | xargs -I {} echo "{}")
screenshot_after=$(find . -type f -name 'screenshot-*.png' | head -n 2 | tail -n 1 | xargs -I {} echo "{}")

# Upload the screenshots to GCS
gsutil cp "$screenshot_before" gs://sana-dev-screenshots/
gsutil cp "$screenshot_after" gs://sana-dev-screenshots/

# Get the URLs of the uploaded images
url_before=$(gsutil ls gs://sana-dev-screenshots/* | grep "$screenshot_before" | xargs -I {} gsutil cat {} | base64 -w 0)
url_after=$(gsutil ls gs://sana-dev-screenshots/* | grep "$screenshot_after" | xargs -I {} gsutil cat {} | base64 -w 0)

# Construct the markdown table
echo "| Before | After |"
echo "|--------|--------|"
echo "| ![alt text]($url_before) | ![alt text]($url_after) |"
