# GitHub Copilot Instructions for Repository Migration Framework

## Repository Purpose

The repository migration framework is a comprehensive automation framework designed to simplify and standardize the migration of application repositories into GitHub. It provides robust GitHub Actions workflows that automate the entire migration processes from various source control systems including Azure DevOps (ADO), BitBucket, SVN, and other GitHub repositories.

### Core Functionality

- **Automated Repository Creation**: Creates new GitHub repositories with standardized naming conventions
- **Multi-Source Migration**: Supports migration from ADO, BitBucket, SVN, and GitHub repositories
- **Team Management**: Automatically creates and configures GitHub teams with appropriate permissions
- **Permission Setup**: Establishes proper access controls based on repository criticality levels
- **Post-Migration Configuration**: Adds mandatory files, configures branch protection, and sets up integrations
- **Azure DevOps Integration**: Handles pipeline rewiring and ADO board integration for ADO migrations

## File Structure and Interconnections

### Core Workflow Files

#### `.github/workflows/migrate.yml`
**Role**: The central orchestration file that defines the complete migration workflow.

**Key Responsibilities**:
- Processes workflow inputs (manual trigger) or issue content (issue-triggered)
- Validates input parameters (naming conventions, required fields)
- Coordinates all migration steps in sequence
- Handles error scenarios and cleanup operations
- Generates comprehensive job summaries

**Interconnections**:
- Calls all PowerShell scripts in the `scripts/` directory
- References environment variables and secrets
- Integrates with GitHub API through service tokens
- Connects to external systems (ADO, BitBucket, SVN) via credentials

#### `.github/workflows/` (Other Files)
- `auto-add-to-project.yml`: Automatically adds issues/PRs to project boards
- `auto-merge.yml`: Handles automated merging of dependabot PRs
- `meta.yml`: Defines metadata requirements for the repository itself
- `platform.yml`: Platform-specific configurations
- `release.yml`: Handles release automation
- `scorecard.yml`: Security and quality scoring

### PowerShell Scripts (`scripts/` directory)

#### `modules.ps1`
**Role**: Common utilities and shared functions used across all scripts.

**Key Functions**:
- GitHub API interaction functions
- Authentication and token management
- Path manipulation utilities
- Error handling patterns

**Dependencies**: 
- PowerShell modules: `powershell-yaml`, `jwtPS`
- Used by all other PowerShell scripts

#### `New-GitHubRepo.ps1`
**Role**: Creates new GitHub repositories.

**Interconnections**:
- Uses `modules.ps1` for GitHub API calls
- Called by main workflow after input validation
- Sets up basic repository structure
- Handles repository existence checks

#### `New-GitHubRepoMigration.ps1`
**Role**: Handles the actual migration from various source systems.

**Key Features**:
- Supports multiple source types (ADO, BitBucket, SVN, GitHub)
- Handles different authentication methods per source
- Manages git history preservation
- Processes folder-specific migrations
- Implements security scanning controls

**Interconnections**:
- Uses `modules.ps1` for common functions
- Integrates with external tools (gh-gei, gh-ado2gh extensions)
- Requires system credentials for source systems
- Called after repository creation

#### `Add-MandatedRepoFile.ps1`
**Role**: Optional script for adding mandatory workflow files to migrated repositories.

**Note**: This script is currently not used in the workflow but is available for organizations that want to add standardized workflow files.

**Generated Content**:
- Creates `.github/workflows/meta.yml` with repository metadata
- Includes app ID, category, business unit, team, owner, and criticality

**Interconnections**:
- Uses input parameters from main workflow
- Commits files using git operations

#### `Execute-ADOMigrationFinalization.ps1`
**Role**: Handles Azure DevOps specific post-migration tasks.

**Key Operations**:
- Configures board integration between ADO and GitHub
- Rewires ADO pipelines to point to GitHub repository
- Sets up service connections
- Establishes autolink references

**Dependencies**:
- GitHub CLI extensions: `gh-gei`, `gh-ado2gh`
- Azure DevOps CLI tools
- ADO service connection configurations

#### Other Specialized Scripts
- `Parse-Parameters.ps1`: Processes and validates workflow inputs
- `New-ImportRepoDetails.ps1`: Parses import URLs to determine source systems
- `Rename-GitHubRepo.ps1`: Handles repository renaming operations
- `Add-CustomProperties.ps1`: Sets custom repository properties
- `Install-BFGTool.ps1`: Installs BFG tool for repository cleaning
- `Execute-GitImport.ps1`: Handles git-specific import operations

### Configuration and Templates

#### `.github/ISSUE_TEMPLATE/migration-request.yml`
**Role**: Defines the issue template for migration requests.

**Interconnections**:
- Form fields map directly to workflow inputs
- Triggers the migration workflow when issues are created with `migration-request` label
- Validates input formats and requirements

#### `platform.config.json`
**Role**: Contains platform-specific metadata and configuration.

**Content**:
- Repository title and description
- Logo reference
- Platform-specific comments and guidance

## Team Structure and Permissions

The repository implements a hierarchical team structure:

1. **`tis`**: Top-level team with pull permissions (non-critical) or no permissions (critical)
2. **`tis-{deliverable-provider}`**: Provider-specific team, nested under `tis`
3. **`tis-{deliverable-provider}-{deliverable-owner}`**: Owner-specific team with maintain permissions
4. **`tis-{deliverable-provider}-{deliverable-owner}-admins`**: Admin team with full repository access

### Team Validation Logic

