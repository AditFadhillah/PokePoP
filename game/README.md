## Development Commands

------------------------------------------------------------

# Install dependencies (first time or after updating package.json)
npm install

# Start development server with hot reload
npm run dev

# Build production-ready files (output in dist/)
npm run build

# Preview the production build locally
npm run preview

# GITHUB
# Initialize repo (first time)
git init

# Add all changes
git add .

# Or add specific file
git add src/ui/App.tsx

# Commit with message
git commit -m "message"

# Push to remote (after git remote add origin …)
git push origin main

# Pull latest changes
git pull origin main

# Check remote URL
git remote -v

# Check repo status (changed files, branch)
git status

# See changes in detail
git diff

# Create new branch
git checkout -b feature-battle-system

# Switch to another branch
git checkout main

# List all branches
git branch

# Push new branch to GitHub
git push -u origin feature-battle-system

# Merge feature branch into main
git checkout main
git pull origin main
git merge feature-battle-system

# Delete branch locally
git branch -d feature-battle-system

# Delete branch on GitHub
git push origin --delete feature-battle-system

# Unstage a file (remove from git add)
git reset HEAD <file>

# Discard changes in a file (CAREFUL: irreversible)
git checkout -- <file>

# Amend the last commit (e.g., fix commit message)
git commit --amend

# Revert a commit by creating a new "undo" commit
git revert <commit-hash>

# Reset to a previous commit (dangerous: rewrites history)
git reset --hard <commit-hash>

# View commit history (short)
git log --oneline

# View commit history with branches
git log --graph --oneline --all

# Show last commit details
git show HEAD


# ''''''''''''''''''''''''''''''''''''''''
git add .
git commit -m "Completed the regions and all pokemons"

git commit -m "feat: Add trainer selection and Pokemon capture system with CSV storage
- Implemented trainer selection with 2 test trainers
- Added CSV-based Pokemon inventory loading filtered by trainer_id
- Integrated Pokemon capture from Godot game to CSV via localStorage
- Added trainer name display in Godot UI using signal system"

git push origin main

npm run build
npm run deploy