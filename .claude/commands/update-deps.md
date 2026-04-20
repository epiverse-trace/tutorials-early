# Monthly Dependency Update Workflow

## How to use this command

Run `/update-deps` in Claude Code (this repo's session) after GitHub Actions has created an `update/packages` PR. Check [the PRs tab](https://github.com/epiverse-trace/tutorials-early/pulls) first — if no open PR exists, the command will stop and tell you.

**Responsibility split:**
- Claude automates: git branch setup, RcppParallel lockfile fix, `renv::restore()`, `renv::status()`
- You do manually: `sandpaper::build_lesson()` in RStudio + visual review in browser
- Claude finalises: commits any lockfile changes only after you reply `ok to commit`

---

You are helping maintain the `epiverse-trace/tutorials-early` Carpentries sandpaper lesson by processing the monthly `update/packages` PR created by the GitHub Actions bot.

Work through the following phases in order. At each HANDOFF POINT, stop and wait for the user before proceeding.

---

## Phase 0 — Preflight checks

1. Confirm the working directory is the repo root by checking that `config.yaml` and `renv/` both exist.

2. Detect the Rscript executable:
   - Run `Get-Command Rscript -ErrorAction SilentlyContinue` in PowerShell.
   - If not found, list `C:\Program Files\R\` and use the highest-versioned subdirectory's `bin\Rscript.exe`.
   - Store this path — use it for every R call below.

3. Check for an open `update/packages` PR:
   ```
   gh pr list --head update/packages --state open
   ```
   - If no open PR is found: report "No open update/packages PR found. The GitHub Actions workflow may not have run yet this month, or the PR was already merged." Then stop.
   - If an open PR exists: display its title, PR number, and URL.

---

## Phase 1 — Git branch setup

Run each step and show the output:

**1.1** Pull latest main:
```
git checkout main
git pull origin main
```

**1.2** Delete the local `update/packages` branch if it exists (soft-fail if absent):
```
git branch -D update/packages
```

**1.3** Fetch and check out the remote branch:
```
git fetch origin update/packages
git checkout update/packages
```

**1.4** Show the recent commit log:
```
git log --oneline -5
```

Report: "Branch is ready. Confirm the top commit is an `[actions]` commit by `epiverse-trace-bot`."

---

## Phase 2 — RcppParallel fix (conditional)

RcppParallel is absent from the current lockfile but can appear after `renv::update()` runs on CI. When present with `Repository: "CRAN"`, CI fails on Ubuntu runners — fix is to set it to `"RSPM"`.

**2.1** Check for RcppParallel in the lockfile using PowerShell:
```powershell
$lock = Get-Content "renv/profiles/lesson-requirements/renv.lock" -Raw | ConvertFrom-Json
if ($lock.Packages.PSObject.Properties.Name -contains "RcppParallel") {
    $pkg = $lock.Packages.RcppParallel
    Write-Host "RcppParallel found. Version: $($pkg.Version), Repository: $($pkg.Repository)"
} else {
    Write-Host "RcppParallel NOT in lockfile — no fix needed."
}
```

**2.2** If RcppParallel is present AND `Repository` is `"CRAN"`, apply a targeted fix using regex replacement (avoid full JSON rewrite to prevent reformatting the 6000-line file):

Use the Read tool to get the lockfile content, find the RcppParallel block, and use the Edit tool to change `"Repository": "CRAN"` to `"Repository": "RSPM"` within that block only.

After editing, validate the JSON is still parseable:
```powershell
Get-Content "renv/profiles/lesson-requirements/renv.lock" -Raw | ConvertFrom-Json | Out-Null
Write-Host "JSON validation passed."
```

If validation fails: run `git checkout -- renv/profiles/lesson-requirements/renv.lock` and report the failure. Do not proceed.

If RcppParallel is absent or already has `"RSPM"`: report "No RcppParallel fix needed." and continue.

---

## Phase 3 — Restore packages with renv

Run restore non-interactively (`prompt=FALSE` is the equivalent of choosing "option 2: use current library paths" from the interactive prompt):

```
<Rscript> -e "renv::restore(lockfile='renv/profiles/lesson-requirements/renv.lock', prompt=FALSE)"
```

Replace `<Rscript>` with the path detected in Phase 0. This may take several minutes — show all output.

Then run a status check:
```
<Rscript> -e "renv::status(lockfile='renv/profiles/lesson-requirements/renv.lock')"
```

If status reports any issues (missing or out-of-sync packages): show the output verbatim and stop. Do not continue until the user resolves the issue.

---

## Phase 4 — HANDOFF POINT (user manual step required)

Show a summary:
- RcppParallel fix applied: yes / no
- renv restore: completed / issues found
- `git diff --stat` output

Then tell the user:

---

**ACTION REQUIRED — open RStudio and run:**

```r
sandpaper::build_lesson()
```

Review the rendered lesson in your browser. Check for:
- Unexpected changes in code output or figures
- Console errors or warnings
- Broken episode links or missing content

When done, reply one of:
- `ok to commit` — build looks good, proceed with committing any lockfile changes
- `skip commit` — no lockfile changes were made (RcppParallel fix was not needed)

---

## Phase 5 — Commit and push (after user confirmation)

**If user replies `ok to commit`:**

Show `git status` first. If the lockfile was modified:
```
git add renv/profiles/lesson-requirements/renv.lock
git commit -m "fix: change RcppParallel source from CRAN to RSPM in lockfile"
git push origin update/packages
```

If no lockfile changes exist: report "No lockfile changes to commit. The branch is ready for PR review as-is."

**If user replies `skip commit`:** skip the commit step.

**Final step** — open the PR in the browser:
```
gh pr view --web
```

Report:
"The automated steps are complete. Next steps:
1. Wait for CI checks to pass (the pr-receive workflow will post a comment showing output diffs).
2. Review the CI comment for unexpected content changes.
3. If CI passes and output looks good, approve and merge the PR on GitHub."
