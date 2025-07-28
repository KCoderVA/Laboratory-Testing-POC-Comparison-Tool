
# Data Security Verification Checklist


> **Reference Standard:** All security verification and checklist items in this document are based on the workflow, logic, and standards defined in `[App].[LabTest_POC_Compare].sql`. For any security review, validation, or public release, always reference this file as the authoritative source.

---

## **v1.9.0 Public Release**
This data security verification checklist is current as of the v1.9.0 public release. No major feature updates are planned; only occasional data source maintenance or minor corrections will be made as needed. All security verification steps are standardized for open-source use.

---

## ⚠️ **CRITICAL: Complete This Checklist Before Public Release**

This checklist ensures your PowerBI template is completely free of sensitive data before GitHub publication.

## 📋 **Pre-Release Security Verification**

### **Phase 1: Visual Inspection (5 minutes)**
- [ ] **Open Template File**: Load the .pbix file in PowerBI Desktop
- [ ] **Check All Report Pages**: Navigate through every page of the report
- [ ] **Verify No Real Data**: Confirm all visuals show "No data available" or sample data only
- [ ] **Check Slicers/Filters**: Verify dropdowns contain no real patient IDs, dates, or facility info
- [ ] **Review Tooltips**: Hover over visuals to ensure no sensitive data in tooltips
- [ ] **Check Report Title**: Verify title doesn't contain facility-specific identifiers

### **Phase 2: Data Model Inspection (10 minutes)**
- [ ] **Model View**: Switch to Model view in PowerBI Desktop
- [ ] **Check All Tables**: Click on each table and verify "Data" shows no sensitive rows
- [ ] **Review Column Names**: Ensure no column names contain facility-specific codes
- [ ] **Check Relationships**: Verify relationship names don't contain sensitive info
- [ ] **Review Measures**: Check measure definitions for hardcoded sensitive values
- [ ] **Inspect Calculated Columns**: Verify no real data in calculated column formulas

### **Phase 3: Power Query Editor Inspection (15 minutes)**
- [ ] **Open Power Query**: Click "Transform Data" to open Power Query Editor
- [ ] **Check Data Preview**: Verify all query previews show no sensitive data
- [ ] **Review M Code**: Examine M code for each query looking for:
  - [ ] Hardcoded server names with facility identifiers
  - [ ] Real database names
  - [ ] Patient identifiers or SSNs
  - [ ] Actual facility numbers or station codes
  - [ ] Real date ranges from your facility
- [ ] **Check Parameters**: Verify parameters contain only placeholder values
- [ ] **Review Connection Strings**: Ensure no real server/database info embedded

### **Phase 4: Metadata and Properties (5 minutes)**
- [ ] **File Properties**: File → Options and Settings → Options → Current File
  - [ ] Verify report properties contain no sensitive facility info
  - [ ] Check that description includes template language
  - [ ] Confirm author info is appropriate for public release
- [ ] **Dataset Properties**: Check each dataset for sensitive metadata
- [ ] **Visual Properties**: Spot-check visual properties for embedded sensitive data

### **Phase 5: Export Testing (10 minutes)**
- [ ] **Export to PDF**: File → Export → Export to PDF
  - [ ] Review entire PDF for any sensitive data
  - [ ] Check that export shows template/sample data only
- [ ] **Export Data**: Try exporting data from a visual
  - [ ] Verify exported data contains no sensitive information
- [ ] **PowerPoint Export**: Test export to PowerPoint if applicable

### **Phase 6: Technical Deep Dive (15 minutes)**
- [ ] **Save and Reopen**: Save file, close PowerBI, reopen
  - [ ] Verify no cached data appears after reopening
- [ ] **Data Source Settings**: Check File → Options and Settings → Data source settings
  - [ ] Confirm all data sources are disconnected or parameterized
  - [ ] Verify no cached credentials with facility info
- [ ] **Recent Sources**: Check if any recent sources contain sensitive paths
- [ ] **Bookmarks**: Review all bookmarks for cached sensitive states
- [ ] **Selection Pane**: Use selection pane to check for hidden visuals with data

