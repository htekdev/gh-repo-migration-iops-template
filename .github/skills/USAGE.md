# Agent Skills Setup Guide

## Overview

This repository now includes two GitHub Copilot Agent Skills that provide specialized guidance for common migration framework tasks. These skills enhance Copilot's ability to help you with custom properties and import source configuration.

## What Are Agent Skills?

Agent Skills are folders of instructions that GitHub Copilot loads dynamically to provide better assistance with specialized tasks. Think of them as expert consultants that Copilot can call upon when you need help with specific aspects of the migration framework.

## Available Skills

### 1. Add Custom Properties (`add-custom-properties`)

This skill helps you enable and configure custom repository properties in the migration workflow.

**Example prompts that trigger this skill:**
- "How do I enable custom properties?"
- "Add custom properties for app_id and category"
- "Why aren't custom properties working?"
- "Configure custom properties in the migration"

### 2. Add Import Source (`add-import-source`)

This skill provides comprehensive guidance for adding new source control systems (like GitLab, Perforce, etc.) to the migration framework.

**Example prompts that trigger this skill:**
- "How do I add GitLab as an import source?"
- "Add support for importing from Perforce"
- "The import URL pattern isn't being recognized"
- "Configure credentials for a new source system"

## How to Use

### In GitHub Copilot Chat

1. Open the repository in your IDE (VS Code, Visual Studio, etc.)
2. Open GitHub Copilot Chat
3. Ask questions related to the skills
4. Copilot will automatically use the relevant skill to provide detailed guidance

**Example conversation:**

```
You: How do I add GitLab as an import source?

Copilot: [Uses add-import-source skill]
To add GitLab as an import source, follow these steps:

1. Update the URL parsing script (New-ImportRepoDetails.ps1)...
2. Modify the migration script (New-GitHubRepoMigration.ps1)...
3. Configure secrets for authentication...
[...detailed step-by-step guidance...]
```

### Using @workspace

For workspace-specific questions, use the `@workspace` mention:

```
@workspace How do I enable custom properties in the migration workflow?
```

### In GitHub.com (with GitHub Copilot Pro+)

Skills are also available when using Copilot in github.com:
1. Navigate to your repository
2. Open Copilot panel
3. Ask questions about custom properties or import sources
4. Copilot will reference the skills as needed

## Skill Activation

Skills activate automatically based on:
- **Keywords in your question** (custom properties, import source, etc.)
- **Context of the conversation** (discussing migration framework)
- **Files you're working with** (scripts, workflows, etc.)

You don't need to explicitly mention the skill name - Copilot decides when to use each skill based on your needs.

## What Each Skill Provides

### Add Custom Properties Skill

- ✅ Complete workflow updates (step-by-step)
- ✅ Script modification guidance
- ✅ Organization-level configuration
- ✅ Input validation patterns
- ✅ Troubleshooting common issues
- ✅ Security best practices
- ✅ Testing procedures

### Add Import Source Skill

- ✅ URL pattern detection setup
- ✅ Authentication configuration
- ✅ Script updates (parsing + migration)
- ✅ Credential setup instructions for users
- ✅ Tool installation requirements
- ✅ Testing and validation
- ✅ Error handling patterns
- ✅ Complete GitLab example

## Key Features

### Comprehensive Documentation

Each skill includes:
- Clear prerequisites
- Step-by-step instructions
- Code examples
- Troubleshooting guides
- Security considerations
- Best practices

### User Credential Guidance

The **Add Import Source** skill specifically includes directions for users to update repository secrets with appropriate credentials:

```markdown
## Step 5: Configure Required Secrets

Users must add the necessary credentials to their repository secrets.

### GitHub Organization Secrets (Recommended)
1. Navigate to Organization Settings → Secrets and Variables → Actions
2. Click "New organization secret"
3. Add the credential (e.g., `GITLAB_PAT`)
4. Set repository access

[...detailed guidance for each credential type...]
```

### Workflow Integration

Both skills explain how to:
- Modify workflow files
- Update PowerShell scripts
- Configure environment variables
- Handle secrets securely
- Test implementations

## Implementation Notes

### For Add Custom Properties

The skill guides you through:
1. **Uncommenting** the disabled custom properties step in the workflow
2. **Adding workflow inputs** for new properties
3. **Configuring** organization-level properties in GitHub
4. **Testing** the implementation
5. **Validating** property values

**Important**: Custom properties must be defined at the GitHub organization level before they can be used.

### For Add Import Source

The skill provides:
1. **Complete implementation** from URL parsing to credential setup
2. **User documentation** that you can copy to your README
3. **Security guidance** for handling credentials
4. **Testing procedures** to validate the new source
5. **Example implementation** for GitLab

**Important**: Users need to add appropriate secrets (PATs, credentials) to GitHub for each new source.

## Credential Setup Guidance

The Add Import Source skill includes **complete user-facing documentation** for credential setup:

