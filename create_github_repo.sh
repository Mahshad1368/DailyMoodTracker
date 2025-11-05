#!/bin/bash

# Create GitHub Repository and Push
# This script will open GitHub to create a new repo

echo "📱 Daily Mood Tracker - GitHub Setup"
echo "===================================="
echo ""

# Repository details
REPO_NAME="DailyMoodTracker"
DESCRIPTION="iOS mood tracking app with dynamic icons that change based on your daily mood 🎨📱"

echo "Repository Name: $REPO_NAME"
echo "Description: $DESCRIPTION"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Error: Git not initialized in this directory"
    exit 1
fi

echo "✅ Git repository initialized"
echo ""

# Get GitHub username
echo "📝 What is your GitHub username?"
read -p "Username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: Username cannot be empty"
    exit 1
fi

echo ""
echo "🔗 Creating GitHub repository..."
echo ""

# Open GitHub to create new repo
echo "Opening GitHub in your browser to create the repository..."
echo "Repository will be created at: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "⚠️  IMPORTANT: Make sure to:"
echo "   1. Repository name: $REPO_NAME"
echo "   2. Make it PUBLIC (so others can see your cool project!)"
echo "   3. DO NOT initialize with README, .gitignore, or license"
echo "   4. Click 'Create repository'"
echo ""

open "https://github.com/new"

# Wait for user to create repo
echo "Press ENTER after you've created the repository on GitHub..."
read

echo ""
echo "📤 Pushing to GitHub..."
echo ""

# Add remote and push
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🎉 Your repository is live at:"
    echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    echo ""
    echo "📱 View your project:"
    echo "   git remote -v"
    echo ""
else
    echo ""
    echo "❌ Push failed. This might be because:"
    echo "   1. Repository wasn't created on GitHub yet"
    echo "   2. Wrong username"
    echo "   3. Authentication required"
    echo ""
    echo "Try pushing manually:"
    echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo "   git push -u origin main"
    echo ""
fi
