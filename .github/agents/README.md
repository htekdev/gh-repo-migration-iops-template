# GitHub Copilot Agents

This directory contains custom GitHub Copilot agents for the migrate repository migration framework.

## What are Custom Agents?

Custom agents are specialized AI assistants configured to help with specific tasks in your repository. They have deep knowledge of your codebase structure, conventions, and workflows.

## Available Agents

### @custom-properties

**Purpose:** Manage custom repository properties in the migration workflow.

**Use When:**
- You want to add tracking metadata to migrated repositories
- You need to collect additional information during migration requests
- You want to enable organization-level governance properties

**Example Usage:**
```
@custom-properties add a custom property for CMDB App ID in format APM0001234
```

```
@custom-properties I need to track business_unit, cost_center, and compliance_level
```

**What It Does:**
1. ✏️ Adds new input fields to the issue template
2. 🔧 Updates the workflow to capture and set properties
3. 📝 Documents changes in README
4. ✅ Adds validation rules
5. 🧪 Suggests testing steps

**Files It Modifies:**
- `.github/ISSUE_TEMPLATE/migration-request.yml`
- `.github/workflows/migrate.yml`
- `README.md`
- `.github/copilot-instructions.md` (if needed)

## How to Use Agents

### In Chat
Mention the agent by name:
```
@custom-properties help me add a property for tracking team budgets
```

### In Code Comments
Reference the agent in comments:
```yaml
# @custom-properties: add validation for this property
```

### In Commits/PRs
Tag the agent for context:
```
Add cost_center field @custom-properties
```

## Creating New Agents

To create a new agent:

1. Create a YAML file in `.github/agents/`
2. Define the agent's purpose, capabilities, and instructions
3. Specify triggers and example prompts
4. List relevant files it should work with
5. Document it in this README

See `custom-properties.yml` as a reference template.

## Agent Best Practices

- **Specific Purpose:** Each agent should have a clear, focused responsibility
- **Clear Instructions:** Provide detailed guidance on what the agent should do
- **Context Aware:** Include information about the codebase and conventions
- **User Friendly:** Make it easy for users to invoke and interact with
- **Well Documented:** Explain what the agent does and when to use it

## References

- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [Agent Configuration Guide](https://docs.github.com/en/copilot/customizing-copilot/creating-custom-agents)

---

For questions or issues with agents, please open an issue in this repository.
