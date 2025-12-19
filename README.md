# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)

Automate repository migrations from Azure DevOps, BitBucket, SVN, or GitHub into your organization.

---

## Setup Instructions

### Step 1: Create Your Repository from This Template

**Click here to create:** [Use this template](../../generate)

Or manually:
1. Click the green **"Use this template"** button at the top of this page
2. Choose your organization
3. Name your repository (e.g., `repo-migration`)
4. Set visibility to **Private** or **Internal**
5. Click **"Create repository"**
6. Clone your new repository locally

---

### Step 2: Create a GitHub App

Your organization needs a GitHub App for authentication and permissions.

**Create the App:**

1. Go to: **Organization Settings** → **Developer settings** → **GitHub Apps** → [**New GitHub App**](../../settings/apps/new)

2. **Basic Information:**
   - **GitHub App name:** Choose a name (e.g., `repo-migrate`, `migration-bot`)
     - ⚠️ **SAVE THIS NAME** - you'll need it later
   - **Homepage URL:** Your organization URL
   - **Webhook:** Uncheck "Active" (not needed)

3. **Repository Permissions** (Required):
   ```
   Contents:        Read and write
   Administration:  Read and write
   Metadata:        Read-only (automatic)
   ```

4. **Organization Permissions** (Required):
   ```
   Members:         Read and write
   Administration:  Read and write
   ```

5. Click **"Create GitHub App"**

**After Creation:**

1. **Note your App ID** (shown at top of General tab)
2. **Generate Private Key:**
   - Scroll to "Private keys" section
   - Click **"Generate a private key"**
   - Save the downloaded `.pem` file securely
3. **Install the App:**
   - Click **"Install App"** in left sidebar
   - Click **"Install"** next to your organization
   - Select **"All repositories"** (recommended)

---

### Step 3: Get Your App User ID

You need the full numeric user ID for git commit attribution.

**Using GitHub CLI:**
```bash
gh api /users/YOUR-APP-NAME[bot] --jq '.id'
```
Example: `gh api /users/repo-migrate[bot] --jq '.id'` returns `123456789`

**Using PowerShell:**
```powershell
$appName = "YOUR-APP-NAME"  # Use the name you saved in Step 2
$response = Invoke-RestMethod "https://api.github.com/users/$appName[bot]"
$response.id  # This is your App User ID
```

**Save both:**
- App Name: `YOUR-APP-NAME`
- App User ID: `123456789` (example)

---

### Step 4: Update Configuration with GitHub Copilot

Open your repository in VS Code and use **GitHub Copilot Coding Agent** to configure everything in one step.

**Ask Copilot:**
```
Use the update-app-name skill to update all references with:

App Name: YOUR-APP-NAME
App ID: YOUR-APP-USER-ID

Use the update-default-org skill to update all references with:

Organization: YOUR-ORG-NAME
```

Replace `YOUR-APP-NAME`, `YOUR-APP-USER-ID`, and `YOUR-ORG-NAME` with your actual values. Copilot will update all workflow files, scripts, and documentation automatically in a single pull request.

---

### Step 5: Configure Secrets

Go to: **Repository Settings** → **Secrets and variables** → **Actions**

#### Required (All Migrations):

**Secrets:**
| Name | Value | Where to get it |
|------|-------|-----------------|
| `GH_APP_PRIVATE_KEY` | Full contents of `.pem` file | From Step 2 |

**Variables:**
| Name | Value | Where to get it |
|------|-------|-----------------|
| `GH_APP_ID` | App ID number | From Step 2 |

#### Optional (Configure for sources you'll use):

<details>
<summary><b>Azure DevOps</b></summary>

**Secrets:**
- `ADO_PAT` - [Create Personal Access Token](https://learn.microsoft.com/azure-devops/organizations/accounts/use-personal-access-tokens-to-authenticate) with **Code (Read)** scope

</details>

<details>
<summary><b>BitBucket</b></summary>

**Secrets:**
- `BB_USERNAME` - Your BitBucket username
- `BB_PAT` - [Create App Password](https://support.atlassian.com/bitbucket-cloud/docs/app-passwords/) with **Repository Read**

**Variables:**
- `BITBUCKET_BASE_URL` - Your BitBucket domain (e.g., `bitbucket.company.com`)

</details>

<details>
<summary><b>Subversion (SVN)</b></summary>

**Secrets:**
- `SUBVERSION_SERVICE_PASSWORD` - Your SVN password

**Variables:**
- `SUBVERSION_SERVICE_USERNAME` - Your SVN username
- `SVN_BASE_URL` - Your SVN domain (e.g., `svn.company.com`)

</details>

<details>
<summary><b>External GitHub</b></summary>

**Secrets:**
- `GH_PAT` - [Create Personal Access Token](https://github.com/settings/tokens) with **repo** scope

</details>

---

## ✅ You're Done! Start Migrating

### Create a Migration Request:

1. Go to **[Issues](../../issues)** → **[New Issue](../../issues/new/choose)**
2. Select **"🏃‍♂️ Repository Creation/Migration"**
3. Fill in:
   - **Organization:** Your org name
   - **Team Name:** Your team (e.g., `platform-team`)
   - **Repository Name:** New repo name (e.g., `user-api`)
   - **Source URL:** (Optional) Repository to migrate from
   - **Criticality:** `critical` (private) or `non-critical` (internal)
4. **Submit** and watch it work!

The workflow creates the repository, migrates code, sets up teams, and configures permissions automatically.

---

## Additional Configuration

### Custom Properties

Add custom repository properties (like app IDs, cost centers, etc.) using GitHub Copilot Coding Agent:

```
Use the add-custom-properties skill to add app_id property
```

See [Custom Properties Guide](.github/skills/add-custom-properties/SKILL.md)

### Add New Source Systems

Support additional source control systems using GitHub Copilot Coding Agent:

```
Use the add-import-source skill to add GitLab support
```

See [Add Import Source Guide](.github/skills/add-import-source/SKILL.md)

### All Available Skills:

- **[update-readme-repo](.github/skills/update-readme-repo/SKILL.md)** - Fix workflow status badge
- **[update-app-name](.github/skills/update-app-name/SKILL.md)** - Update GitHub App references
- **[update-default-org](.github/skills/update-default-org/SKILL.md)** - Update organization references  
- **[add-custom-properties](.github/skills/add-custom-properties/SKILL.md)** - Add repository metadata
- **[add-import-source](.github/skills/add-import-source/SKILL.md)** - Support new source systems

---

## Troubleshooting

**Authentication fails:**
- Check `GH_APP_ID` variable is correct
- Verify `GH_APP_PRIVATE_KEY` includes `-----BEGIN RSA PRIVATE KEY-----` headers
- Confirm GitHub App is installed on your organization

**Permission errors:**
- Review app permissions in Organization Settings → Developer settings → GitHub Apps
- Ensure app has Contents (write) and Administration (write)

**Source migration fails:**
- Verify correct secrets are configured for your source (ADO_PAT, BB_PAT, etc.)
- Check source URL format matches examples
- Ensure base URL variables are set (BITBUCKET_BASE_URL, SVN_BASE_URL)

---

## Support

- 📖 **Skills Documentation:** [`.github/skills/`](.github/skills/)
- 💬 **GitHub Copilot Coding Agent:** Ask Copilot to help with configuration and customization
- 🐛 **Issues:** [Report issues](../../issues/new)

---

**Questions?** Contact your organization's administrators or open an issue.