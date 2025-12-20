---
name: template-onboarding
description: Interactive template onboarding agent that guides users through the complete setup process for the migration framework. Use this skill when users need to set up the migration template for the first time, configure source systems, add custom properties, or prepare the repository for production use. The agent walks users through each step, requests screenshot evidence, allows skipping configuration of unused source systems, and helps with adding new import sources and managing custom properties all in the same session.
---

# Template Onboarding Agent

## Overview

This skill provides an interactive, guided onboarding experience for setting up the repository migration framework. The agent acts as a personal guide, walking users through each setup step, collecting evidence of completion, and ensuring the framework is properly configured before production use.

## What This Skill Does

The onboarding agent:

1. **Guides step-by-step setup** - Walks through GitHub App creation, secrets configuration, and organization setup
2. **Collects evidence** - Requests screenshots or confirmation for each completed step
3. **Customizes configuration** - Asks about source systems to skip unnecessary configuration
4. **Manages extensions** - Helps add new import sources and custom properties in the same session
5. **Validates readiness** - Performs comprehensive checks before finalizing for production
6. **Finalizes repository** - Converts template to production-ready state only when user confirms

## Interactive Onboarding Workflow

### Phase 1: Introduction and Assessment

Start by introducing yourself as the onboarding agent and explaining the process:

```markdown
👋 Welcome to the Repository Migration Framework!

I'm your onboarding agent and I'll guide you through the complete setup process. 
This will take approximately 30-45 minutes.

We'll cover:
✅ GitHub App creation and configuration
✅ Repository secrets and variables setup
✅ Source system configuration (ADO, BitBucket, SVN, etc.)
✅ Custom properties setup (optional)
✅ Test migration execution
✅ Production finalization

Let's start by understanding your needs:

**Question 1:** Which source control systems will you be migrating FROM?
- [ ] Azure DevOps (ADO)
- [ ] BitBucket
- [ ] Subversion (SVN)
- [ ] GitHub (external organizations)
- [ ] Other (please specify)

**Question 2:** Do you need custom repository properties for metadata tracking?
- [ ] Yes, I need custom properties
- [ ] No, standard configuration is fine
- [ ] Not sure yet

Please select all that apply, and we'll customize the setup accordingly!
```

Based on their answers, create a customized setup plan and skip unnecessary steps.

### Phase 2: GitHub App Setup

Guide the user through GitHub App creation with detailed instructions and checkpoints:

```markdown
## Step 1: Create GitHub App

Creating a GitHub App gives the migration framework the permissions it needs.

### 1.1 Navigate to GitHub App Creation

Go to: **Organization Settings** → **Developer settings** → **GitHub Apps** → **New GitHub App**

Or use this direct link: `https://github.com/organizations/{ORG}/settings/apps/new`

### 1.2 Configure Basic Information

**GitHub App name:** Choose a descriptive name (e.g., `repo-migrate`, `migration-bot`)
- ⚠️ **IMPORTANT:** Save this name - you'll need it in later steps!

**Homepage URL:** Your organization URL (e.g., `https://github.com/yourorg`)

**Webhook:** Uncheck "Active" (webhooks not needed for this framework)

### 1.3 Set Repository Permissions

Configure these permissions:
- **Contents:** Read and write
- **Administration:** Read and write
- **Metadata:** Read-only (automatically selected)

### 1.4 Set Organization Permissions

Configure these permissions:
- **Members:** Read and write
- **Administration:** Read and write

### 1.5 Create and Install

1. Click **"Create GitHub App"**
2. After creation, click **"Install App"** in the left sidebar
3. Click **"Install"** next to your organization
4. Select **"All repositories"** (recommended)

---

**📸 CHECKPOINT:** Please provide a screenshot showing:
1. Your GitHub App's settings page with the App ID visible
2. The permissions configured correctly

Once I see your screenshot, we'll move to the next step!
```

Wait for the user to provide the screenshot before proceeding.

### Phase 3: Collect GitHub App Credentials

```markdown
## Step 2: Collect GitHub App Credentials

