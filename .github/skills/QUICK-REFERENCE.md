# Quick Reference: Agent Skills

## 🎯 Fast Access Guide

### Custom Properties Skill

**Ask Copilot:**
- "Enable custom properties in migration"
- "Add custom property for [property-name]"
- "Fix custom properties not showing"
- "How to validate custom properties"

**What you'll get:**
- Workflow configuration steps
- Script modification guidance  
- Property validation code
- Troubleshooting help

**Key files to update:**
- `.github/workflows/migrate.yml`
- `scripts/Add-CustomProperties.ps1`

---

### Import Source Skill

**Ask Copilot:**
- "Add [GitLab/Perforce/etc] import support"
- "Configure [source] authentication"
- "Import URL not recognized"
- "Setup credentials for [source]"

**What you'll get:**
- URL pattern detection code
- Authentication setup steps
- User credential documentation
- Complete working example

**Key files to update:**
- `scripts/New-ImportRepoDetails.ps1`
- `scripts/New-GitHubRepoMigration.ps1`
- `.github/workflows/migrate.yml`

---

## 📋 Common Workflows

### Enabling Custom Properties

```
1. Ask: "How do I enable custom properties?"
2. Follow: Step-by-step workflow updates
3. Configure: Org-level properties in GitHub
4. Test: Run migration with properties
5. Validate: Check property values set
```

### Adding New Import Source

```
1. Ask: "Add GitLab import support"
2. Update: URL parsing script
3. Configure: Authentication in migration script
4. Add: Secrets to GitHub (document for users)
5. Test: Import from new source
```

---

## ⚡ Quick Commands

### In GitHub Copilot Chat

```bash
# Custom properties
@workspace enable custom properties
@workspace add custom property for app_id
@workspace why aren't properties working

# Import sources  
@workspace add GitLab support
@workspace configure Perforce authentication
@workspace import URL pattern for Mercurial
```

---

## 🔑 Secret Configuration

### For New Import Sources

**Pattern:**
```
{SOURCE}_PAT          # Personal Access Token
{SOURCE}_USERNAME     # Username (if needed)
{SOURCE}_PASSWORD     # Password (if separate)
```

**Location:**
- Organization Settings → Secrets and Variables → Actions
- Or: Repository Settings → Secrets and Variables → Actions

**Example:**
```
GITLAB_PAT=ghp_xxxxxxxxxxxx
PERFORCE_USERNAME=service-account
PERFORCE_PASSWORD=xxxxxxxxxx
```

---

## 🎨 Example Prompts

### Custom Properties

| Intent | Prompt |
|--------|--------|
| Enable | "I want to enable custom properties for the migration" |
| Add new | "Add a custom property called 'business_unit'" |
| Debug | "Custom properties aren't showing up in the repo" |
| Validate | "Add validation for custom property values" |

### Import Sources

| Intent | Prompt |
|--------|--------|
| Add new | "Add GitLab as an import source" |
| Auth | "How do I configure authentication for Perforce?" |
| Debug | "The import URL isn't being recognized" |
| Document | "Create user documentation for GitLab setup" |

---

## 📊 Skill Decision Tree

```
Question about migration framework?
├─ About custom properties?
│  └─ Use: add-custom-properties skill
│     ├─ Enabling? → Workflow updates
│     ├─ Adding new? → Input configuration
│     └─ Not working? → Troubleshooting
│
└─ About import sources?
   └─ Use: add-import-source skill
      ├─ New source? → Complete implementation
      ├─ Authentication? → Credential setup
      └─ URL issues? → Pattern detection
```

---

## ✅ Success Checklist

### After Enabling Custom Properties

- [ ] Workflow inputs added
- [ ] Setup job outputs updated
- [ ] Workflow step uncommented
- [ ] Org properties configured
- [ ] Test migration successful
- [ ] Properties visible in repo

### After Adding Import Source

- [ ] URL pattern detection works
- [ ] Authentication configured
- [ ] Workflow secrets added
- [ ] User documentation created
- [ ] Test import successful
- [ ] Error handling tested

---

## 🔍 Troubleshooting Quick Fixes

### Copilot Not Using Skill

**Try:**
1. Use more specific keywords
2. Mention the skill domain explicitly
3. Reference specific files
4. Ask in different ways

### Custom Properties Not Appearing

**Check:**
1. Org-level properties defined?
2. Workflow step enabled?
3. Property names match exactly?
4. Repo has correct permissions?

### Import Source Not Working

**Check:**
1. URL pattern regex correct?
2. Secret names match exactly?
3. Credentials have permissions?
4. Source URL format correct?

---

## 📚 Documentation Links

- **Full guides**: `.github/skills/README.md`
- **Usage examples**: `.github/skills/USAGE.md`
- **Skill details**: `.github/skills/[skill-name]/SKILL.md`
- **Framework docs**: `README.md`, `CONFIGURATION.md`

---

## 💡 Pro Tips

1. **Be specific**: "Add GitLab support" > "Add new source"
2. **Reference files**: "Update migrate.yml" helps context
3. **Ask follow-ups**: Break complex tasks into steps
4. **Use @workspace**: For repo-specific questions
5. **Test incrementally**: Validate each change before moving on

---

## 🚀 Getting Started

**New to skills?**
1. Read [USAGE.md](.github/skills/USAGE.md)
2. Try a simple prompt: "How do I enable custom properties?"
3. Follow Copilot's guidance step-by-step
4. Ask follow-up questions as needed

**Want to contribute?**
1. Read [README.md](.github/skills/README.md)
2. Understand skill structure
3. Create/modify skills as needed
4. Test thoroughly before committing

---

*Need more help? Ask GitHub Copilot with @workspace or check the detailed documentation in each skill folder.*
