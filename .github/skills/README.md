# GitHub Copilot Agent Skills

This directory contains Agent Skills that enhance GitHub Copilot's ability to work with the migration framework. Skills are modular packages of instructions that teach Copilot how to perform specialized tasks.

## Available Skills

### 🔧 [add-custom-properties](./add-custom-properties/SKILL.md)

**Purpose**: Guide for enabling and configuring custom repository properties in the migration workflow.

**Use when**:
- Enabling custom properties support
- Adding new custom properties to migrations
- Troubleshooting custom property issues
- Configuring repository metadata

**Key capabilities**:
- Step-by-step workflow updates
- Script modification guidance
- Organization-level property configuration
- Validation and error handling

---

### 📦 [add-import-source](./add-import-source/SKILL.md)

**Purpose**: Comprehensive guide for adding support for new source control systems.

**Use when**:
- Adding a new import source (GitLab, Perforce, Mercurial, etc.)
- Extending authentication methods
- Troubleshooting import detection
- Updating URL parsing patterns

**Key capabilities**:
- Complete implementation workflow
- Credential setup documentation
- URL pattern matching
- Authentication configuration
- Testing and troubleshooting guidance

---

## How Skills Work

GitHub Copilot automatically discovers and loads these skills when relevant to your task. When you ask Copilot about custom properties or adding import sources, it will use these skills to provide accurate, context-aware guidance.

### Skill Structure

Each skill contains:
- **SKILL.md**: Main instruction file with YAML frontmatter and detailed guidance
- **Frontmatter**: Metadata including `name` and `description` that helps Copilot know when to use the skill
- **Markdown body**: Comprehensive instructions, examples, and best practices

### Using Skills

Simply ask Copilot questions related to the skill's domain:

**For Custom Properties:**
- "How do I enable custom properties in the migration?"
- "Add a new custom property for business unit"
- "Why aren't my custom properties showing up?"

**For Import Sources:**
- "How do I add GitLab as an import source?"
- "Add support for importing from Perforce"
- "The import URL isn't being recognized"

## Creating New Skills

To create a new skill for this repository:

1. Create a new directory under `.github/skills/` with a descriptive name (lowercase, hyphen-separated)
2. Create a `SKILL.md` file with YAML frontmatter:
   ```markdown
   ---
   name: skill-name
   description: Clear description of what the skill does and when to use it
   ---
   
   # Skill Name
   
   [Your instructions here]
   ```
3. Test the skill by asking Copilot related questions
4. Iterate based on how well Copilot uses the skill

### Skill Best Practices

- **Concise but comprehensive**: Include all necessary information, but keep it focused
- **Clear triggering conditions**: Description should specify when to use the skill
- **Step-by-step guidance**: Break complex tasks into clear steps
- **Examples included**: Provide code examples and real-world scenarios
- **Error handling**: Include troubleshooting sections
- **Security awareness**: Highlight security considerations

## Documentation

For more information about Agent Skills:
- [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Creating Custom Skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Agent Skills Specification](https://github.com/anthropics/skills)

## Contributing

When adding or modifying skills:
1. Follow the existing skill structure and format
2. Test thoroughly with various prompts
3. Include clear, actionable instructions
4. Update this README with new skills
5. Document any dependencies or prerequisites

## Feedback

If a skill isn't working as expected or you have suggestions for improvements, please open an issue with:
- The question you asked Copilot
- The response you received
- The expected behavior
- Any error messages or logs
