# SQL Deployment and PowerBI Template Request Guide

## 📋 **For VA Healthcare Facilities Only**

This guide is specifically designed for Veterans Affairs healthcare facilities implementing the Laboratory Testing POC Comparison tool using the SQL-first approach for maximum security and compliance.

## ⚠️ **Important: SQL-First Implementation Approach**

For security and compliance reasons, this project uses a **SQL-first implementation model**:
1. **Public Repository**: Contains SQL code and documentation only
2. **PowerBI Template**: Available by request through secure VA channels only
3. **User Verification**: Ensures proper VA permissions and data access controls

## 📋 **Required Steps for Implementation**

### **Step 1: Download SQL Files from GitHub**
1. Navigate to the GitHub repository: [Repository URL]
2. Download the following files:
   ```
   ├── Laboratory POC Comparison (updated July 2025).sql  # Main stored procedure
   ├── Other Documents/CDW Lab Test Names.sql            # Test SID lookup utility
   └── Other Documents/Individualized SQL Queries/       # Individual test queries
   ```
3. Save files to your local development environment

### **Step 2: Deploy SQL Solution to Your Facility's Database**
1. **Connect to your facility's SQL Server** with appropriate VA database permissions
2. **Execute the main stored procedure script**:
   ```sql
   -- File: "Laboratory POC Comparison (updated July 2025).sql"
   -- Ensure you have CREATE PROCEDURE permissions
   ```
3. **Verify successful deployment**:
   ```sql
   -- Check that procedure was created successfully
   SELECT name FROM sys.procedures WHERE name LIKE '%LabTestCompare%'
   ```

### **Step 3: Configure Facility-Specific Parameters**
1. **Update your facility station number** in the SQL code:
   ```sql
   DECLARE @FacilityStationNumber INT = 578;  -- CHANGE THIS to your facility number
   ```

2. **Identify your facility's test SIDs** using the lookup utility:
   ```sql
   -- Execute: "Other Documents/CDW Lab Test Names.sql"
   -- Update facility number and search for your test names
   ```

3. **Update test SIDs in the main procedure**:
   ```sql
   -- CRITICAL: Update these SIDs for your facility
   POC_GLUCOSE_SID: 1000068127 -> [YOUR_POC_GLUCOSE_SID]
   LAB_GLUCOSE_SID: 1000027461 -> [YOUR_LAB_GLUCOSE_SID]
   -- (Continue for all test families)
   ```

### **Step 4: Test SQL Implementation**
1. **Execute the stored procedure** with a small date range:
   ```sql
   -- Test with recent 1-week period
   EXEC [App].[usp_PBI_HIN_LabTestCompare]
   ```
2. **Verify results** contain appropriate data for your facility
3. **Check execution time** and performance
4. **Document any facility-specific adjustments needed**

### **Step 5: Request PowerBI Template (VA Email Required)**

### **Step 5: Request PowerBI Template (VA Email Required)**

**📧 Email Template Request Process:**

```
To: Kyle.Coder@va.gov
From: [Your Official VA Email Address]
Subject: PowerBI Template Request - Laboratory POC Comparison Tool

Dear Kyle,

I am requesting access to the PowerBI template for the Laboratory Testing POC Comparison tool for implementation at our facility.

Facility Information:
- Facility Name: [Your VA Medical Center Name]
- Station Number: [Your 3-digit station number]
- Contact: [Your name and title]
- VA Email: [Your official VA email]

Implementation Status:
☑️ Downloaded SQL files from GitHub repository
☑️ Successfully deployed stored procedures to our database
☑️ Configured facility-specific parameters and test SIDs
☑️ Tested SQL procedures with sample data
☑️ Verified appropriate database permissions and access

Intended Use:
- Primary stakeholders: [e.g., Laboratory management, Pathology department]
- Use case: [e.g., Monthly POC quality reviews, JCAHO compliance]
- Data scope: [e.g., Last 12 months, specific test families]

Security Acknowledgment:
I understand that this PowerBI template will be delivered via secure VA channels and 
must remain within VA network boundaries. Our facility will implement appropriate 
data security controls and user access restrictions.

Thank you for your assistance.

[Your name]
[Your title]
[Your facility]
[Your VA phone number]
```

**Expected Response Timeline:** 2-3 business days for template delivery via secure VA methods

### **Step 6: PowerBI Template Setup (After Receipt)**
1. **Receive template** via secure VA delivery method
2. **Open template** in PowerBI Desktop
3. **Configure data source** to connect to your deployed stored procedure:
   ```
   Data Source: Your facility's SQL Server
   Database: Your facility's database
   Stored Procedure: [App].[usp_PBI_HIN_LabTestCompare]
   Authentication: Windows Authentication (recommended)
   ```
4. **Test connection** and refresh data
5. **Customize branding** for your facility (logos, colors, facility name)
6. **Configure user access** and sharing permissions within VA network

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

## 🔒 **Security and Compliance Considerations**

### **VA Data Access Requirements**
- **CDW Access**: Ensure you have appropriate CDWWork database permissions
- **PHI Handling**: Follow all VA privacy and security protocols
- **User Authentication**: Use Windows Authentication for database connections
- **Network Security**: Keep all data within VA network boundaries

### **PowerBI Security Settings**
1. **Row-Level Security**: Configure for appropriate user access
2. **Data Refresh**: Set up secure, automated refresh schedules
3. **Sharing Permissions**: Limit access to authorized personnel only
4. **Export Controls**: Configure appropriate export restrictions

### **Ongoing Compliance**
- **Regular Reviews**: Quarterly review of user access and permissions
- **Updates**: Monitor for VA security policy changes
- **Documentation**: Maintain implementation and user access logs
- **Training**: Ensure users understand HIPAA and VA privacy requirements

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
