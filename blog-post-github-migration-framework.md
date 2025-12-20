# Lessons from 500+ GitHub Migrations

## Introduction

After migrating 500+ repositories from Azure DevOps, BitBucket, SVN, and other systems to GitHub, we ran into pretty much every migration challenge imaginable. We built an [automated framework](https://github.com/htekdev/gh-repo-migration-iops-template) to solve these problems and open-sourced it so others facing enterprise GitHub migrations can benefit from our learnings.

This post shares the challenges we encountered, how we addressed them, and how GitHub Copilot helped us make the framework maintainable through skills-based configuration.

---

## The Challenges We Encountered

### 1. **Large Files Without LFS**

**Problem:** Repositories contain large files (>100MB) that aren't tracked by LFS. GitHub rejects pushes, blocking the entire migration.

**How we solved it:** Detect large files before pushing, automatically configure Git LFS tracking for them, and convert existing files to LFS storage.

### 2. **Branch Naming Chaos**

**Problem:** Different systems use `main`, `master`, or `trunk`. Pipelines break, protected branches fail.

**How we solved it:** Detect the source repository's default branch and preserve it during migration instead of assuming `main` or `master`.

### 3. **Lost History & Metadata**

**Problem:** Commit authors become "migration-bot," timestamps vanish, branches flatten.

**How we solved it:** Use git clone (not migration APIs) to preserve full history with original authors, timestamps, all branches, tags, and merge topology.

### 4. **Secret Scanning Roadblocks**

**Problem:** Historical secrets block entire migrations, requiring hours of manual remediation.

**How we solved it:** Temporarily disable secret scanning push protection during migration, then re-enable it immediately after. This allows teams to remediate secrets post-migration without blocking the process.

**Room for improvement:** Our current approach relies on teams revoking any exposed secrets after migration, which worked at our scale. A better solution could use pre-commit scanning to detect secrets, mask them, and export findings to a secure location for the issue initiator to address—but we found post-migration revocation more practical for our needs.

### 5. **SVN to Git Translation**

**Problem:** SVN's `trunk/branches/tags` structure doesn't map cleanly to Git refs.

**How we solved it:** Use `git-svn` with automatic layout detection to convert `trunk/branches/tags` structure to Git conventions.

### 6. **Permission Chaos**

**Problem:** Teams lose access, wrong permissions assigned, visibility misconfigured.

**How we solved it:** Create hierarchical teams (parent/owner/admin) automatically, validate requestor's team membership before allowing migration, and set repository visibility based on criticality level.

### 7. **Monorepo Decomposition**

**Problem:** Extracting one folder from a monorepo loses history or requires manual `git-filter-repo` surgery.

**How we solved it:** Add `only-folder` parameter that uses git filtering to migrate specific paths while preserving relevant commit history.

### 8. **Integration Breakage**

**Problem:** CI/CD pipelines, Azure Boards, webhooks—everything points to the old repo.

**How we solved it:** For Azure DevOps migrations, automatically rewire pipelines to point to GitHub, configure board integration, and lock the source repository to read-only.

---

## Our Approach: Issue-Driven Automation

We built the framework on GitHub Actions and PowerShell with a simple workflow:

1. Create a GitHub issue with migration parameters (org, team, repo name, source URL)
2. Workflow validates team membership and naming conventions
3. Creates repository, migrates code with full history
4. Sets up team hierarchy and permissions
5. Rewires pipelines and integrations (for ADO sources)
6. Comments on issue with success or failure details

**What we learned:**
Automation made a huge difference—migrations went from 4-8 hours with manual steps to 10-15 minutes with one issue creation. Success rate improved from ~60% to ~95% as we ironed out edge cases.

---

## Making It Maintainable with GitHub Copilot

One challenge with enterprise frameworks is keeping them maintainable as requirements change. We use GitHub Copilot to help with this:

### Skills-Based Configuration
We created `.github/skills/` with instructions for common customization tasks. For example:

```
Use the template-to-production skill to finalize the repository for production use
```

Copilot can scan the entire repo and automate conversion tasks. We have skills for:
- **add-import-source**: Add support for new source control systems (GitLab, etc.)
- **add-custom-properties**: Add repository metadata requirements
- **template-to-production**: Convert template to production-ready repository

### Development Acceleration
Copilot has helped us:
- Add new source system support (BitBucket, SVN) much faster
- Refactor complex PowerShell functions with proper error handling
- Generate troubleshooting documentation from workflow files
- Onboard new contributors by answering questions about the codebase

This approach makes the framework easier for others to customize for their specific needs.

---

## What Still Needs Work

We're being honest—this framework isn't perfect. Here are areas we know could be better:

**Secret Handling:** Our current approach temporarily disables secret scanning and lets teams handle revocation after migration. We've considered building proactive secret detection using pre-commit scanning, masking secrets in history, and providing teams a secure report to address findings before migration completes. For our scale, post-migration revocation was more practical, but organizations with stricter compliance requirements might need the more sophisticated approach.

**Better Pre-Migration Validation:** We could add repository health checks before migration starts—detecting potential issues like LFS files, large binaries, or malformed branch names and reporting them upfront.

**Post-Migration Verification:** Automated comparison of source vs. migrated repositories (commit counts, file checksums, branch structures) would catch edge cases we might miss.

If you implement improvements in these areas, we'd love to see your approach!

---

## Try It Out

The framework is open source and still evolving. If you're facing enterprise GitHub migrations, give it a try:

**Repository:** [github.com/htekdev/gh-repo-migration-iops-template](https://github.com/htekdev/gh-repo-migration-iops-template)

### Quick Start

1. Use the repository template to create your own instance
2. Configure GitHub App authentication (see README)
3. Set up secrets for your source systems (ADO, BitBucket, etc.)
4. Create an issue using the migration request template

### We'd Love Your Feedback

This framework solves our specific challenges, but every organization's needs are different:

- **Found a bug?** Open an issue
- **Have a feature request?** Let us know
- **Added support for a new source system?** Submit a PR
- **Customized it for your org?** Share what worked

The Copilot skills in `.github/skills/` make it easier to customize—you can add new source systems, custom properties, or validation rules by describing what you need.

## Key Lessons

1. **Large-scale migrations have hidden complexity** - Test thoroughly with a pilot repo
2. **Automation is worth the investment** - Manual migrations don't scale
3. **Plan permissions carefully** - Team structure mistakes are hard to fix later
4. **Document your edge cases** - They'll come up again
5. **Open source helps everyone** - Share solutions, learn from others

---

**Questions or war stories?** Open an issue in the framework repository. We'd love to hear how it works (or doesn't work) for your migrations!