The migration workflow includes team membership validation with the following behavior:

#### `Test-TeamExists` Function
- Checks if a team exists in the organization using GitHub API
- Returns `true` if team exists, `false` if not
- Used as a prerequisite check before membership validation

#### `Test-UserTeamMembership` Function
- **Updated behavior**: First checks if the team exists using `Test-TeamExists`
- **If team doesn't exist**: Returns `true` to allow migration (team will be created during migration)
- **If team exists**: Validates membership and returns `true` for active members, `false` for non-members or pending invitations
- **Security maintained**: Still validates membership for existing teams while allowing new project migrations

This approach solves the chicken-and-egg problem where team validation was blocking migrations for teams that would be created as part of the migration process.

## Coding Practices and Standards

### Naming Conventions

#### Repository Naming
- Pattern: `{deliverable-provider}-{deliverable}-{category}`
- Example: `gtm-user-management-app`
- Requirements: lowercase, hyphen-separated, alphanumeric start/end

#### Input Parameters
- **kebab-case**: Used for all workflow inputs (`deliverable-provider`, `deliverable-owner`)
- **lowercase**: All input values must be lowercase
- **validation patterns**: Regex validation for special characters and format

#### PowerShell Functions
- **PascalCase**: Function names (`New-GitHubRepo`, `Update-GitHubToken`)
- **PascalCase**: Parameter names (`$GitHubRepoUrl`, `$DeliverableProvider`)
- **camelCase**: Local variables when appropriate

### Error Handling Standards

#### PowerShell Scripts
```powershell
try {
    # Main operations
    $result = Invoke-SomeOperation
    Write-Output "| **Operation** | ✅ | Success message |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
}
catch {
    Write-Output "| **Operation** | ❌ | $($_.Exception.Message) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    throw $_
}
finally {
    # Cleanup operations
    Pop-Location
    Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
}
```

#### Workflow Error Recovery
- Failed repository creation triggers cleanup of created resources
- Team creation failures are handled with retry mechanisms
- Critical failures prevent proceeding to subsequent steps

### Security Practices

#### Secret Management
- Use GitHub secrets for external system credentials
- Never log or expose sensitive information
- Implement credential rotation patterns

#### Repository Security
- Set appropriate visibility (internal for non-critical, private for critical)
- Disable secret scanning push protection during migration, re-enable after
- Implement branch protection after migration completion

#### Input Validation
- Validate all user inputs against regex patterns
- Check for SQL injection and command injection patterns
- Sanitize file paths and repository names

### Git Operations Standards

#### Commit Standards
- Use service account: `{{APP_NAME}}[bot]` with email `{{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com`
- Include descriptive commit messages
- Preserve git history during migrations when possible

#### Branch Management
- Default branch handling for different source systems
- Branch protection bypass during migration setup
- Automatic branch cleanup for temporary operations

### API Integration Patterns

#### GitHub API Usage
- Use authenticated requests through `modules.ps1` functions
- Implement retry logic for rate-limited operations
- Handle 404 responses gracefully with null checks
- Use PATCH operations for updates, POST for creation

#### External API Integration
- Azure DevOps: Use Azure CLI and REST API
- BitBucket: Basic authentication with service accounts
- SVN: Command-line tools with credential management

### Logging and Monitoring

#### Job Summary Format
```
| Name | Status | Notes |
| ---- | ------ | ----- |
| **Operation** | ✅/❌ | Description |
```

#### Status Indicators
- ✅ Success
- ❌ Failure
- 🏃 In Progress
- 🔑 Authentication
- 🔓 Permission Changes
- 🔒 Security Operations

### File Organization

#### Script Dependencies
- All scripts must source `modules.ps1` using `. "$($PSScriptRoot)/modules.ps1"`
- Maintain consistent parameter patterns across scripts
- Use temporary directories for isolation: `New-TemporaryDirectory`

#### Configuration Management
- Environment variables for runtime configuration
- JSON configuration files for static settings
- Workflow inputs for user-provided parameters

### Testing and Validation

#### Input Validation
- Regex patterns for naming conventions
- Required field validation
- Format validation for IDs and URLs

#### Operational Validation
- Check repository existence before creation
- Validate source system connectivity before migration
- Verify team creation success before permission assignment

### Performance Considerations

#### Parallel Operations
- Team creation uses retry mechanisms for consistency
- Migration operations are sequential for data integrity
- Cleanup operations are performed in reverse order

#### Resource Management
- Use temporary directories for isolation
- Clean up resources in finally blocks
- Limit concurrent API operations to avoid rate limiting

## Integration Points

### External Systems
- **Azure DevOps**: Repository migration, pipeline rewiring, board integration
- **BitBucket**: Git repository cloning and migration
- **SVN**: Subversion repository conversion with history preservation
- **GitHub**: Repository creation, team management, permission configuration

### GitHub Features
- **Actions**: Workflow orchestration and automation
- **Teams**: Hierarchical permission management
- **API**: Repository and organization management
- **Apps**: Authentication and enhanced permissions

### Service Dependencies
- **GitHub CLI Extensions**: `gh-gei`, `gh-ado2gh` for specialized operations
- **Azure CLI**: Azure DevOps integration and management
- **Git Tools**: Repository operations and history management
- **PowerShell Modules**: `powershell-yaml`, `jwtPS` for data processing and authentication

This documentation provides the foundation for understanding the repository's architecture, coding standards, and operational patterns. When working with this codebase, always prioritize security, maintain consistency with established patterns, and ensure comprehensive error handling.