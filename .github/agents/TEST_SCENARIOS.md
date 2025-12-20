# Onboarding Agent Test Scenarios

This document outlines test scenarios for the template onboarding agent.

## Test Scenario 1: Full Setup with All Source Systems

**Goal**: Validate complete setup with ADO, BitBucket, SVN, and external GitHub.

**Steps**:
1. Invoke agent: `@workspace /onboarding`
2. Answer Phase 1 assessment:
   - Select all source systems: ADO, BitBucket, SVN, External GitHub
   - Need custom properties: Yes
   - Organization: test-org
3. Phase 2: Create GitHub App
   - Provide App Name: test-migration-app
   - Provide App ID: 12345
   - Provide App User ID: 123456789
   - Upload screenshot of app settings
4. Phase 3: Configure secrets and variables
   - Add GH_APP_PRIVATE_KEY secret
   - Add GH_APP_ID, GH_APP_NAME, GH_APP_USER_ID variables
   - Provide screenshots
5. Phase 4: Configure all source systems
   - ADO: Add ADO_PAT secret, optionally ADO_SERVICE_CONNECTION_ID
   - BitBucket: Add BB_USERNAME, BB_PAT secrets, BITBUCKET_BASE_URL variable
   - SVN: Add SUBVERSION_SERVICE_PASSWORD secret, SUBVERSION_SERVICE_USERNAME and SVN_BASE_URL variables
   - External GitHub: Add GH_PAT secret
   - Provide screenshots for each
6. Phase 5: Run test migration
   - Create test issue with migration request
   - Verify successful run
   - Provide screenshot of green workflow
7. Phase 6: Configure custom properties
   - Request custom properties configuration
   - Agent invokes add-custom-properties skill
8. Phase 7: Skip (no additional source systems needed)
9. Phase 8: Finalize for production
   - Confirm all checklist items
   - Say "I'm ready to finalize"
   - Agent invokes template-to-production skill
10. Phase 9: Review post-finalization
    - Confirm understanding of new structure

**Expected Results**:
- All phases completed successfully
- All secrets and variables configured
- Test migration runs successfully
- Repository finalized for production
- README converted to user-focused documentation

---

## Test Scenario 2: Minimal Setup (No Source Migration)

**Goal**: Set up framework for creating new repositories only, no source migrations.

**Steps**:
1. Invoke agent: `@workspace /onboarding`
2. Answer Phase 1 assessment:
   - Select: Only creating new repositories (no migration)
   - Need custom properties: No
   - Organization: test-org
3. Phase 2: Create GitHub App (same as Scenario 1)
4. Phase 3: Configure secrets and variables (same as Scenario 1)
5. Phase 4: Skip all source systems
   - Agent should skip ADO, BitBucket, SVN, External GitHub configuration
6. Phase 5: Run test migration
   - Create empty repository (no source URL)
7. Phase 6: Skip custom properties
8. Phase 7: Skip additional source systems
9. Phase 8: Finalize for production
10. Phase 9: Review post-finalization

**Expected Results**:
- Only required GitHub App setup completed
- No source system credentials configured
- Documentation cleaned up to remove source system references
- Faster setup process

---

## Test Scenario 3: Selective Source Systems

**Goal**: Set up only ADO and skip other systems.

**Steps**:
1. Invoke agent: `@workspace /onboarding`
2. Answer Phase 1 assessment:
   - Select: Azure DevOps only
   - Need custom properties: No
   - Organization: test-org
3. Phase 2: Create GitHub App
4. Phase 3: Configure secrets and variables
5. Phase 4: Configure ADO only
   - Add ADO_PAT secret
   - Add ADO_SERVICE_CONNECTION_ID variable
   - Request to skip BitBucket, SVN, External GitHub
   - Agent should offer to clean up documentation for unused systems
6. Phase 5: Run test migration from ADO
7. Phase 6: Skip custom properties
8. Phase 7: Skip additional source systems
9. Phase 8: Finalize for production
10. Phase 9: Review post-finalization

