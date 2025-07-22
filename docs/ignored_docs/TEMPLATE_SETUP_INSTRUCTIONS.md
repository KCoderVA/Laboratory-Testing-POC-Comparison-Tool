# PowerBI Template Setup Instructions

## ⚠️ **TEMPLATE FILE - NO REAL DATA INCLUDED**

This is a template PowerBI file that requires configuration with your own data sources to function properly.

## 📋 **Required Steps After Download**

### **Step 1: Initial Template Setup**
1. Download the template file: `Laboratory_POC_Comparison_TEMPLATE.pbix`
2. Open PowerBI Desktop
3. Open the template file
4. Verify you see "No data available" in all visuals (this confirms the template is clean)

### **Step 2: Configure Data Source Connection**
1. Click **"Transform Data"** in the ribbon
2. In Power Query Editor:
   - Go to **Data Source Settings**
   - You should see disconnected/empty data sources
3. Configure your SQL Server connection:
   ```
   Server: [YOUR_SQL_SERVER_NAME]
   Database: [YOUR_DATABASE_NAME]
   Authentication: [YOUR_AUTH_METHOD]
   ```

### **Step 3: Update Facility Parameters**
1. In Power Query Editor, look for **"Parameters"** in the left panel
2. Update the following parameters for your facility:
   ```
   Facility Number: [YOUR_FACILITY_STATION_NUMBER]
   Server Name: [YOUR_SQL_SERVER]
   Database Name: [YOUR_DATABASE]
   ```

### **Step 4: Configure Test SIDs (Critical)**
Your facility's test SIDs will be different from the template. You MUST update these:

1. Open the main query in Power Query Editor
2. Find the section with test SID declarations
3. Update with your facility's test SIDs:
   ```sql
   -- CHANGE THESE TO YOUR FACILITY'S TEST SIDS:
   POC_GLUCOSE_SID: [YOUR_POC_GLUCOSE_SID]
   LAB_GLUCOSE_SID: [YOUR_LAB_GLUCOSE_SID]
   ISTAT_CREATININE_SID: [YOUR_ISTAT_CREATININE_SID]
   LAB_CREATININE_SID: [YOUR_LAB_CREATININE_SID]
   -- (Continue for all test families)
   ```

### **Step 5: Test Connection**
1. Click **"Close & Apply"** in Power Query Editor
2. PowerBI will attempt to refresh the data
3. If successful, you should see your facility's data populate the visuals
4. If errors occur, verify your connection settings and test SIDs

## 🔍 **Finding Your Facility's Test SIDs**

Use the included utility to find your test SIDs:

### **Method 1: CDW Lab Test Names Utility**
1. Open `Other Documents/CDW Lab Test Names.sql`
2. Update the facility number to your facility
3. Run the query in SQL Server Management Studio
4. Search for tests containing keywords like:
   - "Glucose"
   - "Creatinine" 
   - "Hematocrit"
   - "Hemoglobin"
   - "Troponin"
   - "Urinalysis"

### **Method 2: Manual Query**
```sql
-- Example query to find test SIDs for your facility
SELECT DISTINCT 
    ls.LabChemTestSID,
    ls.LabChemTestName,
    ls.LOINC,
    COUNT(*) as TestCount
FROM [CDWWork].[Chem].[LabChem] lc
INNER JOIN [CDWWork].[Dim].[LabChemTest] ls ON lc.LabChemTestSID = ls.LabChemTestSID  
INNER JOIN [CDWWork].[SPatient].[SPatient] sp ON lc.PatientSID = sp.PatientSID
WHERE sp.Sta3n = [YOUR_FACILITY_NUMBER]
    AND ls.LabChemTestName LIKE '%Glucose%'
    AND lc.LabChemResultDateTime >= '2024-01-01'
GROUP BY ls.LabChemTestSID, ls.LabChemTestName, ls.LOINC
ORDER BY TestCount DESC
```

## ⚙️ **Advanced Configuration**

### **Date Range Settings**
The template is configured for the most recent fiscal year. To change:
1. In Power Query Editor, find the date range parameters
2. Update `@StartDate` and `@EndDate` as needed

### **Statistical Thresholds**
Modify the discrepancy percentage thresholds:
1. Look for measures containing "Threshold" in the name
2. Adjust percentage values based on your clinical protocols

### **Custom Branding**
1. Replace logos and facility names throughout the report
2. Update color schemes to match your organization
3. Modify report titles and headers

## 🔒 **Security Considerations**

### **Data Access Verification**
- Ensure you have appropriate permissions to access lab data
- Verify compliance with your facility's data access policies
- Confirm HIPAA and privacy requirements are met

### **Row-Level Security**
The template includes RLS templates. Configure for your environment:
```DAX
-- Example RLS rule (customize for your facility)
[FacilityStationNumber] = VALUE(USERNAME())
```

### **Data Refresh Security**
- Use service accounts with minimal required permissions
- Implement secure credential storage
- Set up appropriate refresh schedules

## ❗ **Troubleshooting Common Issues**

### **"No Data" After Configuration**
1. **Check Test SIDs**: Most common issue - verify test SIDs are correct for your facility
2. **Verify Date Range**: Ensure your date range contains actual test data
3. **Check Permissions**: Confirm you have access to the required tables
4. **SQL Connection**: Test your SQL connection independently

### **Performance Issues**
1. **Reduce Date Range**: Start with a smaller time period (1 month)
2. **Check Indexing**: Ensure proper indexes on PatientSID and test date columns
3. **Query Optimization**: Review execution plans for the underlying queries

### **Missing Test Families**
1. **Test SID Verification**: Some facilities may not have all test types
2. **Alternative Tests**: Look for similar test names or LOINC codes
3. **Custom Modifications**: Adapt queries for your facility's specific tests

## 📞 **Support and Additional Resources**

### **Primary Support**
- **Original Author**: Kyle J. Coder (Kyle.Coder@va.gov)
- **Institution**: Edward Hines Jr. VA Hospital
- **GitHub Repository**: [Link to repository]

### **Documentation References**
- **Main SQL Documentation**: See comments in `Laboratory POC Comparison (updated July 2025).sql`
- **Project Analysis**: Review `PROJECT_ANALYSIS_AND_RECOMMENDATIONS.md`
- **License Protection**: See `POWERBI_LICENSE_PROTECTION.md`

### **Community Support**
- **GitHub Issues**: Submit bug reports and feature requests
- **Healthcare Informatics Forums**: Professional community discussions
- **VA Informatics Network**: Internal VA resources and support

## ✅ **Setup Verification Checklist**

### **Before Going Live:**
- [ ] All test SIDs verified and updated
- [ ] Facility parameters configured correctly
- [ ] Data refresh successful with your facility's data
- [ ] All visuals displaying appropriate data (no test/sample data visible)
- [ ] Performance acceptable for your data volume
- [ ] Security and access controls properly configured
- [ ] Stakeholder review and approval completed

### **Ongoing Maintenance:**
- [ ] Regular data refresh schedule established
- [ ] Monitoring for performance issues
- [ ] Periodic review of test SID mappings
- [ ] Updates for clinical protocol changes
- [ ] License attribution maintained in all copies

---

**Template Created**: July 22, 2025  
**Author**: Kyle J. Coder, Edward Hines Jr. VA Hospital  
**License**: MIT License - Attribution Required  
**Version**: 2.0 Template Release
