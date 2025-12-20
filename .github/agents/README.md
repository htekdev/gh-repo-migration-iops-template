# Custom Agents

This directory contains custom GitHub Copilot agents that provide specialized assistance for this repository.

## What are Custom Agents?

Custom agents are AI assistants with specialized knowledge and workflows for specific tasks. They act as expert guides that can:

- Walk you through complex multi-step processes
- Validate your work and request confirmations
- Customize their guidance based on your specific needs
- Integrate with other tools and skills
- Provide interactive, conversational assistance

## Available Agents

### 🎯 Template Onboarding Agent

**File**: [`onboarding-agent.md`](./onboarding-agent.md)

**Purpose**: Interactive guide for setting up the migration framework from template to production.

**Use this agent when**:
- You've just created a repository from this template
- You need help with initial GitHub App setup
- You want to configure secrets and source systems
- You need to customize the framework for your organization
- You're ready to finalize the repository for production use

**How to invoke**:
```
@workspace /onboarding
```

**What it does**:
1. **Assesses your needs** - Asks about source systems you'll use
2. **Guides GitHub App creation** - Step-by-step with validation
3. **Configures secrets/variables** - Ensures all credentials are set
4. **Sets up source systems** - Only configures what you'll use
5. **Adds custom properties** - Optional metadata configuration
6. **Tests your setup** - Validates with a test migration
7. **Finalizes for production** - Converts template to operational mode
8. **Confirms completion** - Ensures nothing is missed

**Key features**:
- ✅ Screenshot validation at critical steps
- ✅ Skip configuration for unused source systems
- ✅ Integration with existing skills (add-custom-properties, add-import-source, template-to-production)
- ✅ Troubleshooting assistance
- ✅ Interactive commands for navigation
- ✅ Comprehensive phase-by-phase workflow

## How to Use Agents

### Starting an Agent Session

1. Open GitHub Copilot Chat in your IDE or GitHub UI
2. Type the agent invocation (e.g., `@workspace /onboarding`)
3. Follow the agent's prompts and instructions
4. Provide requested information and screenshots
5. The agent will guide you through to completion

### During an Agent Session

You can:
- Answer questions as prompted
- Request clarification: `"Explain [topic] in more detail"`
- Navigate: `"Go back to Phase X"` or `"Skip this step"`
- Check status: `"Show me my current setup status"`
- Ask for help: `"Help me troubleshoot [issue]"`

### Best Practices

1. **Have prerequisites ready** - Check agent requirements before starting
2. **Take screenshots** - Keep them for documentation and validation
3. **Answer all questions** - Helps the agent customize guidance
4. **Don't skip validation** - Screenshots ensure steps are done correctly
5. **Ask questions** - Agents are there to help, no question is too small

## Creating New Agents

Want to create your own custom agent? See the [skill-creator guide](../skills/skill-creator/SKILL.md) for best practices and patterns.

### Agent File Structure

```markdown
---
name: agent-name
description: Clear description of what the agent does and when to use it
---

# Agent Title

[Agent content with phases, validation steps, and guidance]
```

### Key Elements

- **Frontmatter**: YAML with `name` and `description` (determines when agent is invoked)
- **Clear phases**: Break complex tasks into manageable steps
- **Validation points**: Request confirmations and screenshots
- **Interactive commands**: Provide navigation and help options
- **Integration**: Reference other skills and tools
- **Troubleshooting**: Include common issues and solutions

## Related Resources

- **Skills**: See [`.github/skills/`](../skills/) for non-interactive automation
- **Copilot Instructions**: See [`.github/copilot-instructions.md`](../copilot-instructions.md) for general context
- **GitHub Copilot Docs**: [About custom agents](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