### Example Output

When you ask "How do I add GitLab support?", the skill will guide you to create documentation like:

```markdown
## For GitLab Import Source

**Prerequisites:**
1. GitLab Personal Access Token with `read_repository` scope

**Setup Steps:**

1. **Generate GitLab Personal Access Token**:
   - Go to GitLab Settings → Access Tokens
   - Create token with scopes: `read_repository`, `read_api`
   - Copy the token

2. **Add Token to GitHub Secrets**:
   - Go to GitHub Organization Settings
   - Navigate to Secrets and Variables → Actions
   - Add secret named `GITLAB_PAT`
   - Paste your GitLab token

3. **Verify Configuration**:
   - Run test migration
   - Check logs for authentication success
```

This ensures users know exactly how to configure credentials for the new source system.

## Testing Your Changes

Both skills include testing guidance:

### Unit Testing
- Test with minimal test repositories
- Verify each component individually
- Check error handling

### Integration Testing
- Test with real repositories
- Verify end-to-end functionality
- Check edge cases

### Security Testing
- Validate credential handling
- Test with expired tokens
- Check for credential exposure

## Best Practices

1. **Read the full skill before implementing** - Both skills are comprehensive
2. **Follow the steps in order** - Each step builds on the previous
3. **Test in a non-production environment first** - Validate before rolling out
4. **Document user-facing changes** - Add to README and documentation
5. **Keep credentials secure** - Never commit secrets, use GitHub Secrets
6. **Validate thoroughly** - Test success cases and error cases

## Advanced Usage

### Combining Skills

You can work with both skills in a conversation:

```
You: I need to add custom properties for the team name and also add GitLab support

Copilot: [Uses both skills]
Let's tackle both tasks:

For custom properties:
1. [Guidance from add-custom-properties skill]

For GitLab support:
1. [Guidance from add-import-source skill]
```

### Iterative Development

Skills support iterative questions:

```
You: How do I add custom properties?
Copilot: [Provides overview]

You: Show me how to update the workflow inputs
Copilot: [Provides specific guidance]

You: What validation should I add?
Copilot: [Provides validation patterns]
```

## Troubleshooting

### Skill Not Activating

If Copilot doesn't seem to use the skill:
1. Be more specific in your question
2. Use keywords like "custom properties" or "import source"
3. Mention the specific task (e.g., "add GitLab support")
4. Reference specific files (e.g., "migrate.yml")

### Incomplete Guidance

If you need more detail:
1. Ask follow-up questions
2. Request specific sections (e.g., "Show me the validation code")
3. Ask about specific scenarios (e.g., "How do I handle GitLab groups?")

### Skill Content Updates

If you need to update a skill:
1. Edit the `SKILL.md` file in the skill's directory
2. Update the frontmatter description if the purpose changes
3. Test with various prompts to ensure it works
4. Update the README if adding major sections

## Examples

### Example 1: Enable Custom Properties

**Your question:**
```
@workspace I want to enable custom properties in the migration. 
What steps do I need to follow?
```

**Copilot's response** (using add-custom-properties skill):
```
To enable custom properties in the migration workflow, follow these steps:

1. Identify Required Properties
   First determine which properties you need:
   - app_id
   - category
   - business_unit
   [...]

2. Update Workflow Inputs
   Add to .github/workflows/migrate.yml:
   [code example]

3. Uncomment the Workflow Step
   [specific guidance with line numbers]

[...complete step-by-step guidance...]
```

### Example 2: Add New Import Source

**Your question:**
```
How do I add support for importing from GitLab? 
Include the credential setup instructions for users.
```

**Copilot's response** (using add-import-source skill):
```
Here's how to add GitLab support to the migration framework:

Step 1: Update URL Parsing
[code example for New-ImportRepoDetails.ps1]

Step 2: Update Migration Script
[code example for New-GitHubRepoMigration.ps1]

[...]

Step 5: User Credential Setup Documentation

Add this to your README for users:

### GitLab Prerequisites

1. Generate Personal Access Token
   [detailed steps]

2. Add Secret to GitHub
   [detailed steps]

3. Verify Setup
   [testing steps]

[...complete implementation with user documentation...]
```

## Contributing to Skills

Want to improve or add skills? See [.github/skills/README.md](.github/skills/README.md) for guidelines on:
- Creating new skills
- Modifying existing skills
- Testing skills
- Best practices

## Additional Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Agent Skills Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Migration Framework Documentation](./README.md)
- [Copilot Instructions](./copilot-instructions.md)

## Questions?

If you have questions about using these skills or need help with implementation:
1. Ask GitHub Copilot with specific questions
2. Reference the skill documentation directly
3. Check the troubleshooting sections
4. Review the examples provided
5. Open an issue if you encounter problems

---

**Note**: These skills are designed to work with GitHub Copilot (VS Code, Visual Studio, github.com, etc.). They require an active GitHub Copilot subscription.
