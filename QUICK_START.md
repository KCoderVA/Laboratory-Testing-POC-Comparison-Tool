# Quick Start Guide - Laboratory POC Comparison Tool

🚀 **Get up and running in 15 minutes!**

This guide provides the fastest path to deploy and run the Laboratory POC Comparison analysis at your VA facility.

## Table of Contents
- [Prerequisites Checklist](#prerequisites-checklist)
- [Quick Setup (5 Steps)](#quick-setup-5-steps)
- [First Execution](#first-execution)
- [Optional: PowerBI Integration](#optional-powerbi-integration)
- [Troubleshooting](#troubleshooting)

## Prerequisites Checklist

### ✅ Required VA Access (Must Complete First)

**🔐 Step 1: NDS Operational Access**
- [ ] Complete NDS Operational Access request
- [ ] Visit: https://vaww.vhadataportal.med.va.gov/Data-Access/Operations-Access *(VA network only)*
- [ ] Wait for PHI/Real SSN access approval

**💻 Step 2: SQL Software Installation**
- [ ] **Option A:** Download VS Code from https://code.visualstudio.com/download
- [ ] **Option B:** Request SSMS via https://yourit.va.gov (submit OIT ticket)
  - [ ] Or use VA Software Center: `softwarecenter:SoftwareID=ScopeId_16785680-02FE-4B9B-B358-62C5C20205D4/Application_a72f3f2b-d050-4637-9e32-8091ecda9e61`

**🔗 Step 3: Database Connection Setup**
- [ ] Configure connection to: `VhaCdwDwhSql33.vha.med.va.gov`
- [ ] Test connection with your VA credentials
- [ ] Verify access to CDWWork database

**📊 Optional Step 4: Database Write Access** *(For stored procedures only)*
- [ ] Contact your CDW owner via: https://dvagov.sharepoint.com/sites/OITBISL/SitePages/CDW-Site-Directory.aspx
- [ ] Request write access to your facility's database schema

## Quick Setup (5 Steps)

### 🔽 Step 1: Download Files
Download the main analysis file:
```
📄 LabTest_POC_Compare_Analysis.sql
📄 [dbo].[sp_SignAppObject].sql (for stored procedure mode)
```

### 🔧 Step 2: Configure Facility Settings
Open `LabTest_POC_Compare_Analysis.sql` and modify line 285:

```sql
-- CHANGE THIS LINE TO YOUR FACILITY:
DECLARE @FacilityStationNumber INT = 578;  -- Replace 578 with your station number
```

**Common Station Numbers:**
- Edward Hines Jr. VA: `578`
- Milwaukee VA: `695` 
- Find yours at: https://dvagov.sharepoint.com/sites/OITBISL/SitePages/CDW-Site-Directory.aspx

### ▶️ Step 3: Choose Execution Mode

**Option A: Query Mode (Recommended for first use)**
- Keep stored procedure lines commented out (default)
- Execute query directly in VS Code/SSMS
- Results appear as CSV-like table

**Option B: Stored Procedure Mode**
1. Uncomment these lines (around line 260):
   ```sql
   CREATE OR ALTER PROCEDURE [App].[LabTest_POC_Compare]    
   AS
   BEGIN
   EXEC dbo.sp_SignAppObject [LabTest_POC_Compare]
   ```
2. Uncomment at end of file:
   ```sql
   END
   GO
   ```

### 🏃‍♂️ Step 4: Execute Query
- **In VS Code:** Press `Ctrl+Shift+E` to execute
- **In SSMS:** Press `F5` or click Execute button
- **Expected runtime:** 2-5 minutes depending on data volume

### ✅ Step 5: Verify Results
Expected output includes:
- Patient identifiers (Last 4 SSN)
- Test collection times and results
- Location information
- Test family groupings (Glucose, Creatinine, etc.)

## First Execution

### What to Expect
- **Data Range:** Fiscal year to date (October 1st to current date)
- **Test Families:** 6 major POC vs Lab comparisons
- **Output Format:** Structured data suitable for analysis
- **Performance:** Optimized with temporary tables and indexing

### Validation Checklist
- [ ] Results contain your facility's data only
- [ ] Date ranges match fiscal year expectations
- [ ] Test result counts seem reasonable for your facility
- [ ] No error messages in execution output

## Optional: PowerBI Integration

### For Query Mode Users
1. Copy query results to Excel or CSV
2. Import into PowerBI Desktop
3. Create visualizations as needed

### For Stored Procedure Mode Users
1. Deploy stored procedure successfully
2. Connect PowerBI to database
3. Use DirectQuery to `[App].[LabTest_POC_Compare]`
4. Request PowerBI template: Kyle.Coder@va.gov

**PowerBI Connection String:**
```
Server: VhaCdwDwhSql33.vha.med.va.gov
Database: [Your facility's database]
Procedure: EXEC [App].[LabTest_POC_Compare]
```

## Troubleshooting

### Common Issues

**❌ "Access denied to CDWWork database"**
- ✅ Verify NDS Operational Access completion
- ✅ Check VA network connection
- ✅ Confirm database permissions

**❌ "Object name '[App].[LabTest_POC_Compare]' is invalid"**
- ✅ Ensure you're in stored procedure mode
- ✅ Verify procedure was created successfully
- ✅ Check database write permissions

**❌ "No results returned"**
- ✅ Verify your facility station number is correct
- ✅ Check if your facility has POC testing data
- ✅ Adjust date range if needed

**❌ Query runs too slowly**
- ✅ Limit date range for testing (modify @StartDate/@EndDate)
- ✅ Check database server performance
- ✅ Consider off-peak execution times

### Getting Help

1. **Technical Issues:** Check [TECHNICAL_GUIDE.md](TECHNICAL_GUIDE.md)
2. **Clinical Questions:** Review [CLINICAL_USER_GUIDE.md](CLINICAL_USER_GUIDE.md) 
3. **Security Concerns:** See [DATA_SECURITY_VERIFICATION.md](DATA_SECURITY_VERIFICATION.md)
4. **Contact Author:** Kyle.Coder@va.gov (VA email only)

### Next Steps
- [ ] Review results for clinical relevance
- [ ] Share findings with laboratory management
- [ ] Schedule regular analysis runs
- [ ] Request PowerBI template for ongoing use
- [ ] Consider facility-specific customizations

---

💡 **Pro Tip:** Start with Query Mode for initial testing, then deploy as Stored Procedure for production PowerBI integration.

🔒 **Security Note:** This tool processes PHI data. Ensure compliance with your facility's data handling policies.
DECLARE @FacilityStationNumber VARCHAR(10) = 'YOUR_STATION_NUMBER'  -- Replace with your facility's station number
DECLARE @StartDate DATE = '2024-01-01'  -- Adjust start date as needed
DECLARE @EndDate DATE = '2024-12-31'    -- Adjust end date as needed
```

### Step 4: Verify Test SIDs
Check that the test SIDs match your facility's configuration:

```sql
-- Common test SIDs (verify these match your system)
-- Glucose Tests
WHERE LabChemTestSID IN (
    '800000000025',  -- iSTAT Glucose
    '800000000058'   -- Chemistry Glucose
)
```

⚠️ **Important:** Test SIDs may vary between facilities. Verify these values with your laboratory or informatics team.

## First Run

### Execute the Main Query
1. **Select All Text:** Ctrl+A in SSMS
2. **Execute Query:** F5 or click Execute
3. **Review Results:** Check the Messages tab for row counts and execution time
4. **Verify Output:** Ensure results look reasonable for your facility

### Expected Output
The query will return:
- **Comparison Results:** Paired laboratory tests with time differences
- **Diagnostic Info:** Row counts and execution time in Messages tab
- **Filtered Data:** Only results within specified time windows

### Sample Results Format
```
PatientLastFourSSN | POC_TestName | POC_Result | POC_DateTime | Standard_TestName | Standard_Result | Standard_DateTime | TimeDifference_Minutes
1234              | iSTAT Glucose | 95        | 2024-01-15   | Chemistry Glucose | 98             | 2024-01-15       | 45
```

## Basic Configuration

### Time Windows
Adjust comparison time windows based on clinical requirements:

```sql
-- Time window configuration (in minutes)
DECLARE @GlucoseWindow INT = 60        -- 1 hour for glucose
DECLARE @CreatinineWindow INT = 240    -- 4 hours for creatinine
DECLARE @HematocritWindow INT = 120    -- 2 hours for hematocrit
-- Add other test windows as needed
```

### Date Range
Modify the analysis period:

```sql
DECLARE @StartDate DATE = '2024-01-01'  -- Start of analysis period
DECLARE @EndDate DATE = '2024-12-31'    -- End of analysis period
```

### Test Selection
Enable/disable specific test families by commenting/uncommenting sections:

```sql
-- To disable a test family, comment out its section:
/*
AND (
    -- Glucose Tests
    (poc.LabChemTestSID = '800000000025' AND standard.LabChemTestSID = '800000000058')
)
*/
```

## PowerBI Dashboard Setup

### Open the Dashboard
1. Open PowerBI Desktop
2. Open file: `Laboratory Testing POC Comparison.pbix`
3. Refresh data connections

### Configure Data Source
1. **Home Tab → Transform Data → Data Source Settings**
2. **Update Server:** Point to your SQL Server instance
3. **Update Database:** Point to your database
4. **Credentials:** Ensure proper authentication

### Refresh Data
1. **Home Tab → Refresh**
2. Wait for data refresh to complete
3. Verify charts populate with your facility's data

## Troubleshooting

### Common Issues

#### "Invalid object name" Error
**Problem:** SQL query references tables that don't exist
**Solution:** 
- Verify database name in connection
- Check table names match your schema
- Confirm you have read access to required tables

#### No Results Returned
**Problem:** Query runs but returns no data
**Solution:**
- Check date range (@StartDate and @EndDate)
- Verify facility station number
- Confirm test SIDs exist in your database
- Check if data exists for the specified time period

#### PowerBI Connection Issues
**Problem:** Cannot connect PowerBI to database
**Solution:**
- Verify SQL Server allows external connections
- Check firewall settings
- Confirm authentication credentials
- Test connection in SSMS first

#### Performance Issues
**Problem:** Query takes too long to execute
**Solution:**
- Reduce date range for initial testing
- Check database indexing on LabChemTestSID and dates
- Consider running during off-peak hours
- Review execution plan for optimization opportunities

### Getting Help
1. **Check Documentation:** Review README.md and other docs
2. **Search Issues:** Look for similar problems in GitHub issues
3. **Create Issue:** Submit a new issue with details
4. **Contact Support:** Use contact information in README.md

## Next Steps

### Validate Results
1. **Spot Check:** Manually verify a few comparison results
2. **Clinical Review:** Have laboratory staff review time windows
3. **Statistical Check:** Verify statistical calculations are reasonable

### Customize for Your Facility
1. **Add Test Types:** Add facility-specific test comparisons
2. **Adjust Time Windows:** Modify based on clinical protocols
3. **Enhance Reports:** Customize PowerBI dashboard for your needs

### Individual Test Queries
Try the specialized queries for specific test families:
- `LabPOC_Compare_Glucose(July2025).sql`
- `LabPOC_Compare_Creatinine(July2025).sql`
- `LabPOC_Compare_Hematocrit(July2025).sql`
- `LabPOC_Compare_Hemoglobin(July2025).sql`
- `LabPOC_Compare_Troponin(July2025).sql`
- `LabPOC_Compare_Urinalysis(July2025).sql`

### Advanced Configuration
1. **Review:** `ChatGPT_QueryImprovementRecommendations.md` for optimization ideas
2. **Implement:** Additional quality metrics or statistical analyses
3. **Integrate:** With existing laboratory information systems

### Share Results
1. **Export Data:** Use PowerBI export features for reports
2. **Schedule Refresh:** Set up automated data refresh in PowerBI Service
3. **Distribute Reports:** Share dashboards with laboratory leadership

---

## Quick Reference

### Key Files
- **Main Query:** `Laboratory POC Comparison (updated July 2025).sql`
- **PowerBI Dashboard:** `Laboratory Testing POC Comparison.pbix`
- **Documentation:** `README.md`, `PROJECT_ANALYSIS_AND_RECOMMENDATIONS.md`

### Key Configuration Variables
```sql
@FacilityStationNumber -- Your facility's station number
@StartDate            -- Analysis start date
@EndDate              -- Analysis end date
```

### Support Resources
- **Project Documentation:** All `.md` files in the root directory
- **GitHub Issues:** For bug reports and feature requests
- **Security Issues:** Follow `SECURITY.md` guidelines

---

**Ready to get started? Open the main SQL file and update your facility configuration!**
