# Quick Start Guide

Welcome to the Laboratory Testing POC Comparison project! This guide will help you get up and running quickly.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [First Run](#first-run)
- [Basic Configuration](#basic-configuration)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)

## Prerequisites

### Required Software
- **SQL Server 2016 or later** (or Azure SQL Database)
- **PowerBI Desktop** (latest version recommended)
- **SQL Server Management Studio (SSMS)** or Azure Data Studio

### Required Access
- **Database Access:** Read access to laboratory data tables
- **Facility Information:** Your facility's station number
- **Test Data:** Access to laboratory test results for analysis

### Recommended Knowledge
- Basic SQL query knowledge
- Understanding of laboratory operations
- Familiarity with PowerBI (for dashboard use)

## Quick Setup

### Step 1: Download the Project
```bash
# Clone the repository
git clone https://github.com/[username]/laboratory-testing-poc-comparison.git
cd laboratory-testing-poc-comparison
```

### Step 2: Database Connection
1. Open SQL Server Management Studio
2. Connect to your database server
3. Open the main SQL file: `Laboratory POC Comparison (updated July 2025).sql`

### Step 3: Configure Facility Settings
Edit the configuration section at the top of the SQL file:

```sql
-- =============================================
-- FACILITY CONFIGURATION
-- =============================================
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
