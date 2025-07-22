# PowerBI License Protection and Attribution Embedding

## Overview

This document provides comprehensive methods for embedding MIT License protections and attribution information into PowerBI (.pbix) files to prevent unauthorized use and ensure proper credit attribution.

## Table of Contents
1. [Multiple Embedding Methods](#multiple-embedding-methods)
2. [Built-in PowerBI Metadata](#built-in-powerbi-metadata)
3. [Hidden Visual Elements](#hidden-visual-elements)
4. [Data Model Embedding](#data-model-embedding)
5. [Report Settings Protection](#report-settings-protection)
6. [Advanced Protection Methods](#advanced-protection-methods)
7. [Legal Considerations](#legal-considerations)
8. [Implementation Checklist](#implementation-checklist)

---

## Multiple Embedding Methods

### Strategy: Layer Multiple Protection Methods
To maximize protection against plagiarism and unauthorized use, implement multiple layers of license embedding:

1. **Visible Attribution** (can be removed)
2. **Hidden Visual Elements** (harder to find)
3. **Metadata Embedding** (requires technical knowledge to remove)
4. **Data Model Comments** (embedded in data structure)
5. **Measure Descriptions** (technical embedding)
6. **Report Properties** (administrative embedding)

---

## Built-in PowerBI Metadata

### 1. Report Properties and Metadata
**Access:** File → Options and Settings → Options → Current File → Report Settings

```
Report Title: Laboratory Testing POC Comparison Tool
Description: Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital. 
             Licensed under MIT License. Original source: https://github.com/your-repo
             Unauthorized use without attribution is prohibited.
Author: Kyle J. Coder, Edward Hines Jr. VA Hospital
Subject: Laboratory POC Comparison Analysis
Comments: This report is licensed under the MIT License. Redistribution requires 
          attribution to Kyle J. Coder and Edward Hines Jr. VA Hospital.
```

### 2. Dataset Properties
For each dataset in your model:
- **Dataset Name**: Include your attribution
- **Description**: Full MIT License text
- **Comments**: Contact information and original source

### 3. Custom Properties (Advanced)
Use PowerBI's custom properties feature:
```
Property Name: License
Value: MIT License - Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital

Property Name: OriginalAuthor  
Value: Kyle J. Coder, Clinical Informatics, Edward Hines Jr. VA Hospital

Property Name: SourceRepository
Value: https://github.com/your-username/laboratory-testing-poc-comparison

Property Name: RequiredAttribution
Value: This work must include attribution to Kyle J. Coder and Edward Hines Jr. VA Hospital
```

---

## Hidden Visual Elements

### 1. Transparent Text Boxes
Create text boxes with license information:
- Set background transparency to 100%
- Set font color to white or transparent
- Position behind other visuals
- Content: Full MIT License text

```
Text Content:
MIT License - Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital
Licensed under MIT License. Original work by Kyle J. Coder.
Contact: Kyle.Coder@va.gov
Repository: https://github.com/your-repo
Unauthorized use without proper attribution violates license terms.
```

### 2. Off-Canvas Elements
- Place text boxes outside the visible canvas area
- Use the selection pane to verify they exist but aren't visible
- Include comprehensive attribution information

### 3. Microscopic Visuals
- Create extremely small (1x1 pixel) text boxes
- Position in corners or overlapping existing visuals
- Fill with attribution text

---

## Data Model Embedding

### 1. Calculated Columns with Attribution
Create calculated columns that embed license information:

```DAX
LicenseInfo = "MIT License - Kyle J. Coder, Edward Hines Jr. VA Hospital - " & FORMAT(TODAY(), "YYYY-MM-DD")

Attribution = "Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital"

OriginalSource = "https://github.com/your-username/laboratory-testing-poc-comparison"
```

### 2. Measures with Hidden Attribution
Create measures that include license information in descriptions:

```DAX
-- Measure Name: _LICENSE_ATTRIBUTION_DO_NOT_REMOVE
-- Description: MIT License Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital
_LICENSE_ATTRIBUTION = "Kyle J. Coder, Edward Hines Jr. VA Hospital"

-- Hidden in report but embedded in model
License_Embedded = 
"This PowerBI report is licensed under MIT License. 
Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital.
Original source: https://github.com/your-repo
Removing this attribution violates license terms."
```

### 3. Table Comments and Descriptions
For every table in your data model:
- **Table Description**: Include MIT License text
- **Column Descriptions**: Scatter attribution across multiple columns
- **Relationship Comments**: Embed license information

---

## Report Settings Protection

### 1. Page-Level Protections
For each report page:
- **Page Name**: Include subtle attribution
- **Page Tooltip**: License information
- **Page Description**: Full attribution

### 2. Visual-Level Embedding
For each visual:
- **Title**: Subtle attribution
- **Subtitle**: License reference
- **Alt Text**: Full MIT License text
- **Tooltip**: Attribution information

Example:
```
Visual Title: "Glucose Comparison Analysis"
Subtitle: "© 2025 K. Coder, Hines VA"
Alt Text: "MIT License - Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital. 
          This visualization is part of the Laboratory Testing POC Comparison Tool. 
          Licensed under MIT License. Redistribution requires attribution."
```

---

## Advanced Protection Methods

### 1. Embedded Images with Metadata
- Create transparent watermark images with EXIF metadata containing license info
- Embed as report backgrounds or decorative elements
- EXIF data includes copyright and attribution

### 2. Custom Themes with Attribution
Create a custom theme file (.json) with embedded comments:
```json
{
  "name": "Laboratory POC Analysis Theme - MIT Licensed",
  "version": "1.0",
  "comment": "Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital",
  "dataColors": [...],
  "license": "MIT License - Kyle J. Coder"
}
```

### 3. Bookmarks with License Information
Create hidden bookmarks that contain license state:
- Name: "LICENSE_MIT_Kyle_Coder_Hines_VA"
- Display hidden visuals with attribution
- Include in bookmark navigation

### 4. Data Source Connection Strings
If using custom data connections, embed attribution in connection metadata:
```
Connection Name: "HinesVA_LabData_KyleCoder_MIT_Licensed"
Description: "Licensed under MIT License - Kyle J. Coder, Edward Hines Jr. VA Hospital"
```

---

## Legal Considerations

### 1. Copyright Notice Requirements
According to MIT License terms, include this exact text:
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
```

### 2. Contact Information
Always include:
- **Primary Contact**: Kyle.Coder@va.gov
- **Institution**: Edward Hines Jr. VA Hospital
- **Department**: Clinical Informatics
- **Original Repository**: [GitHub URL]

### 3. Usage Terms
Clearly state:
- Attribution requirements
- Commercial use permissions
- Modification allowances
- Distribution requirements

---

## Implementation Checklist

### ✅ Immediate Actions
- [ ] Add attribution to report properties
- [ ] Create hidden text boxes with license info
- [ ] Embed license in data model measures
- [ ] Add attribution to visual tooltips
- [ ] Include license in page descriptions

### ✅ Advanced Protection
- [ ] Create transparent watermarks
- [ ] Embed EXIF metadata in images
- [ ] Add license bookmarks
- [ ] Include attribution in custom themes
- [ ] Modify connection string names

### ✅ Verification Steps
- [ ] Export .pbix and verify embedded metadata
- [ ] Test that license info survives copy/paste operations
- [ ] Confirm attribution appears in model documentation
- [ ] Validate hidden elements are not easily discoverable
- [ ] Review all embedding locations for completeness

### ✅ Legal Protection
- [ ] Document all embedding locations
- [ ] Maintain records of original creation
- [ ] Save backup with timestamp and version info
- [ ] Consider digital signatures if available
- [ ] Keep detailed development logs

---

## Technical Implementation Guide

### Step 1: Metadata Embedding
```powershell
# PowerBI Desktop: File → Options and Settings → Options
# Navigate to: Current File → Report Settings
# Update all available metadata fields with attribution
```

### Step 2: Visual Element Creation
```
1. Insert → Text Box
2. Content: Full MIT License text
3. Format → General → Effects → Background → Transparency: 100%
4. Format → General → Effects → Border → None
5. Position behind existing visuals
6. Lock in place: Format → General → Properties → Lock objects
```

### Step 3: Data Model Modifications
```dax
-- Create licensing table
LICENSE_INFO = 
DATATABLE(
    "Property", STRING,
    "Value", STRING,
    {
        {"License", "MIT License"},
        {"Copyright", "Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital"},
        {"Author", "Kyle J. Coder"},
        {"Institution", "Edward Hines Jr. VA Hospital"},
        {"Department", "Clinical Informatics"},
        {"Contact", "Kyle.Coder@va.gov"},
        {"Repository", "https://github.com/your-repo"},
        {"CreatedDate", FORMAT(TODAY(), "YYYY-MM-DD")},
        {"LastModified", FORMAT(NOW(), "YYYY-MM-DD HH:MM:SS")}
    }
)
```

### Step 4: Verification Process
1. **Save and Reopen**: Verify persistence of embedded data
2. **Export to PDF**: Check if attribution appears
3. **Share with Colleague**: Test if metadata survives sharing
4. **Model Documentation**: Generate and review data model docs
5. **Performance Impact**: Ensure embedding doesn't affect performance

---

## Effectiveness Assessment

### High Effectiveness (Difficult to Remove)
- Data model structure embedding
- Measure descriptions and comments
- Table relationship metadata
- Custom property embedding

### Medium Effectiveness (Requires Technical Knowledge)
- Hidden visual elements
- Off-canvas text boxes
- Report metadata
- Bookmark embedding

### Lower Effectiveness (Easily Removable)
- Visible text attribution
- Page titles
- Visual titles/subtitles
- Theme names

---

## Maintenance and Updates

### Regular Review (Quarterly)
- Verify all embedding locations remain intact
- Update copyright years if necessary
- Check for new PowerBI features that support attribution
- Review and update contact information

### Version Control
- Document embedding locations for each version
- Maintain backup copies with full attribution
- Track any changes to embedded license information
- Preserve original creation timestamps

---

## Conclusion

By implementing multiple layers of license protection and attribution embedding, you significantly increase the difficulty for unauthorized users to remove all traces of your intellectual property rights. While no method is 100% foolproof, this comprehensive approach provides strong legal and technical protection for your PowerBI work.

**Remember**: The goal is not to prevent all possible theft, but to make it legally and technically difficult enough that most users will respect the license terms and provide proper attribution.

---

**Document Created**: July 22, 2025  
**Author**: Kyle J. Coder, Edward Hines Jr. VA Hospital  
**Purpose**: Intellectual Property Protection for PowerBI Reports  
**License**: MIT License (Same as source project)
