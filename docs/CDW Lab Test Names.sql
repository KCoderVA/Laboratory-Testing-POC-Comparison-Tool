
/*
===============================================================================
USAGE LICENSE:
===============================================================================
    MIT License

    Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital

    --------------------------------------------------------------------------
    v1.9.0 PUBLIC RELEASE (2025-07-28)
    This file is published as part of the full public release (v1.9.0) of the Laboratory Testing POC Comparison Tool. No major feature updates are planned; only occasional data source maintenance or minor corrections will be made as needed. All logic, workflow, and documentation are standardized for open-source use.
    --------------------------------------------------------------------------

    RECOMMENDED FILENAME: CDW_Lab_Test_Names.sql

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

-- =========================================================================
-- PROJECT/BUSINESS INFORMATION:
-- =========================================================================
    Project Title:   Laboratory Point-Of-Collection Comparison
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
    
    DEVELOPMENT INFORMATION:
        Primary Developer: Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-28 (Current Version)
        Version History:   See main project file for full versioning
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        SQL Dialect:       T-SQL (Microsoft SQL Server)

    PROJECT PURPOSE:
        This query provides a reference lookup of all laboratory test definitions
        (LabChemTest) for the Laboratory Point-Of-Collection Comparison project.
        It is intended to help users identify, validate, and map LabChemTestSID values
        for use in clinical analytics, reporting, and solution implementation.

    IMPLEMENTATION GUIDANCE FOR OTHER FACILITIES:
        • Update the [Sta3n] filter to your facility's station number as needed
        • Update or expand the LabChemTestSID list to match your local test identifiers
        • Use this query to validate test names, codes, and mappings for your implementation
        • For full project setup, see:
          https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/README.md

    SCOPE:
        Returns metadata for selected laboratory tests relevant to POC vs Lab comparison
        for Edward Hines Jr. VA Hospital (Station 578). Can be adapted for other facilities.

    DELIVERABLES:
        1. Lab test name reference query (this file)
        2. Main comparison stored procedure ([App].[LabTest_POC_Compare].sql)
        3. PowerBI Report Dashboard
        4. Documentation Package
        5. Implementation Guide for other VA facilities

    COMPLETE SOLUTION REPOSITORY:
        GitHub Repository: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool
        Implementation Guide: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/TEMPLATE_SETUP_INSTRUCTIONS.md
        PowerBI Template Request: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/POWERBI_TEMPLATE_REQUEST.md
        Security Documentation: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/DATA_SECURITY_VERIFICATION.md

    TECHNICAL SPECIFICATIONS:
        Platform:          Microsoft SQL Server (T-SQL)
        Compatible Versions: SQL Server 2016 Enterprise and higher
        Database Engine:   Microsoft SQL Server (minimum version 13.0)
        Language Version:  T-SQL (Transact-SQL)
        Required Features: Standard SQL SELECT, filtering, and ordering
        Security Level:    VA-compliant, HIPAA-compliant, PHI-protected

    DATA INTEGRATION POINTS:
        Dependencies:      CDWWork.Dim.LabChemTest (Lab test definitions)
        Used by:           Main comparison procedure, PowerBI dashboard, and documentation

    PERFORMANCE CHARACTERISTICS:
        Performance:       Fast lookup for test metadata; no large data movement
        Output Format:     Tabular metadata for reference and mapping

    COMPLIANCE REQUIREMENTS:
        • VA Directive 6500: Information Security Program
        • VA Handbook 5200.08: Privacy and Release of Information
        • HIPAA Privacy Rule: Protected Health Information handling
        • FISMA Controls: Federal security assessment requirements

    Lab Test SIDs Used:
        1000068127 (POC Glucose), 1000027461 (Lab Glucose)
        1000114340 (iSTAT Creatinine), 1000062823 (Lab Creatinine)
        1000114341 (iSTAT Hematocrit), 1000048470 (Lab Hematocrit)
        1000114342 (iSTAT Hemoglobin), 1000036429 (Lab Hemoglobin)
        1000113247 (iSTAT Troponin), 1600022143 (High Sensitivity Troponin I)
        1000122927 (POC Urinalysis), 1000153039 (UA W/ MICROSCOPIC-iQ)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        Special recognition to the Edward Hines Jr. VA Hospital Clinical Informatics
        team for their expertise in laboratory data analysis and quality improvement.

===============================================================================
    TROUBLESHOOTING & VALIDATION:
===============================================================================
    COMMON IMPLEMENTATION ISSUES:
    1. Data Source Access: Verify CDWWork database permissions and connection
    2. Test SID Mapping: Confirm lab test SIDs match your facility's configuration
    3. Output Validation: Spot-check test names and codes for accuracy

    SUPPORT & MAINTENANCE:
    For technical support, implementation guidance, or feature requests:
    • GitHub Issues: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/issues
    • Documentation: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/wiki
    • VA Clinical Informatics: Contact your local Clinical Informatics team

===============================================================================
*/

