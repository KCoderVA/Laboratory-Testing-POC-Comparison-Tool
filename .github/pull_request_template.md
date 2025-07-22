# Pull Request Template

## Summary
**Brief Description:**
Provide a concise description of the changes in this pull request.

**Related Issue:**
Closes #[issue number] (if applicable)

## Type of Change
Please check all that apply:
- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📚 Documentation update
- [ ] 🔧 Code refactoring (no functional changes)
- [ ] ⚡ Performance optimization
- [ ] 🔒 Security enhancement
- [ ] 🧪 Test improvements
- [ ] 🏗️ Build/deployment changes

## Clinical Impact
**Clinical Justification:**
Explain how these changes affect laboratory operations, patient care, or quality assurance.

**Clinical Validation:**
Describe how the clinical accuracy of these changes has been validated.

**Workflow Impact:**
How do these changes affect existing laboratory workflows?

## Technical Changes
**Components Modified:**
- [ ] SQL stored procedures
- [ ] Individual test queries
- [ ] PowerBI reports/dashboards
- [ ] Documentation
- [ ] Configuration files
- [ ] Other: ___________

**Key Changes:**
1. Change 1: Description
2. Change 2: Description
3. Change 3: Description

**Breaking Changes:**
If this is a breaking change, describe what breaks and how users should adapt.

## Testing
**Testing Completed:**
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Clinical validation complete
- [ ] Security review complete
- [ ] Cross-platform testing complete

**Test Data Used:**
- Data volume: _____ records
- Date range: _____ to _____
- Test types: _____
- Facility types: _____

**Performance Impact:**
- Query execution time: Before _____ / After _____
- Memory usage: Before _____ / After _____
- CPU usage: Before _____ / After _____

**Clinical Testing Results:**
Describe clinical validation results and any clinical review feedback.

## Code Quality
**Code Review Checklist:**
- [ ] Code follows project style guidelines
- [ ] Code is well-commented with clinical context
- [ ] Error handling is appropriate
- [ ] Security best practices followed
- [ ] Performance considerations addressed
- [ ] Documentation updated as needed

**Static Analysis:**
- [ ] No new security vulnerabilities introduced
- [ ] No new performance regressions
- [ ] Code complexity is reasonable
- [ ] Test coverage is adequate

## Security and Compliance
**Security Review:**
- [ ] No PHI exposure risks introduced
- [ ] Access controls maintained or improved
- [ ] Audit logging preserved
- [ ] Input validation adequate
- [ ] Output sanitization appropriate

**HIPAA Compliance:**
- [ ] Changes maintain HIPAA compliance
- [ ] No new PHI handling requirements
- [ ] Existing safeguards preserved
- [ ] Risk assessment completed (if needed)

**Data Privacy:**
- [ ] Only last-4 SSN used (no full SSN)
- [ ] No temporary PHI storage
- [ ] Appropriate data retention
- [ ] Secure data handling

## Documentation
**Documentation Updated:**
- [ ] README.md
- [ ] Inline code comments
- [ ] Clinical justification documented
- [ ] Configuration guide updated
- [ ] API documentation (if applicable)
- [ ] User guide updated
- [ ] CHANGELOG.md updated

**Clinical Documentation:**
- [ ] Time window rationale documented
- [ ] Test comparison logic explained
- [ ] Quality metrics documented
- [ ] Clinical validation process described

## Deployment Considerations
**Database Changes:**
- [ ] No database schema changes
- [ ] Schema changes are backward compatible
- [ ] Migration scripts provided
- [ ] Rollback plan available

**Configuration Changes:**
- [ ] No configuration changes required
- [ ] Configuration changes documented
- [ ] Default values appropriate
- [ ] Upgrade path documented

**Deployment Risk:**
- [ ] Low risk - Minor changes only
- [ ] Medium risk - Moderate changes with testing
- [ ] High risk - Significant changes requiring careful deployment

## Validation Requirements
**Clinical Validation:**
Who should review these changes from a clinical perspective?
- [ ] Laboratory Director
- [ ] Clinical Informatics Professional
- [ ] Quality Assurance Staff
- [ ] Laboratory Technologist
- [ ] Other: ___________

**Technical Validation:**
What technical validation is still needed?
- [ ] Performance testing with larger datasets
- [ ] Cross-platform compatibility testing
- [ ] Integration testing with other systems
- [ ] Security penetration testing
- [ ] Other: ___________

## Rollback Plan
**Rollback Strategy:**
Describe how to rollback these changes if issues are discovered.

**Dependencies:**
List any dependencies that would prevent or complicate rollback.

**Monitoring:**
What should be monitored after deployment to ensure success?

## Screenshots/Examples
**Before and After:**
Include screenshots or examples showing the impact of changes (ensure no PHI is visible).

**Query Results:**
Show example query results demonstrating the changes (use de-identified data only).

**PowerBI Updates:**
Include screenshots of PowerBI report changes (anonymized data only).

## Checklist
**Pre-submission Checklist:**
- [ ] All tests pass locally
- [ ] Code has been self-reviewed
- [ ] Clinical accuracy validated
- [ ] Security implications considered
- [ ] Documentation updated
- [ ] Breaking changes noted
- [ ] Performance impact assessed
- [ ] HIPAA compliance maintained

**Reviewer Guidelines:**
**For Clinical Reviewers:**
- Validate clinical logic and time windows
- Verify test comparison methodologies
- Confirm quality metrics are appropriate
- Check clinical workflow impact

**For Technical Reviewers:**
- Review code quality and structure
- Validate security implementations
- Check performance optimizations
- Verify error handling

**For Security Reviewers:**
- Assess PHI protection measures
- Validate access controls
- Review audit logging
- Check for security vulnerabilities

## Contact Information
**Pull Request Author:**
- Name: ___________
- Role: ___________
- Email: ___________

**Clinical SME (if different):**
- Name: ___________
- Role: ___________
- Email: ___________

**Additional Reviewers Needed:**
List specific individuals who should review this PR and why.

---

**Note:** Ensure all screenshots, examples, and test data are de-identified and contain no Protected Health Information (PHI).
