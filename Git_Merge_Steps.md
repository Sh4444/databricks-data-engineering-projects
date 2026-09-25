# Git Merge Steps in Databricks

This notebook documents the steps to merge branches and push changes in Databricks Git folders (Repos).

There are **three approaches** available depending on your setup.

---

## Option 1: Git CLI (Requires Attached Compute)

This is the **fastest and most reliable** approach when compute is available.

### Steps

1. **Check current status** — see what branch you're on and if there are uncommitted changes:
   ```sh
   git status
   ```

2. **Checkout the target branch** (e.g., `dev`):
   ```sh
   git checkout dev
   ```

3. **Pull the latest** to sync with remote:
   ```sh
   git pull origin dev
   ```

4. **Merge the source branch** (e.g., your feature branch):
   ```sh
   git merge payroll-employee-nyc-add-folder
   ```

5. **Push to remote**:
   ```sh
   git push origin dev
   ```

### If Merge Conflicts Occur

1. Open the conflicted file and edit it manually to resolve the conflict.
2. Stage the resolved file:
   ```sh
   git add <file-path>
   ```
3. Complete the merge commit:
   ```sh
   git commit
   ```
4. Push to remote:
   ```sh
   git push origin dev
   ```

5. If you want to **abort** the merge and start over:
   ```sh
   git merge --abort
   ```

---

## Option 2: Databricks Repos UI (No Compute Needed)

Use this when no compute is attached or you prefer a visual interface.

### Steps

1. Navigate to **Workspace → Repos → your repository**.
2. Click the **branch dropdown** at the top and switch to the **target branch** (e.g., `dev`).
3. Click the **three-dot menu (⋮)** in the top-right corner.
4. Select **Merge**.
5. Choose the **source branch** to merge from (e.g., `payroll-employee-nyc-add-folder`).
6. Review the changes shown in the dialog.
7. Click **Confirm** to complete the merge.
8. If prompted, **Push** the changes to the remote.

### Resolving Conflicts in the UI

1. When a conflict is detected, the Repos UI opens a **conflict resolution modal**.
2. For each conflicted file, choose **Ours** (keep target branch version) or **Theirs** (keep source branch version).
3. Click **Resolve** and then **Complete Merge**.
4. Push the changes to remote.

> **Tip:** You can open the Git modal directly with:
> `https://<databricks-domain>/browse?o=<workspaceId>&openGit=<git-folder-id>`

---

## Option 3: Pull Request on Git Provider (GitHub/GitLab/Bitbucket)

This is the **best practice for code review** before merging.

### Steps

1. **Push your feature branch** to the remote:
   ```sh
   git push origin payroll-employee-nyc-add-folder
   ```

2. Go to your **Git provider** (GitHub, GitLab, Bitbucket, etc.).

3. Open a **Pull Request (PR)** from your feature branch → target branch (`dev`).

4. **Review** the changes, add reviewers, and discuss if needed.

5. Click **Merge** on the Git provider to merge the PR.

6. Back in Databricks:
   - Switch to the `dev` branch
   - **Pull** the latest changes:
     ```sh
     git checkout dev
     git pull origin dev
     ```

> **Note:** This approach is recommended for team collaboration as it provides a review trail.

---

## Best Practices

| Tip | Description |
| --- | --- |
| **Check status first** | Always run `git status` before merging to ensure a clean working tree |
| **Pull before merge** | Pull the latest on the target branch to avoid unnecessary conflicts |
| **Write meaningful commit messages** | Describe what changed and why, not just "updated files" |
| **Use PRs for team collaboration** | Pull requests provide code review and audit trail |
| **Resolve conflicts carefully** | Review each conflict before choosing ours/theirs |
| **Use feature branches** | Keep `dev` and `main` clean by working on feature branches |

## Quick Reference Commands

```sh
# Check status
git status

# Switch branch
git checkout <branch-name>

# Pull latest
git pull origin <branch-name>

# Merge a branch
git merge <source-branch>

# Push to remote
git push origin <branch-name>

# Abort a merge
git merge --abort

# View commit log
git log --oneline

# List all branches
git branch -a
```

---

## Merging `dev` to `main` via GitHub Pull Request

This section covers the full workflow for merging your `dev` branch into `main` using a GitHub Pull Request, then syncing back to Databricks.

### Step 1: Ensure `dev` is Pushed to Remote

```sh
# Make sure you're on the dev branch
git checkout dev

# Push latest dev changes to GitHub
git push origin dev
```

### Step 2: Create a Pull Request on GitHub

1. Go to your repository on GitHub:
   `https://github.com/Sh4444/databricks-data-engineering-projects`
2. Click **Pull requests** → **New pull request**
3. Set the branch comparison:
   - **base**: `main`
   - **compare**: `dev`
4. Review the files and changes shown
5. Add a **title** (e.g., `Merge dev into main`) and **description**
6. Click **Create pull request**

### Step 3: Review & Resolve Conflicts (If Any)

1. If there are merge conflicts, GitHub will show a warning.
2. Click **Resolve conflicts**.
3. Edit the conflicted files directly in GitHub's web editor.
4. Choose which changes to keep by removing the conflict markers:
   ```
   <<<<<<< main
   (main branch changes)
   =======
   (dev branch changes)
   >>>>>>> dev
   ```
5. Click **Mark as resolved** for each file.
6. Click **Commit merge**.

### Step 4: Merge the Pull Request

1. Once conflicts are resolved (or if there are none), click **Merge pull request**.
2. Choose the merge method:
   - **Create a merge commit** — preserves full history (recommended)
   - **Squash and merge** — combines all commits into one
   - **Rebase and merge** — applies commits without a merge commit
3. Click **Confirm merge**.
4. Optionally delete the `dev` branch if no longer needed.

### Step 5: Sync `main` in Databricks Repos

Back in Databricks, pull the latest `main` to sync your local repo:

```sh
# Switch to main branch
git checkout main

# Pull latest changes from GitHub
git pull origin main
```

### Quick Summary

| Step | Action | Where |
| --- | --- | --- |
| 1 | Push `dev` to remote | Databricks Git CLI or UI |
| 2 | Create Pull Request (`dev` → `main`) | GitHub |
| 3 | Resolve conflicts (if any) | GitHub web editor |
| 4 | Merge the Pull Request | GitHub |
| 5 | Pull `main` to sync | Databricks Git CLI or UI |

> **Tip:** Always verify that the `main` branch is up to date in Databricks after merging on GitHub to avoid working with stale code.