-- ===================================================================================================
-- LAB TEST NAME REFERENCE QUERY
-- ===================================================================================================
--
-- PURPOSE: Extract and display metadata for selected laboratory tests used in the
--          Laboratory Point-Of-Collection Comparison project. This query is intended
--          for reference, mapping, and validation of LabChemTestSID values and names.
--
-- METHODOLOGY:
-- • Filters for a specific VA facility (Sta3n = 578 by default)
-- • Returns all key metadata fields for selected LabChemTestSID values
-- • Can be adapted for other facilities or expanded for additional tests
--
-- PERFORMANCE CONSIDERATIONS:
-- • Designed for fast metadata lookup; not intended for large-scale data extraction
-- • No functional changes should be made to the SELECT or WHERE clauses without validation
-- ===================================================================================================

-- ===================================================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- ===================================================================================================
--
-- PURPOSE: Initialize SQL Server environment settings and declare procedure-level variables
--          for consistent execution across different SQL Server instances and user sessions.
--
-- TECHNICAL NOTES:
-- • ANSI_NULLS ON: Ensures NULL comparisons follow ANSI SQL standards (NULL = NULL returns UNKNOWN)
-- • QUOTED_IDENTIFIER ON: Enables double-quoted identifiers for object names (ANSI SQL compliance)
-- • SET STATISTICS: Provides detailed execution time and I/O statistics for performance monitoring
-- • Facility Station Parameter: Configurable for multi-facility implementations
-- • Date Range Logic: Automatically calculates fiscal year-to-date (October 1st to current date)
-- ===================================================================================================
        -- Controls how SQL Server handles NULL value comparisons and string concatenations with NULLs
        -- When ON: NULL comparisons always return UNKNOWN, preventing unexpected results in WHERE clauses
                SET ANSI_NULLS ON
                GO
        -- Controls how SQL Server interprets quoted identifiers (table/column names in double quotes)
        -- When ON: Double quotes identify object names, single quotes identify string literals (ANSI SQL standard)
                SET QUOTED_IDENTIFIER ON
                GO

        -- ===========================================================================================
        -- DEPLOYMENT MODE CONFIGURATION: QUERY vs STORED PROCEDURE
        -- ===========================================================================================
        -- 
        -- This section controls whether the code executes as:
        -- A) Direct Query Mode: Results displayed in query results window as CSV-like output
        -- B) Stored Procedure Mode: Code deployed as a reusable database procedure
        --
        -- *** IMPORTANT: Both CREATE/ALTER and END sections must be modified together! ***
        --
        -- TO ACTIVATE STORED PROCEDURE MODE:
        -- 1. UNCOMMENT the following 4 lines below by removing the leading "--" characters:
        --    • CREATE OR ALTER PROCEDURE [App].[LabTest_POC_Compare]
        --    • AS 
        --    • BEGIN
        --    • EXEC dbo.sp_SignAppObject [LabTest_POC_Compare]
        -- 2. SCROLL TO THE END of this file and UNCOMMENT the "END" statement 
        --    (search for "-- END" near the bottom of the file)
        -- 3. OPTIONALLY: Comment out the variable declarations below (lines 280-290) and 
        --    add parameters to the procedure header instead for more flexibility
        --
        -- TO REVERT TO DIRECT QUERY MODE:
        -- 1. COMMENT OUT the 4 lines below by adding "--" at the beginning of each line
        -- 2. SCROLL TO THE END of this file and COMMENT OUT the "END" statement
        --    (add "--" before "END" near the bottom of the file)
        -- 3. UNCOMMENT the variable declarations if they were commented out
        --
        -- STORED PROCEDURE DEPLOYMENT WORKFLOW:
        -- 1. Test in Direct Query Mode first to validate results
        -- 2. Switch to Stored Procedure Mode for production deployment  
        -- 3. Execute the modified code to CREATE the stored procedure in the database
        -- 4. Sign the procedure using: EXEC dbo.sp_SignAppObject 'LabTest_POC_Compare'
        -- 5. Grant execution permissions to PowerBI service account and end users
        -- 6. Configure PowerBI to call: EXEC [App].[LabTest_POC_Compare]
        --
        -- CURRENT CONFIGURATION: Direct Query Mode (Stored Procedure lines are commented out)
        -- ===========================================================================================
          -- CREATE OR ALTER PROCEDURE [App].[LabTest_POC_Compare]    
          -- AS
          -- BEGIN
          -- EXEC dbo.sp_SignAppObject [LabTest_POC_Compare]
        
        -- Enable execution messages and row counts for detailed output
                SET NOCOUNT OFF;  -- Show row counts and execution messages for each query section
                --SET NOCOUNT ON;  -- Disable showing row counts and execution messages for each query section
      
        -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
        -- NOTE: For multiple facilities or wildcard searches, change the parameter type and WHERE clauses:
        --   • Wildcards: Change to VARCHAR and use LIKE operator (e.g., WHERE Sta3n LIKE '%578%')
        --   • Multiple stations: Use IN operator (e.g., WHERE Sta3n IN (578, 568, 332, 113))
                DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (v12/s578)
                --DECLARE @FacilityStationNumber VARCHAR(50) = '578,568,332,113';  -- Example to include results from multiple facility

        -- Date Range Parameters - Automatically sets fiscal year to date range
        -- NOTE: To modify date ranges for historical analysis or specific periods:
        --   • Historical: Change YEAR(GETDATE()) - 1 to YEAR(GETDATE()) - 2 for previous fiscal year
        --   • Explicit dates: Use CAST('2024-10-01' AS DATETIME2(0)) and CAST('2025-09-30' AS DATETIME2(0))
                DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
                DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

        -- Enable detailed execution time statistics in the output of the query results
                SET STATISTICS TIME ON;
                SET STATISTICS IO ON;

