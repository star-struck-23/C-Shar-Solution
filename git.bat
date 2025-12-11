#!/bin/bash

# Set your new credentials
NEW_NAME="star-struck-23"
NEW_EMAIL="165274593+star-struck-23@users.noreply.github.com"

# Backup your repository first
echo "Creating backup of current state..."
git branch backup-before-email-rewrite

# Get all unique author and committer emails in the repository
echo "Finding all unique emails in repository history..."
ALL_EMAILS=$(git log --pretty=format:"%ae%n%ce" | sort | uniq)

echo "Found the following emails:"
echo "$ALL_EMAILS"
echo ""

# Check if running on Windows (Git Bash) to adjust sed command
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    SED_CMD="sed -i"
else
    SED_CMD="sed -i ''"
fi

# Rewrite all commits with new name and email
echo "Rewriting Git history with new credentials..."
echo "New Name: $NEW_NAME"
echo "New Email: $NEW_EMAIL"
echo ""

# Option 1: Replace ALL emails with new one (simplest approach)
echo "Option 1: Replacing ALL emails with the new one..."
git filter-branch --env-filter '
OLD_EMAIL=""
CORRECT_NAME="'"$NEW_NAME"'"
CORRECT_EMAIL="'"$NEW_EMAIL"'"

if [ "$GIT_COMMITTER_EMAIL" != "$CORRECT_EMAIL" ]; then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" != "$CORRECT_EMAIL" ]; then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

# Option 2: If you want to replace specific old emails only
# Uncomment and modify this section instead of Option 1 if needed
# OLD_EMAIL="your.old-email@example.com"  # Change this to your old email
# echo "Option 2: Replacing specific old email: $OLD_EMAIL"
# git filter-branch --env-filter '
# OLD_EMAIL="'"$OLD_EMAIL"'"
# CORRECT_NAME="'"$NEW_NAME"'"
# CORRECT_EMAIL="'"$NEW_EMAIL"'"
# 
# if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]; then
#     export GIT_COMMITTER_NAME="$CORRECT_NAME"
#     export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
# fi
# if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]; then
#     export GIT_AUTHOR_NAME="$CORRECT_NAME"
#     export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
# fi
# ' --tag-name-filter cat -- --branches --tags

# Clean up and optimize repository
echo "Cleaning up..."
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo ""
echo "Done! Repository history has been rewritten."
echo ""
echo "Verification - last 5 commits:"
git log --pretty=format:"%h - %an <%ae> - %ad - %s" --date=short -5
