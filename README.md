# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/htekconsulting/gh-repo-migration-iops-template/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/htekconsulting/gh-repo-migration-iops-template/actions/workflows/migrate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-Required-green.svg)](https://cli.github.com/)

Automated repository migration framework for **htekconsulting**. Migrate repositories from Azure DevOps with complete automation.

---

## Quick Start

### Request a Repository Migration

1. Go to **[Issues](../../issues)** → **[New Issue](../../issues/new/choose)**
2. Select **"🏃‍♂️ Repository Creation/Migration"**
3. Fill in the form:
   - **Organization:** `htekconsulting`
   - **Team Name:** Your team identifier (e.g., `platform-team`)
   - **Repository Name:** New repository name
   - **Source URL:** (Optional) Azure DevOps repository to migrate from
   - **Criticality:** `critical` (private) or `non-critical` (internal)
4. Submit and track progress

The migration runs automatically and completes in minutes.

---

## Supported Source Systems

| Source | URL Format | Authentication |
|--------|------------|----------------|
| **Azure DevOps** | `https://dev.azure.com/{org}/{project}/_git/{repo}` | PAT configured |
| **GitHub (Internal)** | `https://github.com/htekconsulting/{repo}` | No extra auth needed |

---

## What Gets Created

Every migration automatically:

✅ Creates new GitHub repository with standardized naming  
✅ Migrates complete git history (when source provided)  
✅ Creates team hierarchy with proper permissions  
✅ Configures repository visibility based on criticality  
✅ Sets up branch protection rules  
✅ Integrates with Azure DevOps boards (for ADO sources)

---

## Migration Options

### Full Repository Migration
Migrate an entire repository with complete history:
- Leave "Only Include Specific Folder" blank
- All branches and tags are migrated

### Partial Migration (Folder Only)
Extract a single folder from a larger repository:
- Set "Only Include Specific Folder" to folder path (e.g., `backend/api`)
- Only that folder's history is preserved
- Useful for monorepo splitting

### New Repository Only
Create an empty repository without migration:
- Leave "Source Repository URL" blank
- Repository created with README.md only

---

## Team Structure

Each repository gets a two-tier team structure:

```
{team-name}                    → Maintain permissions
└── {team-name}-admins        → Admin permissions
```

**Permissions by Criticality:**
- **Critical repos:** Private, restricted team access
- **Non-critical repos:** Internal, standard team access

---

## Troubleshooting

### Migration Fails

**Check workflow run:**
1. Go to [Actions](../../actions/workflows/migrate.yml)
2. Click the failed run
3. Review job summary for specific error

**Common issues:**
- Source URL format incorrect
- Authentication not configured for source system
- Team name doesn't follow naming conventions
- Repository name already exists

### Need Help?

- 📖 **View workflow runs:** [Actions page](../../actions)
- 🐛 **Report issues:** [Create issue](../../issues/new)
- 💬 **Contact:** htekconsulting platform team
- 📚 **Setup documentation:** [SETUP.md](SETUP.md) (for admins)

---

## Administration

Repository administrators can find setup and configuration documentation in [SETUP.md](SETUP.md).

**Admin tasks:**
- Adding new source systems
- Updating secrets and credentials  
- Modifying team naming conventions
- Customizing repository properties
- Troubleshooting authentication

---

## Support

**For migration requests:** Use the issue template  
**For technical issues:** Contact platform team  
**For setup changes:** See [SETUP.md](SETUP.md)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Security

See [SECURITY.md](SECURITY.md) for security policies and reporting vulnerabilities.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