-- ===================================================================================================
-- QUERY FUNCTIONAL TEXT
-- ===================================================================================================
SELECT TOP (1000) [LabChemTestSID]                  -- Unique system identifier for each lab test definition
      ,[LabChemTestIEN]                             -- Internal Entry Number (IEN) for VistA/CPRS mapping
      ,[Sta3n]                                      -- VA facility station number (e.g., 578 = Hines)
      ,[LabChemTestName] AS [LabChemTestName_VISTA] -- Official VistA test name for the lab test
      ,[LabChemPrintTestName]                       -- Print-friendly test name for reports/labels
      ,[NLTNationalVALabCodeSID]                    -- National Laboratory Test (NLT) code SID for standardization
      ,[NationalVALabCodeSID]                       -- National VA Lab Code SID for cross-facility mapping
      ,[LabChemTestLocation]                        -- Default location/department associated with the test
      ,[LabTestType]                                -- Test type/category (e.g., Chemistry, Hematology)
      ,[RequiredTestFlag]                           -- Indicates if test is required for certain panels/orders
      ,[TestCost]                                   -- Cost of the test (for billing/analysis)
      ,[SNOMEDProcedureSID]                         -- SNOMED code SID for procedure mapping
      ,[HighestLabChemTestUrgencySID]               -- Highest urgency level allowed for this test
      ,[ForcedLabChemTestUrgencySID]                -- If set, forces a specific urgency for this test
      ,[DefaultSpecimenSiteCPTSID]                  -- Default CPT code SID for specimen site
      ,[HCSPCSCPTSID]                               -- Healthcare Common Procedure Coding System (HCPCS) CPT SID
      ,[CollectionSampleSID]                        -- Collection sample type SID (e.g., blood, urine)
      ,[BillableFlag]                               -- Indicates if the test is billable (Y/N)
      ,[UniqueCollectionSampleFlag]                 -- Indicates if sample must be unique for this test
      ,[UniqueAccessionNumberFlag]                  -- Indicates if accession number must be unique
      ,*                                            -- All additional columns for full metadata reference
  FROM [CDWWork].[Dim].[LabChemTest]                -- Source: Lab test definitions dimension table
  WHERE [Sta3n] LIKE @FacilityStationNumber         -- Filter for specific VA facility (default: 578)
   AND ([LabChemTestSID] = 1000122927               -- POC_URINALYSIS (Point-of-Care Urinalysis)
        OR [LabChemTestSID] = 1000153039            -- TEMP_UA_W/_MICROSCOPIC-iQ (UA with Microscopic - iQ analyzer)
        OR [LabChemTestSID] = 1000114340            -- ISTAT CREATININE (iSTAT device creatinine test)
        OR [LabChemTestSID] = 1000062823            -- CREATININE (Traditional lab creatinine test)
        OR [LabChemTestSID] = 1000114341            -- ISTAT HEMATOCRIT (iSTAT device hematocrit test)
        OR [LabChemTestSID] = 1000048470            -- HEMATOCRIT (Traditional lab hematocrit test)
        OR [LabChemTestSID] = 1000114342            -- ISTAT HEMOGLOBIN (iSTAT device hemoglobin test)
        OR [LabChemTestSID] = 1000036429            -- HEMOGLOBIN (Traditional lab hemoglobin test)
        OR [LabChemTestSID] = 1000113247            -- TROPONIN ISTAT (iSTAT device troponin test)
        OR [LabChemTestSID] = 1600022143            -- HIGH SENSITIVITY TROPONIN I (Lab-based high sensitivity troponin)
        OR [LabChemTestSID] = 1000068127            -- POC GLUCOSE (Point-of-Care glucose test)
        OR [LabChemTestSID] = 1000027461            -- GLUCOSE (Traditional lab glucose test)
        )
    --AND ([LabChemTestName] LIKE '%TROPONIN%')       -- Optional: Filter for test names containing 'TROPONIN'
    --    --OR [LabChemTestName] LIKE '%top%')        -- Optional: Additional filter for test names
  ORDER BY [LabChemTestName_VISTA]                  -- Sort results alphabetically by VistA test name