## 🔍 **Specific Items to Look For**

### **Patient Information:**
- [ ] Patient names (full or partial)
- [ ] SSNs or patient identifiers (even last 4 digits beyond sample format)
- [ ] Birth dates or ages
- [ ] Contact information
- [ ] Real admission/discharge dates

### **Facility Information:**
- [ ] Actual server names or IP addresses
- [ ] Real database names
- [ ] Facility station numbers (beyond template examples)
- [ ] Department codes or names
- [ ] Staff names or login IDs
- [ ] Network paths or shared drive locations

### **Clinical Data:**
- [ ] Real lab test results
- [ ] Actual medication names or codes
- [ ] Procedure codes or names
- [ ] Provider names or NPIs
- [ ] Real clinical notes or comments

### **Technical Information:**
- [ ] Connection strings with production info
- [ ] Query parameters with real values
- [ ] Error messages containing sensitive paths
- [ ] Cached query results in Power Query
- [ ] Temporary table names with facility codes

## 🚨 **Red Flags - Stop and Clean Immediately**

If you find ANY of the following, STOP and clean the template:

- **Real Patient Data**: Any actual patient identifiers or clinical results
- **Production Connections**: Live connections to production databases
- **Facility Codes**: Real facility numbers, station codes, or identifiers
- **Staff Information**: Employee names, usernames, or contact info
- **Network Information**: Real server names, IP addresses, or network paths
- **Date Ranges**: Actual date ranges from your facility's data

## ✅ **Final Verification Steps**

### **Independent Review:**
- [ ] **Colleague Review**: Have a colleague review the template independently
- [ ] **Fresh Eyes**: Ask someone unfamiliar with the project to review
- [ ] **Technical Review**: Have IT/Security review if required

### **Testing with Clean Environment:**
- [ ] **Clean Computer**: Test template on computer without access to production data
- [ ] **New User Account**: Test with account that has no facility data access
- [ ] **Offline Testing**: Test template completely offline

### **Documentation:**
- [ ] **Verification Log**: Document who reviewed and when
- [ ] **Issues Found**: Log any sensitive data found and how it was cleaned
- [ ] **Sign-off**: Get appropriate approvals for public release

## 🔐 **Additional Security Measures**

### **Template Naming:**
- [ ] **Clear Template Name**: Filename clearly indicates it's a template
- [ ] **Version Control**: Include version number in template name
- [ ] **NO_DATA Indicator**: Consider adding "NO_DATA" to filename

### **Repository Preparation:**
- [ ] **Separate Template Folder**: Create dedicated /templates/ folder
- [ ] **Clear Documentation**: Include setup instructions and security notes
- [ ] **License Protection**: Ensure license attribution is embedded per protection guide

### **Post-Release Monitoring:**
- [ ] **Download Test**: Download from GitHub and verify it's clean
- [ ] **User Feedback**: Monitor for reports of sensitive data exposure
- [ ] **Regular Review**: Periodically re-verify template cleanliness

## 📞 **Emergency Response Plan**

### **If Sensitive Data Found After Release:**
1. **Immediate Action**: Remove file from public repository immediately
2. **Assessment**: Document what sensitive data was exposed
3. **Notification**: Inform appropriate privacy/security teams
4. **Remediation**: Create completely clean template
5. **Re-verification**: Complete full security review before re-release

## 📝 **Verification Sign-off**

**Security Reviewer**: _________________________ **Date**: _____________  
**Technical Reviewer**: ________________________ **Date**: _____________  
**Project Owner**: _____________________________ **Date**: _____________  

**Final Approval for Public Release**: ✅ / ❌

**Comments/Issues Found:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

**Document Created**: July 22, 2025  
**Author**: Kyle J. Coder, Edward Hines Jr. VA Hospital  
**Purpose**: Data Security Verification for Public Template Release  
**Classification**: Security Checklist - Internal Use
