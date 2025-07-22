---
name: Bug Report
about: Report a bug or issue with the Laboratory Testing POC Comparison project
title: '[BUG] Brief description of the issue'
labels: bug
assignees: ''

---

## Bug Description
**Brief Summary:**
A clear and concise description of what the bug is.

**Clinical Impact:**
Describe the potential impact on laboratory operations or patient care.

## Environment Information
**Healthcare System:**
- [ ] Veterans Affairs (VA)
- [ ] Private Hospital
- [ ] Academic Medical Center
- [ ] Community Hospital
- [ ] Other: ___________

**Technical Environment:**
- **SQL Server Version:** (e.g., SQL Server 2019, Azure SQL Database)
- **SQL Server Edition:** (e.g., Standard, Enterprise, Express)
- **Database Size:** (e.g., <1GB, 1-10GB, >10GB)
- **PowerBI Version:** (e.g., PowerBI Desktop, PowerBI Service)
- **Operating System:** (e.g., Windows Server 2019, Windows 10)

**Data Volume:**
- **Approximate number of lab results per month:** ___________
- **Date range of data being analyzed:** ___________
- **Number of different test types:** ___________

## Steps to Reproduce
**Detailed Steps:**
1. Step 1: '...'
2. Step 2: '...'
3. Step 3: '...'
4. See error

**SQL Parameters Used:**
```sql
-- Include any specific parameters or configuration values used
DECLARE @FacilityStationNumber VARCHAR(10) = 'XXX'
DECLARE @StartDate DATE = 'YYYY-MM-DD'
DECLARE @EndDate DATE = 'YYYY-MM-DD'
-- etc.
```

## Expected Behavior
**What should happen:**
A clear and concise description of what you expected to happen.

**Clinical Expectation:**
What clinical outcome or analysis result was expected?

## Actual Behavior
**What actually happened:**
A clear and concise description of what actually happened.

**Error Messages:**
```
Include any error messages, SQL error codes, or PowerBI error details
```

**Screenshot (if applicable):**
Add screenshots to help explain your problem (ensure no PHI is visible).

## Sample Data
**Data Characteristics:**
- Test types involved: ___________
- Time period: ___________
- Volume of records: ___________

**De-identified Sample:**
```sql
-- Provide de-identified sample data that demonstrates the issue
-- Remove all PHI including full SSN, names, dates of birth, etc.
-- Use only last-4 SSN and anonymized dates
```

## Performance Information
**Query Execution Time:**
- Expected: _____ seconds/minutes
- Actual: _____ seconds/minutes

**Resource Usage:**
- CPU usage during execution: _____%
- Memory usage: _____GB
- Disk I/O impact: High/Medium/Low

## Impact Assessment
**Operational Impact:**
- [ ] Blocks daily laboratory operations
- [ ] Affects quality assurance processes
- [ ] Impacts regulatory reporting
- [ ] Delays patient care decisions
- [ ] Other: ___________

**Data Accuracy Impact:**
- [ ] Produces incorrect comparison results
- [ ] Missing expected test pairs
- [ ] Incorrect time window calculations
- [ ] Statistical calculation errors
- [ ] Other: ___________

**Urgency Level:**
- [ ] Critical - Immediate fix required
- [ ] High - Fix needed within 24 hours
- [ ] Medium - Fix needed within 1 week
- [ ] Low - Fix needed when convenient

## Additional Context
**Workarounds:**
Describe any temporary workarounds you've found.

**Related Issues:**
Link to any related issues or previous reports.

**Additional Information:**
Add any other context about the problem here.

## Validation Requirements
**Testing Environment:**
How can this bug be safely tested without affecting production systems?

**Clinical Validation:**
What clinical expertise is needed to validate the fix?

**Data Requirements:**
What type of test data is needed to verify the fix?

## Contact Information
**Primary Contact:**
- Name: ___________
- Role: ___________
- Email: ___________
- Phone: ___________ (for critical issues)

**Clinical SME Contact:**
- Name: ___________
- Role: ___________
- Email: ___________

---

**Security Note:** Please ensure no Protected Health Information (PHI) is included in this report. Use only de-identified data and remove any direct patient identifiers.
