# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default tseslint.config([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      ...tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      ...tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      ...tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default tseslint.config([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

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
git commit -m "Add Pokemon game layout"
git push origin main

npm run build
npm run deploy