# Laboratory Testing POC Comparison Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2016+-blue.svg)](https://www.microsoft.com/en-us/sql-server)
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

### Prerequisites
- SQL Server 2016+ or Azure SQL Database with VA data access
- VA network access and appropriate database permissions
- PowerBI Desktop (for dashboard visualization after SQL setup)
- Healthcare data warehouse with laboratory test data
- Administrative access to create stored procedures on your facility's database

### Implementation Steps
1. **Download Project Files** from GitHub repository
2. **Deploy SQL Solution** using the provided stored procedure files
3. **Configure Facility Parameters** in the SQL code for your station
4. **Request PowerBI Template** from project author via VA email
5. **Connect PowerBI** to your newly created stored procedure

### Basic Setup
1. **Download the SQL files** from this GitHub repository:
   ```
   - Laboratory POC Comparison (updated July 2025).sql (Main procedure)
   - Individual test family queries in Other Documents/
   - CDW Lab Test Names.sql (for finding your test SIDs)
   ```

2. **Deploy to your VA database** with appropriate permissions:
   ```sql
   -- Execute the main stored procedure script on your facility's database
   -- File: "Laboratory POC Comparison (updated July 2025).sql"
   ```

3. **Configure your facility parameters** in the SQL code:
   ```sql
   DECLARE @FacilityStationNumber INT = 578;  -- CHANGE THIS: Your facility number
   ```

4. **Request PowerBI template** from the author:
   - **Contact**: Kyle.Coder@va.gov (VA-to-VA email only)
   - **Include**: Your facility name, station number, and intended use
   - **Receive**: Clean PowerBI template file via secure VA channels

5. **Connect PowerBI to your stored procedure** and refresh data

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
**Version:** 2.0 (Production Release)

**GitHub Repository:** Ready for immediate publication  
**Documentation Status:** Complete and comprehensive  
**Community Readiness:** Approved for open-source release
