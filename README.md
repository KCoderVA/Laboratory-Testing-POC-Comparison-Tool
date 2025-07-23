# Laboratory Testing POC Comparison Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2016+-blue.svg)](https://www.microsoft.com/sql-server)
[![PowerBI](https://img.shields.io/badge/PowerBI-Available%20by%20Request-orange.svg)](mailto:Kyle.Coder@va.gov)

> **📧 PowerBI Template Available by Request Only**  
> For security compliance, the PowerBI template (.pbix) is distributed through secure VA channels only.  
> **VA users**: Email Kyle.Coder@va.gov to request template after deploying SQL components.  
> **Non-VA users**: Use SQL files to create custom visualizations for your environment.

## Overview

A comprehensive SQL Server solution for comparing Point-of-Care (POC) laboratory tests with traditional laboratory methods in healthcare settings. This tool enables laboratory management to systematically identify and investigate discrepancies between paired test results, improving patient safety and laboratory quality assurance.

**Developed at:** Edward Hines Jr. VA Hospital, Clinical Informatics Department  
**Primary Use Case:** Detecting significant discrepancies between POC and traditional laboratory test results  
**Target Users:** Laboratory managers, pathology staff, clinical quality teams, healthcare informatics professionals

## 🚀 Quick Start

### Prerequisites (COMPLETE IN ORDER)

**🔐 Pre-requisite #1: NDS Operational Access**
- Gain "NDS Operational Access" to view PHI/Real SSN Access data sources
- Follow instructions at: https://vaww.vhadataportal.med.va.gov/Data-Access/Operations-Access
- ⚠️ **Note:** This link is only accessible on a secure VA network

**💻 Pre-requisite #2: SQL Software Interface**
Install and configure SQL software on your local machine:
- **Option A - VS Code:** Download from https://code.visualstudio.com/download
- **Option B - SQL Server Management Studio (SSMS):**
  - Submit OIT ticket via https://yourit.va.gov
  - Open VA Software Center: `softwarecenter:SoftwareID=ScopeId_16785680-02FE-4B9B-B358-62C5C20205D4/Application_a72f3f2b-d050-4637-9e32-8091ecda9e61`

**🔗 Pre-requisite #3: Database Connection**
- Use VS Code or SSMS to connect to CDW's Database Engine
- **Server Name:** `VhaCdwDwhSql33.vha.med.va.gov`
- **Authentication:** Use your VA-issued access credentials

**📊 Optional Pre-requisite #4: Database Write Access** *(Not required for basic query execution)*
- Gain read & write access to your facility's database on SQL33 server
- Contact your team's CDW owner (directory: https://dvagov.sharepoint.com/sites/OITBISL/SitePages/CDW-Site-Directory.aspx)
- Required only for stored procedure deployment and PowerBI online integration

### Implementation Steps

**📥 Step #1: Download SQL Files**
Download the main SQL file from this repository:
```
File: LabTest_POC_Compare_Analysis.sql
```

**🔧 Step #2: Open and Configure**
1. Open the SQL file with your configured VS Code or SSMS software
2. Modify the `@FacilityStationNumber` on line #285 to match your facility
3. Update LabChemTestSID values if needed for your facility's test identifiers

**▶️ Step #3: Execute Query**
Run the query in your SQL software interface (VS Code or SSMS):
- **Default Output:** CSV-like table results in query results window
- **PowerBI Integration:** Import query directly via DirectQuery (https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-use-directquery)

**🔧 Optional Step #4: Deploy as Stored Procedure**
Convert to database stored procedure for live PowerBI connection:
1. Follow instructions in SQL file to uncomment stored procedure lines
2. Deploy `[App].[LabTest_POC_Compare]` to your facility's database
3. Use `[dbo].[sp_SignAppObject]` for VA security compliance
4. See [TECHNICAL_GUIDE.md](docs/TECHNICAL_GUIDE.md) for detailed deployment instructions

**📊 Optional Step #5: PowerBI Template**
VA employees can request the PowerBI template (.pbix file):
- Email Kyle.Coder@va.gov from your VA email address
- Include your facility information and deployment confirmation
- Template provides user-friendly sorting and visualization of query results

### Basic File Structure

📁 **Project Files:**
```
├── LabTest_POC_Compare_Analysis.sql          # Main analysis query/procedure
├── [dbo].[sp_SignAppObject].sql             # VA security signing procedure
├── docs/
│   ├── QUICK_START.md                       # Simplified setup guide
│   ├── TECHNICAL_GUIDE.md                   # Detailed technical documentation
│   ├── CLINICAL_USER_GUIDE.md               # Clinical workflow guidance
│   └── DATA_SECURITY_VERIFICATION.md        # Security compliance documentation
├── Other Documents/
│   ├── CDW Lab Test Names.sql               # Helper to find your facility's test SIDs
│   ├── Individual test comparison scripts    # Separate queries for each test family
│   └── Source documentation files
└── Published Version/
    └── Laboratory POC Comparison (combined).sql  # Legacy combined version
```

🔧 **Configuration Variables:**
```sql
DECLARE @FacilityStationNumber INT = 578;  -- CHANGE THIS: Your facility number
DECLARE @StartDate DATETIME2(0) = [Auto-calculated fiscal year start]
DECLARE @EndDate DATETIME2(0) = [Current date]
```

📊 **Output Modes:**
- **Query Mode:** CSV-like results in SQL client (default)
- **Stored Procedure Mode:** `[App].[LabTest_POC_Compare]` for PowerBI integration

## 📊 Features

### Core Capabilities
- **Six Major Test Family Comparisons:**
  - Glucose (POC vs Lab) - 30-minute comparison window
  - Creatinine (iSTAT vs Lab) - 24-hour comparison window  
  - Hematocrit (iSTAT vs Lab) - 30-minute comparison window
  - Hemoglobin (POC vs Lab) - 30-minute comparison window
  - Troponin (iSTAT vs High Sensitivity) - 30-minute comparison window
  - Urinalysis (POC vs Microscopic) - 30-minute comparison window

### Advanced Features
- **Statistical Analysis:** Automated calculation of discrepancy rates and patterns
- **Performance Monitoring:** Built-in execution time tracking and row count reporting
- **PowerBI Integration:** Executive dashboard with automated refresh capabilities
- **Cross-Facility Adaptability:** Parameterized design for easy adaptation to other healthcare facilities
- **Clinical Context:** Time-window based comparisons aligned with clinical best practices

## 📁 Project Structure

```
Laboratory Testing POC Comparison/
├── README.md                                          # This documentation
├── .gitignore                                         # Git exclusions (archives, sensitive files)
├── Laboratory POC Comparison (updated July 2025).sql  # Main comprehensive stored procedure
├── POWERBI_TEMPLATE_REQUEST.md                       # How to request PowerBI template (VA only)
├── POWERBI_LICENSE_PROTECTION.md                     # Guide for embedding license in .pbix files
├── TEMPLATE_SETUP_INSTRUCTIONS.md                    # Setup guide for SQL deployment and PowerBI requests
├── DATA_SECURITY_VERIFICATION.md                     # Security considerations for VA implementations
├── Other Documents/
│   ├── CDW Lab Test Names.sql                        # Test SID lookup utility
│   └── Individualized SQL Queries/                   # Test-specific queries
│       ├── LabPOC_Compare_Glucose(July2025).sql
│       ├── LabPOC_Compare_Creatinine(July2025).sql
│       ├── LabPOC_Compare_Hematocrit(July2025).sql
│       ├── LabPOC_Compare_Hemoglobin(July2025).sql
│       ├── LabPOC_Compare_Troponin(July2025).sql
│       └── LabPOC_Compare_Urinalysis(July2025).sql
└── PROJECT_ANALYSIS_AND_RECOMMENDATIONS.md           # Comprehensive project analysis

Note: PowerBI template (.pbix) available by request from author via VA email only
```

## 🔧 Installation & Configuration

### Step 1: Download Project Files
```powershell
# Clone or download from GitHub
git clone https://github.com/[repository-url]
# OR download ZIP file from GitHub repository
```

### Step 2: SQL Database Setup
```sql
-- 1. Connect to your facility's SQL Server with appropriate VA permissions
-- 2. Execute the main stored procedure script on your database
-- File: "Laboratory POC Comparison (updated July 2025).sql"

-- 3. Configure facility-specific parameters
DECLARE @FacilityStationNumber INT = [YOUR_FACILITY_NUMBER];  -- CHANGE THIS
```

### Step 3: Test SID Configuration
```sql
-- Use the CDW Lab Test Names utility to identify your facility's test SIDs
-- File: "Other Documents/CDW Lab Test Names.sql"

-- Update the following SIDs in the main procedure for your facility:
-- POC_GLUCOSE: 1000068127 -> [YOUR_POC_GLUCOSE_SID]
-- LAB_GLUCOSE: 1000027461 -> [YOUR_LAB_GLUCOSE_SID]
-- (Repeat for all test families - see included documentation)
```

### Step 4: Request PowerBI Template
```
📧 Email Request Required (VA-to-VA Only):
   
To: Kyle.Coder@va.gov
Subject: PowerBI Template Request - Laboratory POC Comparison Tool

Include in your request:
- Your facility name and station number
- Intended use case and stakeholders
- Confirmation that SQL procedures are deployed
- Your VA email address for secure delivery

Response: Clean PowerBI template delivered via secure VA channels
```

### Step 5: PowerBI Connection Setup
```sql
-- After receiving PowerBI template:
-- 1. Open template in PowerBI Desktop
-- 2. Update data source connection to point to your facility's database
-- 3. Connect to your deployed stored procedure
-- 4. Refresh data to populate with your facility's results
-- 5. Customize facility-specific branding and parameters
```

## 💡 Usage Examples

### Run Complete Analysis (All Test Families)
```sql
-- Execute main stored procedure for comprehensive analysis
EXEC [App].[usp_PBI_HIN_LabTestCompare]
```

### Run Individual Test Analysis
```sql
-- Example: Glucose-only analysis
-- Use file: "LabPOC_Compare_Glucose(July2025).sql"
```

### Typical Output Structure
```
Patient_ID | POC_Result | Lab_Result | Time_Difference | Discrepancy_Percentage | Clinical_Significance
-----------|------------|------------|-----------------|----------------------|----------------------
****1234   | 120        | 95         | 15 minutes      | 26.3%                | High
****5678   | 89         | 92         | 8 minutes       | 3.4%                 | Low
```

## 🏥 Clinical Context

### Why This Analysis Matters
Laboratory test discrepancies between POC and traditional methods can indicate:
- **Patient condition changes** between sample collections
- **Equipment calibration issues** requiring maintenance
- **Sample collection methodology** variations
- **Processing method discrepancies** needing standardization
- **Quality assurance opportunities** for laboratory improvement

### Time Window Rationale
| Test Family | Comparison Window | Clinical Justification |
|------------|------------------|------------------------|
| Glucose | 30 minutes | Rapid changes due to metabolism, meals |
| Creatinine | 24 hours | Stable marker, slower physiological changes |
| Hematocrit | 30 minutes | Blood volume sensitive, rapid changes possible |
| Hemoglobin | 30 minutes | Similar to hematocrit, hemolysis concerns |
| Troponin | 30 minutes | Cardiac marker, time-sensitive for diagnosis |
| Urinalysis | 30 minutes | Sample degradation, bacterial growth concerns |

## 📈 Performance & Scalability

### Expected Performance
- **Data Volume:** 10,000-50,000 test results per fiscal year
- **Execution Time:** 2-5 minutes for full analysis
- **Memory Usage:** Optimized with temporary tables and indexes
- **Scalability:** Tested with datasets up to 100,000+ records

### Optimization Features
- **Clustered indexes** on PatientSID for efficient joins
- **Date range filtering** applied early for performance
- **Temporary table strategy** minimizing memory footprint
- **Query hints** for large dataset optimization

## 🔒 Security & Privacy

### Data Protection
- **PHI Handling:** Only last-4 SSN digits for patient identification
- **Anonymized Output:** No direct patient identifiers in results
- **Parameterized Queries:** SQL injection prevention
- **Access Control:** Stored procedure-based security model

### Compliance Features
- **HIPAA Compliance:** Appropriate handling of protected health information
- **Audit Trail:** Built-in logging for data access tracking
- **Role-Based Access:** Database-level security implementation

## 🛠️ Customization & Extension

### Adapting to Your Facility
1. **Update facility parameters** in configuration section
2. **Identify local test SIDs** using the CDW lookup utility
3. **Adjust time windows** based on clinical protocols
4. **Modify statistical thresholds** for discrepancy detection

### Adding New Test Families
```sql
-- Template for adding new test comparisons
-- 1. Identify POC and Lab test SIDs
-- 2. Define appropriate comparison time window
-- 3. Add test family section to main procedure
-- 4. Create individual test query file if needed
```

### PowerBI Customization
- **Facility Branding:** Update logos, colors, facility name
- **Clinical Thresholds:** Adjust alert levels for your protocols
- **Additional Visualizations:** Extend dashboard with facility-specific charts
- **Mobile Optimization:** Configure for tablet/mobile access

### PowerBI Template Access
**🔒 VA Security Approach:**

For security and compliance reasons, the PowerBI template (.pbix file) is **not included in this public repository**. Instead, VA facilities can access the template through secure internal channels.

**📧 How to Request PowerBI Template:**
1. **Deploy SQL Solution First**: Complete SQL setup using files from this repository
2. **Email Request**: Contact Kyle.Coder@va.gov (VA-to-VA email required)
3. **Include in Request**:
   - Your facility name and station number
   - Confirmation that SQL procedures are deployed and tested
   - Intended use case and stakeholders
   - Your official VA email address
4. **Secure Delivery**: Clean template delivered via secure VA internal methods

**Why This Approach:**
- **Data Security**: Eliminates risk of sensitive data exposure in public repositories
- **VA Compliance**: Maintains appropriate security controls for healthcare data
- **User Verification**: Ensures users have proper VA access and permissions
- **Support Quality**: Enables direct communication for implementation assistance

### PowerBI License Protection
**⚠️ For Internal VA Distribution:**

When sharing PowerBI files within the VA network, implement the attribution protection methods documented in `POWERBI_LICENSE_PROTECTION.md` to ensure proper credit and license compliance.

**Quick Implementation for VA Users:**
1. Download SQL files from this GitHub repository
2. Deploy stored procedures on your facility's database with appropriate VA permissions
3. Configure facility parameters (station number, test SIDs) in the SQL code
4. Email Kyle.Coder@va.gov to request PowerBI template via secure VA channels
5. Connect PowerBI template to your deployed stored procedure and refresh data

## 🧪 Testing & Validation

### Data Quality Checks
```sql
-- Built-in validation features:
-- ✅ Facility number verification
-- ✅ Date range validation  
-- ✅ Test SID existence checks
-- ✅ Data completeness validation
-- ✅ Statistical outlier detection
```

### Recommended Testing Approach
1. **Start with small date range** (1 week) for initial testing
2. **Validate known clinical scenarios** against expected results
3. **Compare with existing quality metrics** if available
4. **Gradually expand to full fiscal year** analysis

## 🔄 Maintenance & Updates

### Regular Maintenance Tasks
- **Quarterly:** Validate test SID mappings for accuracy
- **Monthly:** Review performance metrics and optimization
- **Weekly:** Monitor data quality and completeness
- **Daily:** Verify PowerBI dashboard refresh status

### Version Control Strategy
- **Semantic Versioning:** Major.Minor.Patch (e.g., 2.1.3)
- **Change Documentation:** Maintain changelog for all updates
- **Rollback Procedures:** Keep previous versions for emergency rollback
- **Testing Protocol:** Validate all changes in non-production environment

## 🤝 Contributing

### Community Contributions Welcome
- **Bug Reports:** Submit issues with detailed reproduction steps
- **Feature Requests:** Propose enhancements with clinical justification
- **Code Contributions:** Submit pull requests with proper documentation
- **Documentation Improvements:** Help expand user guides and examples

### Development Guidelines
- **Code Standards:** Follow existing T-SQL formatting and commenting
- **Testing Requirements:** Include validation for all new features
- **Documentation:** Update README and inline comments for changes
- **Clinical Validation:** Ensure changes align with healthcare best practices

## 📚 Additional Resources

### Documentation
- **PROJECT_ANALYSIS_AND_RECOMMENDATIONS.md:** Comprehensive technical analysis
- **POWERBI_TEMPLATE_REQUEST.md:** How to request PowerBI template via secure VA channels
- **POWERBI_LICENSE_PROTECTION.md:** Complete guide for embedding license protection in .pbix files
- **TEMPLATE_SETUP_INSTRUCTIONS.md:** Step-by-step guide for SQL deployment and template requests
- **DATA_SECURITY_VERIFICATION.md:** Security considerations and compliance requirements
- **Inline SQL Comments:** Detailed code documentation throughout all files

### Support & Community
- **GitHub Issues:** Primary support channel for bug reports and questions
- **Healthcare Informatics Forums:** Professional community discussions
- **Clinical Informatics Networks:** Healthcare-specific implementation guidance

### Related Projects
- **Laboratory Quality Assurance:** Similar tools for lab quality management
- **Clinical Data Analytics:** Healthcare informatics best practices
- **SQL Server Healthcare Solutions:** Database optimization for healthcare

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👥 Authors & Acknowledgments

**Primary Developer:** Kyle J. Coder  
**Role:** Program Analyst, Clinical Informatics  
**Institution:** Edward Hines Jr. VA Hospital (Station 578, VISN 12)  
**Contact:** Kyle.Coder@va.gov

**Project Requestor:** Carrie Carlson  
**Department:** Pathology and Laboratory Medicine Service  
**Contact:** Carrie.Carlson@va.gov

**Special Acknowledgments:**
- Foundational analysis concepts from previous work by Nik Ljubic (Milwaukee VAMC)
- Edward Hines Jr. VA Hospital Clinical Informatics Team
- Pathology and Laboratory Medicine Service staff
- Healthcare informatics community for best practices guidance

---

**Project Initiated:** February 10, 2025  
**Project Completed:** March 21, 2025  
**Last Updated:** July 22, 2025  
**Version:** 1.8.0 (Production Release)

**GitHub Repository:** Ready for immediate publication  
**Documentation Status:** Complete and comprehensive  
**Community Readiness:** Approved for open-source release