**Expected Results**:
- Only ADO configured
- Documentation simplified for ADO-only setup
- BitBucket, SVN, GitHub sections removed from README

---

## Test Scenario 4: Add New Source System

**Goal**: Add GitLab support during onboarding.

**Steps**:
1. Invoke agent: `@workspace /onboarding`
2. Answer Phase 1 assessment:
   - Select: Other (GitLab)
   - Need custom properties: No
   - Organization: test-org
3. Complete Phases 2-5 (GitHub App setup and test)
4. Phase 7: Add GitLab support
   - Request to add GitLab
   - Agent invokes add-import-source skill
   - Provide GitLab details:
     - URL pattern: `https://gitlab.company.com/group/project`
     - Authentication: Personal Access Token
     - Token scope: api, read_repository
5. Configure GitLab credentials
   - Add GITLAB_PAT secret
   - Add GITLAB_BASE_URL variable
6. Test GitLab migration
7. Phase 8: Finalize for production

**Expected Results**:
- GitLab support added to framework
- GitLab credentials configured
- Documentation includes GitLab instructions

---

## Test Scenario 5: Troubleshooting During Setup

**Goal**: Test agent's ability to help troubleshoot issues.

**Steps**:
1. Invoke agent
2. During Phase 2, simulate issue: "I can't find the App ID"
   - Agent should provide detailed instructions
3. During Phase 3, simulate issue: "Workflow failing with auth errors"
   - Agent should provide troubleshooting steps
4. Use interactive command: "Show me my current setup status"
   - Agent should summarize completed and pending steps
5. Use interactive command: "Explain GitHub App permissions"
   - Agent should provide detailed explanation
6. Complete remaining phases successfully

**Expected Results**:
- Agent provides helpful troubleshooting
- Status commands work correctly
- Explanation requests are answered
- Setup completes successfully after resolving issues

---

## Test Scenario 6: Navigation and Backtracking

**Goal**: Test agent's ability to handle non-linear progression.

**Steps**:
1. Invoke agent
2. Complete Phases 1-3
3. Say "Go back to Phase 2"
   - Agent should return to GitHub App setup phase
4. Skip Phase 4: "Skip all source systems"
5. Jump to Phase 8: "I'm ready to finalize"
   - Agent should remind about uncompleted steps (Phase 5 test migration)
6. Complete Phase 5
7. Return to Phase 8 and finalize

**Expected Results**:
- Agent handles navigation commands
- Agent prevents premature finalization
- Agent validates all required steps completed

---

## Validation Checklist

After running test scenarios, verify:

- [ ] Agent follows proper phase sequence
- [ ] Screenshot validation requests are clear
- [ ] Source system configuration is accurate
- [ ] Integration with skills works (add-custom-properties, add-import-source, template-to-production)
- [ ] Troubleshooting guidance is helpful
- [ ] Interactive commands function correctly
- [ ] Finalization checklist is comprehensive
- [ ] Agent confirms all required steps before finalization
- [ ] Post-finalization guidance is clear
- [ ] Agent gracefully handles edge cases

---

## Manual Testing Instructions

To manually test the agent:

1. Create a test repository from the template
2. Open GitHub Copilot in your IDE or browser
3. Type: `@workspace /onboarding`
4. Follow one of the test scenarios above
5. Take notes on any issues or unclear guidance
6. Document screenshots at validation points
7. Verify final repository state matches expectations

---

## Automated Testing (Future)

Potential automated tests:
- Parse agent markdown for completeness
- Validate all phase numbers are sequential
- Check for broken skill references
- Verify all interactive commands are documented
- Validate screenshot request formatting
- Check for consistent terminology

---

## Known Limitations

- Agent relies on user providing accurate information
- Screenshot validation is manual (agent can't verify content)
- Agent can't directly execute workflow runs or API calls
- Integration with skills is through references (not direct invocation)

---

## Improvement Ideas

- Add validation scripts that agent can run
- Include common error messages and solutions
- Add visual diagrams for complex steps
- Create quick reference guide for experienced users
- Add estimated time for each phase
