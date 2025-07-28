
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2016+-blue.svg)](https://www.microsoft.com/sql-server)
[![PowerBI](https://img.shields.io/badge/PowerBI-Available%20by%20Request-orange.svg)](mailto:Kyle.Coder@va.gov)

> **🏥 Healthcare Laboratory Quality Assurance Solution**  
> A comprehensive SQL Server solution for comparing Point-of-Care (POC) laboratory tests with traditional laboratory methods in healthcare settings, enabling systematic quality assurance and patient safety improvements.

## Overview

---

## **v1.9.0 Public Release**
This repository is now published as version 1.9.0, representing the full and final public release of the Laboratory Testing POC Comparison Tool. No major feature updates are planned going forward; only occasional data source maintenance or minor corrections will be made as needed. All documentation and code are standardized for open-source community use.

---

This tool enables laboratory management to systematically identify and investigate discrepancies between paired POC and traditional laboratory test results. Originally developed at Edward Hines Jr. VA Hospital, it provides automated analysis across six major test families with clinical time-window based comparisons.

**Primary Benefits:**
- **Patient Safety Enhancement** - Systematic discrepancy detection and investigation
- **Quality Assurance Automation** - Replaces manual comparison processes  
- **Executive Visibility** - PowerBI dashboard for laboratory performance monitoring
- **Clinical Integration** - Aligns with existing laboratory workflows and protocols
- **Evidence-Based QA** - Data-driven quality improvement initiatives

## Key Features

### Core Test Family Comparisons
- **Glucose** (Point-of-Collection vs Lab Drawn) - 30-minute comparison window
- **Creatinine** (iSTAT vs Lab Drawn) - 24-hour comparison window
- **Hematocrit** (iSTAT vs Lab Drawn) - 30-minute comparison window
- **Hemoglobin** (POC vs Lab Drawn) - 30-minute comparison window
- **Troponin** (iSTAT vs High-Sensitivity Lab Drawn) - 30-minute comparison window
- **Urinalysis** (Point-of-Collection vs Lab Collected) - 30-minute comparison window

### Advanced Capabilities
- **Statistical Analysis** - Automated discrepancy rate calculations and correlation patterns
- **Dual Operation Modes** - Query mode for direct analysis, stored procedure mode for PowerBI integration
- **Performance Monitoring** - Built-in execution time tracking and row count reporting
- **Cross-Facility Adaptability** - Parameterized design for implementation at multiple healthcare facilities
- **Security Compliance** - HIPAA-compliant data handling with VA certificate-based signing

## Implementation at VA Facilities

### Prerequisites
- **NDS Operational Access** for PHI/Real SSN data sources
- **SQL Server Access** to VhaCdwDwhSql33.vha.med.va.gov with VA credentials
- **Database Permissions** (read-only for basic queries, write access for stored procedures)
- **Facility Configuration** (station number and test SID mappings)

### Quick Implementation
👉 **[Follow the Complete Quick Start Guide](QUICK_START.md)** for step-by-step implementation instructions.

### PowerBI Template Access
For security compliance, the PowerBI template is distributed through secure VA channels only (due to sensitive data embedded within .pbix file):
- **VA Users**: Email Kyle.Coder@va.gov after deploying SQL components

## Repository Contents

```
📁 Core Files
├── [App].[LabTest_POC_Compare].sql              # Main analysis query/stored procedure
├── [dbo].[sp_SignAppObject].sql             # VA security signing procedure
└── Other Documents/CDW Lab Test Names.sql    # Test SID lookup utility

📚 Documentation
├── QUICK_START.md                           # Complete implementation guide
├── docs/TECHNICAL_GUIDE.md                  # Advanced deployment & configuration
├── docs/CLINICAL_USER_GUIDE.md              # Clinical workflow guidance
├── docs/CONTRIBUTING.md                     # Community contribution guidelines
├── SECURITY.md                              # Security policies & compliance
└── POWERBI_TEMPLATE_REQUEST.md              # PowerBI template request process

🔧 Individual Test Queries (Optional)
└── Other Documents/[Individual test comparison scripts for each test family]
```

## Technical Documentation

### For Implementation Teams
- **[Quick Start Guide](QUICK_START.md)** - Complete setup and deployment instructions
- **[Technical Guide](docs/TECHNICAL_GUIDE.md)** - Advanced configuration, stored procedure deployment, and PowerBI integration
- **[Security Documentation](SECURITY.md)** - Compliance requirements and data protection

### For Clinical Users  
- **[Clinical User Guide](docs/CLINICAL_USER_GUIDE.md)** - Workflow integration and result interpretation
- **[PowerBI Template Request](POWERBI_TEMPLATE_REQUEST.md)** - Process for accessing executive dashboard

### For Developers
- **[Contributing Guidelines](docs/CONTRIBUTING.md)** - Community contribution standards and healthcare-specific requirements

## Clinical Impact & Quality Assurance

### Why This Analysis Matters
Laboratory test discrepancies between POC and traditional methods can indicate:
- Equipment calibration issues requiring maintenance
- Sample collection methodology variations  
- Processing method discrepancies needing standardization
- Patient condition changes between sample collections
- Quality assurance opportunities for laboratory improvement

### Time Window Clinical Justification
Each test family uses clinically appropriate comparison windows based on:
- Physiological stability of the analyte
- Expected rate of change in patient conditions
- Sample degradation and processing considerations
- Laboratory medicine best practices and protocols

## Support & Community

### Primary Support
- **GitHub Issues** - Bug reports and feature requests
- **VA Internal** - Kyle.Coder@va.gov for VA-specific implementation support

### Contributing
We welcome contributions from the healthcare informatics community:
- Bug reports with clinical context
- Feature enhancements with clinical justification  
- Cross-facility implementation experiences
- Documentation improvements

See **[Contributing Guidelines](docs/CONTRIBUTING.md)** for detailed standards.

## License & Attribution

**License:** MIT License - see [LICENSE](LICENSE) file for details

**Primary Developer:** Kyle J. Coder, Clinical Informatics, Edward Hines Jr. VA Hospital  
**Project Requestor:** Carrie Carlson, Pathology and Laboratory Medicine Service  
**Institution:** Edward Hines Jr. VA Hospital (Station 578, VISN 12)

**Contact:** Kyle.Coder@va.gov  
**Version:** 1.9.0 (Public Release)  
**Last Updated:** July 28, 2025

---

**🏥 Ready to enhance laboratory quality assurance at your healthcare facility?**  
**Start with the [Quick Start Guide](QUICK_START.md) for complete implementation instructions.**

---
## 🚩 Main Analysis File: `[App].[LabTest_POC_Compare].sql`

> **This is the authoritative SQL file for all core logic, clinical rationale, and implementation standards.**
> - All documentation, technical guides, and user instructions are based on this file.
> - Always reference this file for the latest parameters, time windows, and clinical logic.
> - For any new deployments, enhancements, or troubleshooting, start with `[App].[LabTest_POC_Compare].sql`.