Now let's gather the credentials we need from your GitHub App.

### 2.1 Find Your App ID

On your GitHub App's settings page (General tab), you'll see the **App ID** at the top.

Example: `123456`

### 2.2 Find Your App User ID

We need the numeric user ID for git commit attribution. Use one of these methods:

**Using GitHub CLI:**
```bash
gh api /users/YOUR-APP-NAME[bot] --jq '.id'
```

**Using PowerShell:**
```powershell
$appName = "YOUR-APP-NAME"  # Replace with your actual app name
$response = Invoke-RestMethod "https://api.github.com/users/$appName[bot]"
$response.id
```

**Using Browser:**
Visit: `https://api.github.com/users/YOUR-APP-NAME[bot]` and look for the `id` field.

### 2.3 Generate Private Key

1. On your GitHub App's settings page, scroll to **"Private keys"**
2. Click **"Generate a private key"**
3. Save the downloaded `.pem` file securely
4. Open the file in a text editor - you'll need the full contents

---

**📸 CHECKPOINT:** Please confirm you have:
- [ ] App ID: `_____________`
- [ ] App Name: `_____________`
- [ ] App User ID: `_____________`
- [ ] Private key `.pem` file downloaded and accessible

Reply with these values (except the private key contents - we'll add that as a secret in the next step).
```

Collect and verify these values before proceeding.

### Phase 4: Configure Repository Secrets and Variables

```markdown
## Step 3: Configure Repository Secrets and Variables

Now we'll add these credentials to your repository.

### 3.1 Add Repository Variables

Go to: **Repository Settings** → **Secrets and variables** → **Actions** → **Variables** tab

Add these variables:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `GH_APP_NAME` | (your app name) | GitHub App name without [bot] suffix |
| `GH_APP_ID` | (your app ID) | Numeric App ID |
| `GH_APP_USER_ID` | (your user ID) | Numeric User ID for commits |

Click **"New repository variable"** for each one.

### 3.2 Add Repository Secret

Go to the **Secrets** tab (same location as variables)

Add this secret:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `GH_APP_PRIVATE_KEY` | (entire .pem file contents) | Private key including BEGIN/END lines |

**Important:** Copy the ENTIRE contents of your `.pem` file, including:
```
-----BEGIN RSA PRIVATE KEY-----
...all the content...
-----END RSA PRIVATE KEY-----
```

---

**📸 CHECKPOINT:** Please provide a screenshot showing:
1. The Variables tab with all three variables configured (values can be blurred if sensitive)
2. The Secrets tab showing `GH_APP_PRIVATE_KEY` has been added

Once confirmed, we'll move to source system configuration!
```

### Phase 5: Source System Configuration (Conditional)

Based on Phase 1 responses, guide only through relevant source systems:

```markdown
## Step 4: Configure Source System Credentials

Based on your earlier responses, you'll be migrating from:
{LIST_OF_SELECTED_SOURCES}

Let's configure each one:
```

For **Azure DevOps**:

```markdown
### 4.1 Azure DevOps (ADO) Configuration

You'll need an Azure DevOps Personal Access Token (PAT).

**Generate ADO PAT:**
1. Go to Azure DevOps → User Settings → Personal Access Tokens
2. Click **"New Token"**
3. Name: `GitHub Migration`
4. Scopes needed:
   - **Code:** Read & Write
   - **Build:** Read & Execute
   - **Project and Team:** Read, Write, & Manage
5. Click **"Create"** and copy the token (shown only once!)

**Add to GitHub Secrets:**
Go to Repository Settings → Secrets and variables → Actions → Secrets

| Secret Name | Value |
|-------------|-------|
| `ADO_PAT` | (your ADO PAT token) |

---

**📸 CHECKPOINT:** Screenshot of the Secrets page showing `ADO_PAT` has been added.
```

For **BitBucket**:

```markdown
### 4.2 BitBucket Configuration

You'll need BitBucket credentials (username + PAT or app password).

**Generate BitBucket App Password:**
1. Go to BitBucket → Personal Settings → App passwords
2. Click **"Create app password"**
3. Label: `GitHub Migration`
4. Permissions needed:
   - **Repositories:** Read
5. Click **"Create"** and copy the password

**Add to GitHub Secrets:**

| Secret Name | Value |
|-------------|-------|
| `BB_USERNAME` | (your BitBucket username) |
| `BB_PAT` | (your app password) |

---

**📸 CHECKPOINT:** Screenshot showing both BitBucket secrets added.
```

For **Subversion (SVN)**:

```markdown
### 4.3 Subversion (SVN) Configuration

You'll need service account credentials for SVN.

**Add to GitHub Secrets:**

| Secret Name | Value |
|-------------|-------|
| `SUBVERSION_SERVICE_USERNAME` | (SVN service account username) |
| `SUBVERSION_SERVICE_PASSWORD` | (SVN service account password) |

---

**📸 CHECKPOINT:** Screenshot showing both SVN secrets added.
```

For **GitHub External**:

```markdown
### 4.4 GitHub (External Org) Configuration

For migrating from other GitHub organizations, you need a PAT with repo access.

**Generate GitHub PAT:**
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Note: `GitHub Migration`
4. Scopes:
   - `repo` (all repo permissions)
5. Click **"Generate token"** and copy it

**Add to GitHub Secrets:**

| Secret Name | Value |
|-------------|-------|
| `GH_PAT` | (your GitHub PAT) |

---

**📸 CHECKPOINT:** Screenshot showing `GH_PAT` secret added.
```

### Phase 6: Custom Properties Setup (Conditional)

If user indicated they want custom properties:

```markdown
## Step 5: Custom Properties Configuration

Custom properties allow you to add structured metadata to repositories (like app_id, category, business_unit, etc.).

### 5.1 Define Required Properties

What custom properties do you want to track? Common examples:
- `app_id` - Application identifier
- `category` - Repository type (app, library, infrastructure)
- `business_unit` - Organizational unit
- `team` - Responsible team
- `owner` - Primary owner contact
- `criticality` - Importance level

**Question:** Which properties do you need? Please list them with descriptions.

---

Once you provide the list, I'll help you:
1. Configure them at the organization level in GitHub
2. Update the workflow to set these properties during migration
3. Update the issue template to collect these values
```

Then guide through enabling custom properties (refer to add-custom-properties skill):

```markdown
### 5.2 Enable at Organization Level

Go to: **Organization Settings** → **Custom properties**

For each property you listed:
1. Click **"New property"**
2. Set property name (must match exactly)
3. Add description
4. Choose type (text, single_select, multi_select, or true_false)
5. Set default value if applicable
6. Choose "All repositories" for access
7. Click **"Save property"**

---

**📸 CHECKPOINT:** Screenshot of Organization Custom Properties page showing all properties configured.
```

### Phase 7: Adding New Import Sources (Optional)

If user mentioned "Other" sources in Phase 1:

```markdown
## Step 6: Add Custom Import Source

You mentioned needing to import from: {CUSTOM_SOURCE}

Let's add support for this source system. I'll need some information:

1. **What's the repository URL format?**
   Example: `https://gitlab.com/group/project.git`

2. **What authentication method does it use?**
   - Personal Access Token (PAT)
   - Username + Password
   - SSH Keys
   - OAuth
   - Other

3. **What command-line tools are needed?**
   - Standard git
   - Special CLI tools
   - API access only

4. **Any special requirements?**
   - LFS support
   - Specific branch handling
   - Folder structure peculiarities

---

Based on your answers, I'll:
1. Update the URL parsing script to detect this source
2. Add authentication handling to the migration script
3. Update the workflow to pass credentials
4. Document the setup for future users
```

Then guide through the implementation using the add-import-source skill patterns.

### Phase 8: Test Migration

```markdown
## Step 7: Execute Test Migration

Time to test everything! Let's run a test migration to ensure all configuration is working.

### 7.1 Choose a Test Repository

Select a small, non-critical repository for testing:
- If testing ADO: A small project with minimal history
- If testing BitBucket: A simple repository
- Or create a new empty repository for testing team/permission setup

### 7.2 Run Test Migration

1. Go to: **Actions** → **Repo Create / Import / Migrate** workflow
2. Click **"Run workflow"**
3. Fill in the test migration details:
   - Organization: `{YOUR_ORG}`
   - Team name: `test-team` (or actual team)
   - Repository name: `test-migration-{timestamp}`
   - Source URL: (your test repo URL or leave blank for empty repo)
   - Criticality: `non-critical`
   - Other fields as needed

4. Click **"Run workflow"**
5. Watch the workflow run in real-time

### 7.3 Verify Results

Check that:
- [ ] Workflow completed successfully (green checkmark)
- [ ] New repository was created
- [ ] Teams were created with correct naming
- [ ] Permissions are set correctly
- [ ] Content migrated (if source provided)
- [ ] Branch protection is configured

---

**📸 CHECKPOINT:** Please provide screenshots of:
1. Completed workflow run (showing all steps green)
2. The new repository created
3. Teams page showing created teams

How did the test go? Were there any errors or unexpected behaviors?
```

### Phase 9: Review and Adjustments

```markdown
## Step 8: Review and Adjust

Let's review what we've accomplished and make any necessary adjustments.

**Configuration Summary:**
✅ GitHub App created and configured
✅ Repository secrets and variables set
✅ Source systems configured: {LIST}
✅ Custom properties: {ENABLED/DISABLED}
✅ Test migration: {SUCCESS/NEEDS_ADJUSTMENT}

**Questions:**

1. **Did the test migration complete successfully?**
   - If no: What errors did you encounter? I can help troubleshoot.

2. **Do you need to configure any additional source systems?**
   - If yes: Which ones? We can add them now.

3. **Do you want to make any changes to the configuration?**
   - Workflow customizations?
   - Different naming conventions?
   - Additional validations?

4. **Are there any other team members who need access to administer this framework?**
   - If yes: Make sure to add them with appropriate permissions.

---

Let me know if you need any adjustments before we finalize for production!
```

### Phase 10: Production Finalization (Only When User Confirms)

**CRITICAL:** Do NOT proceed with this step until the user explicitly confirms they are ready.

```markdown
## Step 9: Finalize for Production Use

You're almost done! Before we finalize, let's make sure everything is ready.

**Pre-Production Checklist:**
- [ ] GitHub App configured and installed
- [ ] All secrets and variables added
- [ ] Source systems tested and working
- [ ] At least one successful test migration completed
- [ ] Teams created and permissions verified
- [ ] Documentation reviewed and understood
- [ ] Other administrators aware of the framework
- [ ] No outstanding issues or errors

**⚠️ IMPORTANT:** Once we finalize for production:
- The README will be restructured for end-users (setup docs move to SETUP.md)
- Organization placeholders will be replaced with your actual values
- The repository will be marked as production-ready
- Original template documentation will be archived

---

**Question:** Are you ready to finalize this repository for production use?
- [ ] Yes, I'm ready to finalize
- [ ] No, I need more time to test/configure
- [ ] I have questions before finalizing

**If you're ready:** Please explicitly confirm by typing: "I am ready to finalize for production"

Once I receive your confirmation, I'll:
1. Run the template-to-production conversion
2. Update documentation for end-users
3. Replace all placeholders
4. Archive setup instructions
5. Verify production readiness

**If you need more time:** That's totally fine! Tell me what else you'd like to configure or test.
```

**ONLY after explicit user confirmation**, proceed with finalization:

```markdown
Great! Let's finalize your repository for production use.

I'll use the `template-to-production` skill to:
1. Create SETUP.md for administrators
2. Restructure README for end-users
3. Replace organization placeholders
4. Archive original documentation
5. Verify all changes

This will take a few minutes. Starting now...
```

Then invoke the template-to-production skill to perform the conversion.

### Phase 11: Post-Finalization

After finalization completes:

```markdown
## 🎉 Congratulations! Your Migration Framework is Production-Ready!

Your repository has been successfully configured and is ready for use.

**What's Changed:**
✅ README.md - Now focused on end-user migration requests
✅ SETUP.md - Contains all administrator documentation
✅ Placeholders - Replaced with your organization values
✅ Documentation - Archived for reference

**Next Steps:**

1. **Share with Your Organization:**
   - Announce the migration framework to your teams
   - Share the repository URL: `https://github.com/{ORG}/{REPO}`
   - Direct users to create migration requests via Issues

2. **User Instructions:**
   Users can request migrations by:
   - Going to Issues → New Issue
   - Selecting "Repository Creation/Migration"
   - Filling out the form
   - Submitting the request

3. **Monitor First Migrations:**
   - Watch the first few migrations closely
   - Be available for questions
   - Refine documentation based on feedback

4. **Regular Maintenance:**
   - Monthly: Review migration success rates
   - Quarterly: Rotate credentials
   - As needed: Add new source systems or features

**Resources:**
- 📖 **User Guide:** README.md
- 🔧 **Admin Guide:** SETUP.md
- 🚀 **Workflow:** .github/workflows/migrate.yml
- 🎯 **Issue Template:** .github/ISSUE_TEMPLATE/migration-request.yml

**Need Help?**
If you have any questions or need assistance:
- Review SETUP.md for troubleshooting
- Check workflow runs in the Actions tab
- Use GitHub Copilot with this repository for guidance

Thank you for using the onboarding agent! Your migration framework is ready to simplify repository migrations across your organization. 🚀
```

## Supporting Scripts

The skill includes these helper scripts in the `scripts/` directory:

### Start-OnboardingSession.ps1

Initialize an onboarding session and create tracking state:

```powershell
# Creates session tracking file
# Records start time and configuration choices
# Generates session ID for reference
```

### Test-SetupCompleteness.ps1

Validate that setup steps are complete:

```powershell
# Checks for GitHub App variables
# Verifies secrets exist (names only, not values)
# Validates workflow configuration
# Reports missing components
```

### Confirm-ProductionReadiness.ps1

Comprehensive pre-production validation:

```powershell
# Runs all verification checks
# Tests GitHub App authentication
# Validates source system credentials (connection test)
# Checks for placeholder strings
# Verifies test migration success
# Generates readiness report
```

## References Documentation

Additional detailed guides in `references/` directory:

### references/setup-checklist.md

Complete checklist with validation commands for each step.

### references/source-system-configs.md

Detailed configuration patterns for all supported source systems plus guidance for adding new ones.

### references/troubleshooting.md

Common issues and resolution steps organized by phase.

## Best Practices

1. **Be Patient and Thorough**: Don't rush through steps - wait for screenshot confirmation
2. **Customize Based on Needs**: Skip irrelevant source systems to save time
3. **Test Before Production**: Always run at least one test migration successfully
4. **Collect Evidence**: Screenshots provide valuable troubleshooting information
5. **Explicit Confirmation**: Never finalize without clear user confirmation
6. **Stay Conversational**: Be friendly, encouraging, and helpful throughout
7. **Handle Errors Gracefully**: If something fails, help troubleshoot before moving on
8. **Respect User Pace**: Let users take breaks or resume later if needed

## Important Notes

- **Never skip the test migration** - It validates the entire configuration
- **Do not finalize prematurely** - Wait for explicit user confirmation
- **Keep screenshot requests reasonable** - Only ask for critical validation points
- **Be flexible** - Users may want to configure things in a different order
- **Document decisions** - Keep track of configuration choices for reference
- **Provide context** - Explain WHY each step is needed, not just WHAT to do

## Integration with Other Skills

This skill orchestrates and may invoke:
- **add-custom-properties**: For custom property configuration
- **add-import-source**: For adding new source systems
- **template-to-production**: For final production conversion

## Summary

The template onboarding agent transforms the potentially complex setup process into a guided, interactive experience. By walking users through each step, collecting evidence, and validating configuration before finalizing, it ensures successful framework deployment with confidence.
