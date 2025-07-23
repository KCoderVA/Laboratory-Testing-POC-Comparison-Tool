/*
===============================================================================
USAGE LICENSE:
===============================================================================
    MIT License

    Copyright (c) 2025 Kyle J. Coder, Edward Hines Jr. VA Hospital
    
    RECOMMENDED FILENAME: LabTest_POC_Compare_Analysis.sql
    (To match the stored procedure name: [App].[LabTest_POC_Compare])

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
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-17 (Current Version)
        Version History:   33 iterations (v0.1 through v2.0)
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[LabTest_POC_Compare]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have two similar blood tests conducted within short timeframes
        that yield dramatically different results.
        
        CLINICAL RATIONALE:
        Blood tests collected in outpatient settings should ideally produce similar
        results to the same tests performed shortly thereafter in inpatient settings.
        Significant discrepancies between these paired results indicate potential
        issues requiring clinical investigation, such as:
        • Patient condition changes between collections
        • Sample collection methodology differences
        • Equipment calibration variations
        • Processing method discrepancies
        
        IMPLEMENTATION GUIDANCE FOR OTHER FACILITIES:
        This solution can be adapted for use at other VA facilities by:
        • Modifying @FacilityStationNumber parameter (line 285) to your facility's station number
        • Updating LabChemTestSID values to match your facility's test identifiers
        • Adjusting time window parameters for POC vs Lab comparisons based on clinical workflow
        • Configuring PowerBI template with your facility's branding and requirements
        
        For complete implementation instructions, see:
        https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/README.md
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired test results with defined
        time windows for clinically relevant comparisons:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • POC Glucose vs Lab Glucose (30 minutes)
        • iSTAT Creatinine vs Lab Creatinine (24 hours / 1440 minutes)
        • iSTAT Hematocrit vs Lab Hematocrit (30 minutes)
        • POC Hemoglobin vs Lab Hemoglobin (30 minutes)
        • iSTAT Troponin vs High Sensitivity Troponin I (30 minutes)
        • POC Urinalysis vs UA W/ MICROSCOPIC-iQ (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file)
        2. PowerBI Report Dashboard (automated GUI)
        3. Documentation Package
        4. Implementation Guide for other VA facilities
        5. Security signing procedure ([dbo].[sp_SignAppObject])
        
        COMPLETE SOLUTION REPOSITORY:
        GitHub Repository: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool
        Implementation Guide: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/TEMPLATE_SETUP_INSTRUCTIONS.md
        PowerBI Template Request: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/POWERBI_TEMPLATE_REQUEST.md
        Security Documentation: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/blob/main/DATA_SECURITY_VERIFICATION.md
        
    POWERBI REPORT:
        Published Location: https://app.powerbigov.us/groups/f9a21156-7cbd-49e0-8cec-3b7b6e47b9e9/reports/9f36833b-42ca-43f3-a090-6bf48c15bcb7/c72abfeb1ac2073a3247
        Update Frequency:  Automated refresh from stored procedure execution
        End Users:         Laboratory Management, Pathology Staff, Clinical Quality

    TECHNICAL SPECIFICATIONS:
        Platform:          Microsoft SQL Server (T-SQL)
        Compatible Versions: SQL Server 2016 Enterprise and higher
        Database Engine:   Microsoft SQL Server (minimum version 13.0)
        Language Version:  T-SQL (Transact-SQL)
        Required Features: Windowing Functions, CTEs, Dynamic SQL, CASE Logic
        Memory Requirements: Minimum 8GB RAM for large dataset queries
        Storage Requirements: Varies by facility (typically 50GB+ for historical data)
        Network Access:    VistA/CPRS integration required for real-time data
        Security Level:    VA-compliant, HIPAA-compliant, PHI-protected
        Performance Target: <30 seconds execution time for 1-year data ranges
        Concurrent Users:  Up to 50 simultaneous report executions
        
        DATA INTEGRATION POINTS:
        Dependencies:      CDWWork.Chem.PatientLabChem (Primary data source)
                           CDWWork.Dim.Location (Location dimension)
                           CDWWork.SPatient.SPatient (Patient demographics)
                           CDWWork.Dim.LabChemTest (Lab test definitions)
        
        VistA Integration: Real-time clinical data validation
        CPRS Integration:  Clinical context and provider workflow integration
        PowerBI Service:   Executive dashboard and trend visualization
        
        PERFORMANCE CHARACTERISTICS:
        Performance:       Utilizes temporary tables for optimal query execution
                           Indexed on PatientSID for efficient joins
                           Date range filtering applied early for performance
        
        Data Volume:       Processes approximately 10,000-50,000 test results per fiscal year
        Execution Time:    Typical runtime 2-5 minutes depending on data volume
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
        
        COMPLIANCE REQUIREMENTS:
        • VA Directive 6500: Information Security Program
        • VA Handbook 5200.08: Privacy and Release of Information
        • HIPAA Privacy Rule: Protected Health Information handling
        • FISMA Controls: Federal security assessment requirements
        
        Lab Test SIDs:     1000068127 (POC Glucose), 1000027461 (Lab Glucose)
                           1000114340 (iSTAT Creatinine), 1000062823 (Lab Creatinine)
                           1000114341 (iSTAT Hematocrit), 1000048470 (Lab Hematocrit)
                           1000114342 (iSTAT Hemoglobin), 1000036429 (Lab Hemoglobin)
                           1000113247 (iSTAT Troponin), 1600022143 (High Sensitivity Troponin I)
                           1000122927 (POC Urinalysis), 1000153039 (UA W/ MICROSCOPIC-iQ)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        
        Special recognition to the Edward Hines Jr. VA Hospital Clinical Informatics
        team for their expertise in laboratory data analysis and quality improvement
        initiatives that guided the development of this comprehensive solution.
        
        Additional thanks to VA Clinical Quality teams nationwide who provided
        feedback on Point-of-Care testing protocols and validation requirements
        that shaped the analytical approach and clinical relevance of this tool.

==================================================================================================
    TROUBLESHOOTING & VALIDATION:
==================================================================================================
    
    COMMON IMPLEMENTATION ISSUES:
    1. Data Source Access: Verify CDWWork database permissions and connection
    2. Test SID Mapping: Confirm lab test SIDs match your facility's configuration
    3. Date Range Performance: Limit initial queries to 90-day ranges for testing
    4. PowerBI Refresh: Ensure service account has appropriate database access
    
    VALIDATION CHECKPOINTS:
    1. Verify test result counts match expected volume for your facility
    2. Confirm time window logic produces clinically reasonable paired results
    3. Validate statistical calculations against manual spot-checks
    4. Test PowerBI dashboard refresh and data accuracy
    
    PERFORMANCE OPTIMIZATION:
    1. Monitor execution time and adjust date ranges if needed
    2. Consider indexing strategies for large datasets
    3. Implement automated refresh schedules during low-usage periods
    4. Archive historical results to maintain optimal performance

==================================================================================================
    SUPPORT & MAINTENANCE:
==================================================================================================
    
    For technical support, implementation guidance, or feature requests:
    • GitHub Issues: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/issues
    • Documentation: https://github.com/KCoderVA/Laboratory-Testing-POC-Comparison-Tool/wiki
    • VA Clinical Informatics: Contact your local Clinical Informatics team
    
    MAINTENANCE SCHEDULE:
    • Monthly: Verify data source connections and test SID mappings
    • Quarterly: Review performance metrics and optimization opportunities
    • Annually: Validate compliance with updated VA security requirements
    • As Needed: Update test definitions and clinical logic per facility requirements

===============================================================================
*/


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
        
        -- Display detailed parameter values for verification into the output of the query results
                PRINT '============================================================'
                PRINT 'LABORATORY POC COMPARISON ANALYSIS - EXECUTION STARTED'
                PRINT '============================================================'
                PRINT 'Facility Station Number: ' + CAST(@FacilityStationNumber AS VARCHAR(10))
                PRINT 'Analysis Date Range: ' + CONVERT(VARCHAR(20), @StartDate, 120) + ' to ' + CONVERT(VARCHAR(20), @EndDate, 120)
                PRINT 'Execution Start Time: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
                PRINT '============================================================'-- ===================================================================================================


-- ===================================================================================================
-- RAW DATA COLLECTION & CONSOLIDATION SECTION
-- ===================================================================================================
--
-- PURPOSE: Extract and organize raw laboratory test results from CDW into temporary tables
--          for efficient processing and comparison analysis.
--
-- METHODOLOGY:
-- • Creates temporary tables for each test type (POC and traditional lab tests)
-- • Applies facility and date range filters early for optimal performance
-- • Standardizes column naming for consistent downstream processing
-- • Includes comprehensive specimen tracking and audit fields
--
-- PERFORMANCE CONSIDERATIONS:
-- • Temporary tables are indexed on PatientSID for efficient joins
-- • Date filtering applied at source query level to minimize data movement
-- • Test SID filtering ensures only relevant test types are processed
-- ===================================================================================================

    -- ===============================================================================================
    -- GLUCOSE TEST FAMILY ANALYSIS
    -- ===============================================================================================
    --
    -- PURPOSE: Compare Point-of-Care (POC) Glucose tests with traditional laboratory Glucose tests
    --          to evaluate correlation, turnaround time, and clinical decision impact.
    --
    -- CLINICAL CONTEXT:
    -- • POC Glucose: Bedside testing for immediate clinical decisions (30-second results)
    -- • Lab Glucose: Central laboratory analysis with higher precision (30-60 minute turnaround)
    -- • Time Window: 30 minutes for clinically relevant comparisons
    -- • Clinical Significance: Glucose monitoring for diabetes management and critical care
    -- ===============================================================================================

        -- ===========================================================================================
        -- POC GLUCOSE DATA EXTRACTION (LabChemTestSID = 1000068127)
        -- ===========================================================================================
        -- Extract POC Glucose test results from PatientLabChem table
        -- POC (Point of Care) tests are performed at bedside or in clinical areas for rapid results
        DROP TABLE IF EXISTS #TEMP_POC_GLUCOSE;
        SELECT  -- Laboratory Point of Collection Comparison Report For POC Glucose
                poc_glucose.LabChemSID,                        -- Unique identifier for lab chemistry record
                poc_glucose.LRDFN,                             -- Laboratory Record Data File Number for specimen tracking
                poc_glucose.ShortAccessionNumber,              -- Short accession number for specimen identification
                poc_glucose.LongAccessionNumberUID,            -- Long accession number unique identifier for cross-system tracking
                poc_glucose.LabChemTestSID,                    -- Lab chemistry test system identifier (1000068127 = POC Glucose)
                poc_glucose.PatientSID,                        -- Patient system identifier for linking patient records
                poc_glucose.RequestingStaffSID,                -- Staff member who requested the test for tracking accountability
                poc_glucose.LabChemSpecimenDateTime,           -- Date and time specimen was collected from patient
                poc_glucose.LabChemSpecimenDateSID,            -- Date system identifier for specimen collection tracking
                poc_glucose.LabChemCompleteDateTime,           -- Date and time test was completed and results became available
                poc_glucose.LabChemCompleteDateSID,            -- Date system identifier for test completion tracking
                poc_glucose.LabChemResultValue,                -- Test result value as text (glucose concentration)
                poc_glucose.TopographySID,                     -- Anatomical location identifier (where specimen was obtained)
                poc_glucose.Units,                             -- Units of measurement for result (typically mg/dL)
                location.LocationName,                         -- Name of requesting location/department for analysis by service
                [LabChemTestName] = 'POC GLUCOSE'             -- Standardized test name for reporting consistency
        INTO    #TEMP_POC_GLUCOSE                              -- Temporary table stores POC glucose results for later comparison with lab glucose in #TEMP_Combined_Glucose
        FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_glucose
                JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                    ON poc_glucose.RequestingLocationSID = location.LocationSID
        WHERE   poc_glucose.Sta3n = @FacilityStationNumber     -- Filter for specified VA facility
                AND poc_glucose.LabChemTestSID = 1000068127     -- POC Glucose Test SID
                AND poc_glucose.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
                AND poc_glucose.LabChemCompleteDateTime <= @EndDate;   -- Current date
        -- Add index for optimal join performance with patient table and time comparisons
        CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_POC_GLUCOSE (PatientSID);
        CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_POC_GLUCOSE (LabChemSpecimenDateTime);
        
        -- Display row count for POC Glucose results
        PRINT 'POC Glucose records extracted: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

        -- ===================================================================
        -- ANALYSIS of "GLUCOSE" (LabChemTestSID = "1000027461")
        -- ===================================================================
        -- Extract traditional Laboratory Glucose test results from PatientLabChem table
        -- Lab glucose tests are processed in central laboratory using automated chemistry analyzers
        DROP TABLE IF EXISTS #TEMP_GLUCOSE;
        SELECT  lab_glucose.LabChemSID,                        -- Unique identifier for lab chemistry record
                lab_glucose.LRDFN,                             -- Laboratory Record Data File Number for specimen tracking
                lab_glucose.ShortAccessionNumber,              -- Short accession number for specimen identification
                lab_glucose.LongAccessionNumberUID,            -- Long accession number unique identifier for cross-system tracking
                lab_glucose.HostLongAccessionNumberUID,        -- Host system accession number for integration tracking
                lab_glucose.CollectingLongAccessionNumberUID,  -- Collecting system accession number for specimen chain of custody
                lab_glucose.LabChemTestSID,                    -- Lab chemistry test system identifier (1000027461 = Lab Glucose)
                lab_glucose.PatientSID,                        -- Patient system identifier for linking patient records
                lab_glucose.RequestingStaffSID,                -- Staff member who requested the test for accountability tracking
                lab_glucose.Units,                             -- Units of measurement for result (typically mg/dL)
                lab_glucose.LabChemSpecimenDateTime,           -- Date and time specimen was collected from patient
                lab_glucose.LabChemSpecimenDateSID,            -- Date system identifier for specimen collection tracking
                lab_glucose.LabChemCompleteDateTime,           -- Date and time test was completed and results became available
                lab_glucose.LabChemCompleteDateSID,            -- Date system identifier for test completion tracking
                lab_glucose.LabChemResultValue,                -- Test result value as text (glucose concentration)
                lab_glucose.TopographySID,                     -- Anatomical location identifier (where specimen was obtained)
                location.LocationName,                         -- Name of requesting location/department for analysis by service
                location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
                [LabChemTestName] = 'GLUCOSE'                 -- Standardized test name for reporting consistency
        INTO    #TEMP_GLUCOSE                                  -- Temporary table stores traditional lab glucose results for later comparison with POC glucose in #TEMP_Combined_Glucose
        FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_glucose
                JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                    ON lab_glucose.RequestingLocationSID = location.LocationSID
        WHERE   lab_glucose.Sta3n = @FacilityStationNumber     -- Filter for specified VA facility
                AND lab_glucose.LabChemTestSID = 1000027461     -- Lab Glucose Test SID (traditional laboratory test)
                AND lab_glucose.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
                AND lab_glucose.LabChemCompleteDateTime <= @EndDate;   -- Current date

        -- Add index for optimal join performance with patient table and time comparisons
        CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_GLUCOSE (PatientSID);
        CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_GLUCOSE (LabChemSpecimenDateTime);

        -- ===================================================================
        -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "POC GLUCOSE" (LabChemTestSID = "1000068127") versus "GLUCOSE" (LabChemTestSID = "1000027461")
        -- ===================================================================
        -- Combine POC and Lab Glucose results for the same patients when tests were performed within 30 minutes
        -- This creates paired comparisons to identify potential discrepancies between testing methods
        DROP TABLE IF EXISTS #TEMP_Combined_Glucose;
        SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
                RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
                REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- POC test accession number (spaces removed for consistency)
                poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When POC specimen was collected from patient
                poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (POC GLUCOSE)
                poc.LabChemResultValue AS 'First Test Result',               -- POC glucose result value
                poc.Units AS 'First Test Result Unit',                       -- Units for POC result (typically mg/dL)
                poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When POC test was completed and results available
                REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
                lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
                lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (GLUCOSE)
                lab.LabChemResultValue AS 'Second Test Result',              -- Lab glucose result value
                lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (typically mg/dL)
                lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
                poc.LocationName AS 'Collection Location',                   -- Location where tests were requested (for analysis by department)
                [LabTestFamily] = 'Glucose'                                  -- Test family grouping for consolidated analysis
        INTO    #TEMP_Combined_Glucose                                       -- Temporary table stores paired POC/Lab glucose comparisons for final consolidation in #TEMP_Combined_Results
        FROM    #TEMP_POC_GLUCOSE AS poc                                     -- POC glucose results from previous query
                INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient        -- Patient demographic and identification information
                    ON poc.PatientSID = patient.PatientSID                  -- Link POC results to patient records
                INNER JOIN #TEMP_GLUCOSE AS lab                              -- Lab glucose results from previous query
                    ON poc.PatientSID = lab.PatientSID                      -- Match lab results to same patients as POC tests
        WHERE   patient.Sta3n = @FacilityStationNumber                      -- Ensure patient belongs to specified facility
                AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 30;  -- 30-minute comparison window for clinically relevant comparisons

    -- =========================================================================
    -- ANALYSIS of "iSTAT CREATININE" (LabChemTestSID = "1000114340")
    -- =========================================================================
    -- Extract iSTAT Creatinine POC test results from PatientLabChem table
    -- iSTAT devices provide rapid bedside chemistry analysis for critical care decisions
    DROP TABLE IF EXISTS #TEMP_iSTAT_Creatinine;
    SELECT  -- Laboratory Point of Collection Comparison Report For Creatinine
            poc_creatinine.LabChemSID,                     -- Unique identifier for lab chemistry record
            poc_creatinine.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            poc_creatinine.ShortAccessionNumber,           -- Short accession number for specimen identification
            poc_creatinine.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            poc_creatinine.LabChemTestSID,                 -- Lab chemistry test system identifier (1000114340 = iSTAT Creatinine)
            poc_creatinine.PatientSID,                     -- Patient system identifier for linking patient records
            poc_creatinine.RequestingStaffSID,             -- Staff member who requested the test for tracking accountability
            poc_creatinine.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            poc_creatinine.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            poc_creatinine.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            poc_creatinine.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            poc_creatinine.LabChemResultValue,             -- Test result value as text (creatinine concentration)
            poc_creatinine.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            poc_creatinine.Units,                          -- Units of measurement for result (typically mg/dL)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            [LabChemTestName] = 'iSTAT Creatinine'        -- Standardized test name for reporting consistency
    INTO    #TEMP_iSTAT_Creatinine                         -- Temporary table stores iSTAT creatinine results for later comparison with lab creatinine in #TEMP_Combined_Creatinine
    FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_creatinine
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                ON poc_creatinine.RequestingLocationSID = location.LocationSID
    WHERE   poc_creatinine.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND poc_creatinine.LabChemTestSID = 1000114340  -- iSTAT Creatinine Test SID
            AND poc_creatinine.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND poc_creatinine.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_iSTAT_Creatinine (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_iSTAT_Creatinine (LabChemSpecimenDateTime);

    -- =========================================================================
    -- ANALYSIS of "CREATININE" (LabChemTestSID = "1000062823")
    -- =========================================================================
    -- Extract traditional Laboratory Creatinine test results from PatientLabChem table
    -- Lab creatinine tests are processed in central laboratory using automated chemistry analyzers
    DROP TABLE IF EXISTS #TEMP_Creatinine;
    SELECT  lab_creatinine.LabChemSID,                     -- Unique identifier for lab chemistry record
            lab_creatinine.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            lab_creatinine.ShortAccessionNumber,           -- Short accession number for specimen identification
            lab_creatinine.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            lab_creatinine.HostLongAccessionNumberUID,     -- Host system accession number for integration tracking
            lab_creatinine.CollectingLongAccessionNumberUID, -- Collecting system accession number for specimen chain of custody
            lab_creatinine.LabChemTestSID,                 -- Lab chemistry test system identifier (1000062823 = Lab Creatinine)
            lab_creatinine.PatientSID,                     -- Patient system identifier for linking patient records
            lab_creatinine.RequestingStaffSID,             -- Staff member who requested the test for accountability tracking
            lab_creatinine.Units,                          -- Units of measurement for result (typically mg/dL)
            lab_creatinine.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            lab_creatinine.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            lab_creatinine.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            lab_creatinine.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            lab_creatinine.LabChemResultValue,             -- Test result value as text (creatinine concentration)
            lab_creatinine.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
            [LabChemTestName] = 'Creatinine'              -- Standardized test name for reporting consistency
    INTO    #TEMP_Creatinine                               -- Temporary table stores traditional lab creatinine results for later comparison with iSTAT creatinine in #TEMP_Combined_Creatinine
    FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_creatinine
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                ON lab_creatinine.RequestingLocationSID = location.LocationSID
    WHERE   lab_creatinine.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND lab_creatinine.LabChemTestSID = 1000062823  -- Lab Creatinine Test SID (traditional laboratory test)
            AND lab_creatinine.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND lab_creatinine.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_Creatinine (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_Creatinine (LabChemSpecimenDateTime);

    -- =========================================================================
    -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT CREATININE" (LabChemTestSID = "1000114340") versus "CREATININE" (LabChemTestSID = "1000062823")
    -- =========================================================================
    -- Combine iSTAT and Lab Creatinine results for the same patients when tests were performed within 24 hours
    -- Uses 24-hour window instead of 30-minute window due to different clinical workflow patterns for renal function monitoring
    -- This creates paired comparisons to identify potential discrepancies between POC and laboratory creatinine testing methods
    DROP TABLE IF EXISTS #TEMP_Combined_Creatinine;
    SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
            RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
            REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- iSTAT test accession number (spaces removed for consistency)
            poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When iSTAT specimen was collected from patient
            poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (iSTAT Creatinine)
            poc.LabChemResultValue AS 'First Test Result',               -- iSTAT creatinine result value
            poc.Units AS 'First Test Result Unit',                       -- Units for POC result (typically mg/dL)
            poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When iSTAT test was completed and results available
            REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
            lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
            lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (Creatinine)
            lab.LabChemResultValue AS 'Second Test Result',              -- Lab creatinine result value
            lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (typically mg/dL)
            lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
            poc.LocationName AS 'Collection Location',                   -- Location where tests were requested for analysis by department
            [LabTestFamily] = 'Creatinine'                               -- Test family grouping for consolidated analysis
    INTO    #TEMP_Combined_Creatinine                                     -- Temporary table stores paired iSTAT/Lab creatinine comparisons for final consolidation in #TEMP_Combined_Results
    FROM    #TEMP_iSTAT_Creatinine AS poc                                 -- iSTAT creatinine results from previous query
            INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient         -- Patient demographic and identification information
                ON poc.PatientSID = patient.PatientSID                   -- Link POC results to patient records
            INNER JOIN #TEMP_Creatinine AS lab                            -- Lab creatinine results from previous query
                ON poc.PatientSID = lab.PatientSID                       -- Match lab results to same patients as POC tests
    WHERE   patient.Sta3n = @FacilityStationNumber                       -- Ensure patient belongs to specified facility
            AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 1440;  -- 24-hour comparison window (1440 minutes) for renal function monitoring patterns

    -- =========================================================================
    -- ANALYSIS of "iSTAT HEMATOCRIT" (LabChemTestSID = "1000114341")
    -- =========================================================================
    -- Extract iSTAT Hematocrit POC test results from PatientLabChem table
    -- iSTAT devices provide rapid bedside hematology analysis for blood volume assessment
    DROP TABLE IF EXISTS #TEMP_iSTAT_Hematocrit;
    SELECT  -- Laboratory Point of Collection Comparison Report For iSTAT Hematocrit
            poc_hematocrit.LabChemSID,                     -- Unique identifier for lab chemistry record
            poc_hematocrit.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            poc_hematocrit.ShortAccessionNumber,           -- Short accession number for specimen identification
            poc_hematocrit.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            poc_hematocrit.LabChemTestSID,                 -- Lab chemistry test system identifier (1000114341 = iSTAT Hematocrit)
            poc_hematocrit.PatientSID,                     -- Patient system identifier for linking patient records
            poc_hematocrit.RequestingStaffSID,             -- Staff member who requested the test for tracking accountability
            poc_hematocrit.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            poc_hematocrit.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            poc_hematocrit.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            poc_hematocrit.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            poc_hematocrit.LabChemResultValue,             -- Test result value as text (hematocrit percentage)
            poc_hematocrit.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            poc_hematocrit.Units,                          -- Units of measurement for result (typically %)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            [LabChemTestName] = 'iSTAT Hematocrit'        -- Standardized test name for reporting consistency
    INTO    #TEMP_iSTAT_Hematocrit                         -- Temporary table stores iSTAT hematocrit results for later comparison with lab hematocrit in #TEMP_Combined_Hematocrit
    FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_hematocrit
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                ON poc_hematocrit.RequestingLocationSID = location.LocationSID
    WHERE   poc_hematocrit.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND poc_hematocrit.LabChemTestSID = 1000114341  -- iSTAT Hematocrit Test SID
            AND poc_hematocrit.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND poc_hematocrit.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_iSTAT_Hematocrit (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_iSTAT_Hematocrit (LabChemSpecimenDateTime);

    -- =========================================================================
    -- ANALYSIS of "HEMATOCRIT" (LabChemTestSID = "1000048470")
    -- =========================================================================
    -- Extract traditional Laboratory Hematocrit test results from PatientLabChem table
    -- Lab hematocrit tests are processed in central laboratory using automated hematology analyzers
    DROP TABLE IF EXISTS #TEMP_Hematocrit;
    SELECT  lab_hematocrit.LabChemSID,                     -- Unique identifier for lab chemistry record
            lab_hematocrit.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            lab_hematocrit.ShortAccessionNumber,           -- Short accession number for specimen identification
            lab_hematocrit.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            lab_hematocrit.HostLongAccessionNumberUID,     -- Host system accession number for integration tracking
            lab_hematocrit.CollectingLongAccessionNumberUID, -- Collecting system accession number for specimen chain of custody
            lab_hematocrit.LabChemTestSID,                 -- Lab chemistry test system identifier (1000048470 = Lab Hematocrit)
            lab_hematocrit.PatientSID,                     -- Patient system identifier for linking patient records
            lab_hematocrit.RequestingStaffSID,             -- Staff member who requested the test for accountability tracking
            lab_hematocrit.Units,                          -- Units of measurement for result (typically %)
            lab_hematocrit.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            lab_hematocrit.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            lab_hematocrit.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            lab_hematocrit.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            lab_hematocrit.LabChemResultValue,             -- Test result value as text (hematocrit percentage)
            lab_hematocrit.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
            [LabChemTestName] = 'Hematocrit'              -- Standardized test name for reporting consistency
    INTO    #TEMP_Hematocrit                               -- Temporary table stores traditional lab hematocrit results for later comparison with iSTAT hematocrit in #TEMP_Combined_Hematocrit
    FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_hematocrit
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                ON lab_hematocrit.RequestingLocationSID = location.LocationSID
    WHERE   lab_hematocrit.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND lab_hematocrit.LabChemTestSID = 1000048470  -- Lab Hematocrit Test SID (traditional laboratory test)
            AND lab_hematocrit.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND lab_hematocrit.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_Hematocrit (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_Hematocrit (LabChemSpecimenDateTime);

    -- =========================================================================
    -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT HEMATOCRIT" (LabChemTestSID = "1000114341") versus "HEMATOCRIT" (LabChemTestSID = "1000048470")
    -- =========================================================================
    -- Combine iSTAT and Lab Hematocrit results for the same patients when tests were performed within 30 minutes
    -- This creates paired comparisons to identify potential discrepancies between POC and laboratory hematocrit testing methods
    DROP TABLE IF EXISTS #TEMP_Combined_Hematocrit;
    SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
            RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
            REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- iSTAT test accession number (spaces removed for consistency)
            poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When iSTAT specimen was collected from patient
            poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (iSTAT Hematocrit)
            poc.LabChemResultValue AS 'First Test Result',               -- iSTAT hematocrit result value
            poc.Units AS 'First Test Result Unit',                       -- Units for POC result (typically %)
            poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When iSTAT test was completed and results available
            REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
            lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
            lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (Hematocrit)
            lab.LabChemResultValue AS 'Second Test Result',              -- Lab hematocrit result value
            lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (typically %)
            lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
            poc.LocationName AS 'Collection Location',                   -- Location where tests were requested for analysis by department
            [LabTestFamily] = 'Hematocrit'                               -- Test family grouping for consolidated analysis
    INTO    #TEMP_Combined_Hematocrit                                     -- Temporary table stores paired iSTAT/Lab hematocrit comparisons for final consolidation in #TEMP_Combined_Results
    FROM    #TEMP_iSTAT_Hematocrit AS poc                                 -- iSTAT hematocrit results from previous query
            INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient         -- Patient demographic and identification information
                ON poc.PatientSID = patient.PatientSID                   -- Link POC results to patient records
            INNER JOIN #TEMP_Hematocrit AS lab                            -- Lab hematocrit results from previous query
                ON poc.PatientSID = lab.PatientSID                       -- Match lab results to same patients as POC tests
    WHERE   patient.Sta3n = @FacilityStationNumber                       -- Ensure patient belongs to specified facility
            AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 30;  -- 30-minute comparison window for clinically relevant comparisons

    -- =========================================================================
    -- ANALYSIS of "iSTAT HEMOGLOBIN" (LabChemTestSID = "1000114342")
    -- =========================================================================
    -- Extract iSTAT Hemoglobin POC test results from PatientLabChem table
    -- iSTAT devices provide rapid bedside hemoglobin analysis for anemia assessment and blood management
    DROP TABLE IF EXISTS #TEMP_iSTAT_HEMOGLOBIN;
    SELECT  -- Laboratory Point of Collection Comparison Report For iSTAT Hemoglobin
            poc_hemoglobin.LabChemSID,                     -- Unique identifier for lab chemistry record
            poc_hemoglobin.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            poc_hemoglobin.ShortAccessionNumber,           -- Short accession number for specimen identification
            poc_hemoglobin.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            poc_hemoglobin.LabChemTestSID,                 -- Lab chemistry test system identifier (1000114342 = iSTAT Hemoglobin)
            poc_hemoglobin.PatientSID,                     -- Patient system identifier for linking patient records
            poc_hemoglobin.RequestingStaffSID,             -- Staff member who requested the test for tracking accountability
            poc_hemoglobin.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            poc_hemoglobin.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            poc_hemoglobin.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            poc_hemoglobin.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            poc_hemoglobin.LabChemResultValue,             -- Test result value as text (hemoglobin concentration)
            poc_hemoglobin.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            poc_hemoglobin.Units,                          -- Units of measurement for result (typically g/dL)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            [LabChemTestName] = 'POC Hemoglobin'          -- Standardized test name for reporting consistency
    INTO    #TEMP_iSTAT_HEMOGLOBIN                         -- Temporary table stores iSTAT hemoglobin results for later comparison with lab hemoglobin in #TEMP_Combined_Hemoglobin
    FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_hemoglobin
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                ON poc_hemoglobin.RequestingLocationSID = location.LocationSID
    WHERE   poc_hemoglobin.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND poc_hemoglobin.LabChemTestSID = 1000114342  -- iSTAT Hemoglobin Test SID
            AND poc_hemoglobin.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND poc_hemoglobin.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_iSTAT_HEMOGLOBIN (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_iSTAT_HEMOGLOBIN (LabChemSpecimenDateTime);

    -- =========================================================================
    -- ANALYSIS of "HEMOGLOBIN" (LabChemTestSID = "1000036429")
    -- =========================================================================
    -- Extract traditional Laboratory Hemoglobin test results from PatientLabChem table
    -- Lab hemoglobin tests are processed in central laboratory using automated hematology analyzers
    DROP TABLE IF EXISTS #TEMP_HEMOGLOBIN;
    SELECT  lab_hemoglobin.LabChemSID,                     -- Unique identifier for lab chemistry record
            lab_hemoglobin.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            lab_hemoglobin.ShortAccessionNumber,           -- Short accession number for specimen identification
            lab_hemoglobin.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            lab_hemoglobin.HostLongAccessionNumberUID,     -- Host system accession number for integration tracking
            lab_hemoglobin.CollectingLongAccessionNumberUID, -- Collecting system accession number for specimen chain of custody
            lab_hemoglobin.LabChemTestSID,                 -- Lab chemistry test system identifier (1000036429 = Lab Hemoglobin)
            lab_hemoglobin.PatientSID,                     -- Patient system identifier for linking patient records
            lab_hemoglobin.RequestingStaffSID,             -- Staff member who requested the test for accountability tracking
            lab_hemoglobin.Units,                          -- Units of measurement for result (typically g/dL)
            lab_hemoglobin.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            lab_hemoglobin.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            lab_hemoglobin.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            lab_hemoglobin.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            lab_hemoglobin.LabChemResultValue,             -- Test result value as text (hemoglobin concentration)
            lab_hemoglobin.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
            [LabChemTestName] = 'Hemoglobin'              -- Standardized test name for reporting consistency
    INTO    #TEMP_HEMOGLOBIN                               -- Temporary table stores traditional lab hemoglobin results for later comparison with iSTAT hemoglobin in #TEMP_Combined_Hemoglobin
    FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_hemoglobin
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                ON lab_hemoglobin.RequestingLocationSID = location.LocationSID
    WHERE   lab_hemoglobin.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND lab_hemoglobin.LabChemTestSID = 1000036429  -- Lab Hemoglobin Test SID (traditional laboratory test)
            AND lab_hemoglobin.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND lab_hemoglobin.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_HEMOGLOBIN (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_HEMOGLOBIN (LabChemSpecimenDateTime);

    -- =========================================================================
    -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT HEMOGLOBIN" (LabChemTestSID = "1000114342") versus "HEMOGLOBIN" (LabChemTestSID = "1000036429")
    -- =========================================================================
    -- Combine iSTAT and Lab Hemoglobin results for the same patients when tests were performed within 30 minutes
    -- This creates paired comparisons to identify potential discrepancies between POC and laboratory hemoglobin testing methods
    DROP TABLE IF EXISTS #TEMP_Combined_Hemoglobin;
    SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
            RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
            REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- iSTAT test accession number (spaces removed for consistency)
            poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When iSTAT specimen was collected from patient
            poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (POC Hemoglobin)
            poc.LabChemResultValue AS 'First Test Result',               -- iSTAT hemoglobin result value
            poc.Units AS 'First Test Result Unit',                       -- Units for POC result (typically g/dL)
            poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When iSTAT test was completed and results available
            REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
            lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
            lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (Hemoglobin)
            lab.LabChemResultValue AS 'Second Test Result',              -- Lab hemoglobin result value
            lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (typically g/dL)
            lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
            poc.LocationName AS 'Collection Location',                   -- Location where tests were requested for analysis by department
            [LabTestFamily] = 'Hemoglobin'                               -- Test family grouping for consolidated analysis
    INTO    #TEMP_Combined_Hemoglobin                                     -- Temporary table stores paired iSTAT/Lab hemoglobin comparisons for final consolidation in #TEMP_Combined_Results
    FROM    #TEMP_iSTAT_HEMOGLOBIN AS poc                                 -- iSTAT hemoglobin results from previous query
            INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient         -- Patient demographic and identification information
                ON poc.PatientSID = patient.PatientSID                   -- Link POC results to patient records
            INNER JOIN #TEMP_HEMOGLOBIN AS lab                            -- Lab hemoglobin results from previous query
                ON poc.PatientSID = lab.PatientSID                       -- Match lab results to same patients as POC tests
    WHERE   patient.Sta3n = @FacilityStationNumber                       -- Ensure patient belongs to specified facility
            AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 30;  -- 30-minute comparison window for clinically relevant comparisons

    -- =========================================================================
    -- ANALYSIS of "iSTAT TROPONIN" (LabChemTestSID = "1000113247")
    -- =========================================================================
    -- Extract iSTAT Troponin POC test results from PatientLabChem table
    -- iSTAT troponin tests provide rapid cardiac marker analysis for acute myocardial infarction assessment
    DROP TABLE IF EXISTS #TEMP_iSTAT_TROPONIN;
    SELECT  -- Laboratory Point of Collection Comparison Report For iSTAT Troponin
            poc_troponin.LabChemSID,                       -- Unique identifier for lab chemistry record
            poc_troponin.LRDFN,                            -- Laboratory Record Data File Number for specimen tracking
            poc_troponin.ShortAccessionNumber,             -- Short accession number for specimen identification
            poc_troponin.LongAccessionNumberUID,           -- Long accession number unique identifier for cross-system tracking
            poc_troponin.LabChemTestSID,                   -- Lab chemistry test system identifier (1000113247 = iSTAT Troponin)
            poc_troponin.PatientSID,                       -- Patient system identifier for linking patient records
            poc_troponin.RequestingStaffSID,               -- Staff member who requested the test for tracking accountability
            poc_troponin.LabChemSpecimenDateTime,          -- Date and time specimen was collected from patient
            poc_troponin.LabChemSpecimenDateSID,           -- Date system identifier for specimen collection tracking
            poc_troponin.LabChemCompleteDateTime,          -- Date and time test was completed and results became available
            poc_troponin.LabChemCompleteDateSID,           -- Date system identifier for test completion tracking
            poc_troponin.TopographySID,                    -- Anatomical location identifier (where specimen was obtained)
            poc_troponin.Units,                            -- Units of measurement for result (typically ng/mL)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            poc_troponin.LabChemResultNumericValue,        -- Numeric result value for troponin concentration (used instead of text value for precision)
            [LabChemTestName] = 'TROPONIN ISTAT'          -- Standardized test name for reporting consistency
    INTO    #TEMP_iSTAT_TROPONIN                           -- Temporary table stores iSTAT troponin results for later comparison with high sensitivity troponin in #TEMP_Combined_Troponin
    FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_troponin
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                ON poc_troponin.RequestingLocationSID = location.LocationSID
    WHERE   poc_troponin.Sta3n = @FacilityStationNumber    -- Filter for specified VA facility
            AND poc_troponin.LabChemTestSID = 1000113247    -- iSTAT Troponin Test SID
            AND poc_troponin.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND poc_troponin.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_iSTAT_TROPONIN (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_iSTAT_TROPONIN (LabChemSpecimenDateTime);

    -- =========================================================================
    -- ANALYSIS of "HIGH SENSITIVITY TROPONIN I" (LabChemTestSID = "1600022143")
    -- =========================================================================
    -- Extract High Sensitivity Troponin I test results from PatientLabChem table
    -- High sensitivity troponin tests are processed in central laboratory using advanced automated analyzers
    -- These tests provide more precise cardiac marker detection compared to standard troponin assays
    DROP TABLE IF EXISTS #TEMP_HIGH_SENSITIVITY_TROPONIN_I;
    SELECT  lab_troponin.LabChemSID,                       -- Unique identifier for lab chemistry record
            lab_troponin.LRDFN,                            -- Laboratory Record Data File Number for specimen tracking
            lab_troponin.ShortAccessionNumber,             -- Short accession number for specimen identification
            lab_troponin.LongAccessionNumberUID,           -- Long accession number unique identifier for cross-system tracking
            lab_troponin.HostLongAccessionNumberUID,       -- Host system accession number for integration tracking
            lab_troponin.CollectingLongAccessionNumberUID, -- Collecting system accession number for specimen chain of custody
            lab_troponin.LabChemTestSID,                   -- Lab chemistry test system identifier (1600022143 = High Sensitivity Troponin I)
            lab_troponin.PatientSID,                       -- Patient system identifier for linking patient records
            lab_troponin.RequestingStaffSID,               -- Staff member who requested the test for accountability tracking
            lab_troponin.Units,                            -- Units of measurement for result (typically ng/L or ng/mL)
            lab_troponin.LabChemSpecimenDateTime,          -- Date and time specimen was collected from patient
            lab_troponin.LabChemSpecimenDateSID,           -- Date system identifier for specimen collection tracking
            lab_troponin.LabChemCompleteDateTime,          -- Date and time test was completed and results became available
            lab_troponin.LabChemCompleteDateSID,           -- Date system identifier for test completion tracking
            lab_troponin.LabChemResultValue,               -- Test result value as text (troponin concentration)
            lab_troponin.TopographySID,                    -- Anatomical location identifier (where specimen was obtained)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
            lab_troponin.LabChemResultNumericValue,        -- Numeric result value for troponin concentration (used for precision calculations)
            [LabChemTestName] = 'HIGH SENSITIVITY TROPONIN I'  -- Standardized test name for reporting consistency
    INTO    #TEMP_HIGH_SENSITIVITY_TROPONIN_I               -- Temporary table stores high sensitivity troponin results for later comparison with iSTAT troponin in #TEMP_Combined_Troponin
    FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_troponin
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                ON lab_troponin.RequestingLocationSID = location.LocationSID
    WHERE   lab_troponin.Sta3n = @FacilityStationNumber    -- Filter for specified VA facility
            AND lab_troponin.LabChemTestSID = 1600022143    -- High Sensitivity Troponin I Test SID (laboratory test)
            AND lab_troponin.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND lab_troponin.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_HIGH_SENSITIVITY_TROPONIN_I (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_HIGH_SENSITIVITY_TROPONIN_I (LabChemSpecimenDateTime);

    -- =========================================================================
    -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT TROPONIN" (LabChemTestSID = "1000113247") versus "HIGH SENSITIVITY TROPONIN I" (LabChemTestSID = "1600022143")
    -- =========================================================================
    -- Combine iSTAT and High Sensitivity Troponin results for the same patients when tests were performed within 30 minutes
    -- This creates paired comparisons to identify potential discrepancies between POC and laboratory troponin testing methods
    -- Note: Special handling for numeric values to ensure consistent formatting for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Troponin;
    SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
            RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
            REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- iSTAT test accession number (spaces removed for consistency)
            poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When iSTAT specimen was collected from patient
            poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (TROPONIN ISTAT)
            TRIM(TRAILING '0' FROM TRIM(TRAILING '.' FROM CAST(poc.LabChemResultNumericValue AS VARCHAR))) AS 'First Test Result',  -- iSTAT troponin result value (formatted to remove trailing zeros)
            poc.Units AS 'First Test Result Unit',                       -- Units for POC result (typically ng/mL)
            poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When iSTAT test was completed and results available
            REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
            lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
            lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (HIGH SENSITIVITY TROPONIN I)
            lab.LabChemResultValue AS 'Second Test Result',              -- Lab troponin result value (as text from system)
            lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (typically ng/L or ng/mL)
            lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
            poc.LocationName AS 'Collection Location',                   -- Location where tests were requested for analysis by department
            [LabTestFamily] = 'Troponin'                                 -- Test family grouping for consolidated analysis
    INTO    #TEMP_Combined_Troponin                                       -- Temporary table stores paired iSTAT/Lab troponin comparisons for final consolidation in #TEMP_Combined_Results
    FROM    #TEMP_iSTAT_TROPONIN AS poc                                   -- iSTAT troponin results from previous query
            INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient         -- Patient demographic and identification information
                ON poc.PatientSID = patient.PatientSID                   -- Link POC results to patient records
            INNER JOIN #TEMP_HIGH_SENSITIVITY_TROPONIN_I AS lab           -- High sensitivity troponin results from previous query
                ON poc.PatientSID = lab.PatientSID                       -- Match lab results to same patients as POC tests
    WHERE   patient.Sta3n = @FacilityStationNumber                       -- Ensure patient belongs to specified facility
            AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 30;  -- 30-minute comparison window for clinically relevant comparisons

    -- =========================================================================
    -- ANALYSIS of "POC URINALYSIS" (LabChemTestSID = "1000122927")
    -- =========================================================================
    -- Extract POC Urinalysis test results from PatientLabChem table
    -- POC urinalysis tests provide rapid bedside urine analysis for immediate clinical decision making
    DROP TABLE IF EXISTS #TEMP_POC_URINALYSIS;
    SELECT  -- Laboratory Point of Collection Comparison Report For POC Urinalysis
            poc_urinalysis.LabChemSID,                     -- Unique identifier for lab chemistry record
            poc_urinalysis.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            poc_urinalysis.ShortAccessionNumber,           -- Short accession number for specimen identification
            poc_urinalysis.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            poc_urinalysis.LabChemTestSID,                 -- Lab chemistry test system identifier (1000122927 = POC Urinalysis)
            poc_urinalysis.PatientSID,                     -- Patient system identifier for linking patient records
            poc_urinalysis.RequestingStaffSID,             -- Staff member who requested the test for tracking accountability
            poc_urinalysis.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            poc_urinalysis.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            poc_urinalysis.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            poc_urinalysis.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            poc_urinalysis.LabChemResultValue,             -- Test result value as text (urinalysis findings)
            poc_urinalysis.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            poc_urinalysis.Units,                          -- Units of measurement for result (varies by analyte)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            [LabChemTestName] = 'POC Urinalysis'          -- Standardized test name for reporting consistency
    INTO    #TEMP_POC_URINALYSIS                           -- Temporary table stores POC urinalysis results for later comparison with lab urinalysis in #TEMP_Combined_Urinalysis
    FROM    [CDWWork].[Chem].[PatientLabChem] AS poc_urinalysis
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers 
                ON poc_urinalysis.RequestingLocationSID = location.LocationSID
    WHERE   poc_urinalysis.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND poc_urinalysis.LabChemTestSID = 1000122927  -- POC Urinalysis Test SID
            AND poc_urinalysis.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND poc_urinalysis.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_POC_URINALYSIS (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_POC_URINALYSIS (LabChemSpecimenDateTime);

    -- =========================================================================
    -- ANALYSIS of "UA W/ MICROSCOPIC-iQ" (LabChemTestSID = "1000153039")
    -- =========================================================================
    -- Extract UA W/ MICROSCOPIC-iQ test results from PatientLabChem table
    -- Lab urinalysis with microscopic analysis provides comprehensive urine testing with cellular examination
    -- The iQ system refers to the automated urinalysis analyzer used in the central laboratory
    DROP TABLE IF EXISTS #TEMP_UA_W_MICROSCOPIC;
    SELECT  lab_urinalysis.LabChemSID,                     -- Unique identifier for lab chemistry record
            lab_urinalysis.LRDFN,                          -- Laboratory Record Data File Number for specimen tracking
            lab_urinalysis.ShortAccessionNumber,           -- Short accession number for specimen identification
            lab_urinalysis.LongAccessionNumberUID,         -- Long accession number unique identifier for cross-system tracking
            lab_urinalysis.HostLongAccessionNumberUID,     -- Host system accession number for integration tracking
            lab_urinalysis.CollectingLongAccessionNumberUID, -- Collecting system accession number for specimen chain of custody
            lab_urinalysis.LabChemTestSID,                 -- Lab chemistry test system identifier (1000153039 = UA W/ MICROSCOPIC-iQ)
            lab_urinalysis.PatientSID,                     -- Patient system identifier for linking patient records
            lab_urinalysis.RequestingStaffSID,             -- Staff member who requested the test for accountability tracking
            lab_urinalysis.Units,                          -- Units of measurement for result (varies by analyte)
            lab_urinalysis.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
            lab_urinalysis.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
            lab_urinalysis.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
            lab_urinalysis.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
            lab_urinalysis.LabChemResultValue,             -- Test result value as text (comprehensive urinalysis findings including microscopic examination)
            lab_urinalysis.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
            location.LocationName,                         -- Name of requesting location/department for analysis by service
            location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
            [LabChemTestName] = 'UA W/ MICROSCOPIC-iQ'    -- Standardized test name for reporting consistency
    INTO    #TEMP_UA_W_MICROSCOPIC                         -- Temporary table stores lab urinalysis results for later comparison with POC urinalysis in #TEMP_Combined_Urinalysis
    FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_urinalysis
            JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                ON lab_urinalysis.RequestingLocationSID = location.LocationSID
    WHERE   lab_urinalysis.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
            AND lab_urinalysis.LabChemTestSID = 1000153039  -- UA W/ MICROSCOPIC-iQ Test SID (laboratory test with microscopic analysis)
            AND lab_urinalysis.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
            AND lab_urinalysis.LabChemCompleteDateTime <= @EndDate;   -- Current date

    -- Add index for optimal join performance with patient table and time comparisons
    CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_UA_W_MICROSCOPIC (PatientSID);
    CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_UA_W_MICROSCOPIC (LabChemSpecimenDateTime);

    -- =========================================================================
    -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "POC URINALYSIS" (LabChemTestSID = "1000122927") versus "UA W/ MICROSCOPIC-iQ" (LabChemTestSID = "1000153039")
    -- =========================================================================
    -- Combine POC and Lab Urinalysis results for the same patients when tests were performed within 30 minutes
    -- This creates paired comparisons to identify potential discrepancies between POC and laboratory urinalysis testing methods
    DROP TABLE IF EXISTS #TEMP_Combined_Urinalysis;
    SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
            RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
            REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- POC test accession number (spaces removed for consistency)
            poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When POC specimen was collected from patient
            poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (POC Urinalysis)
            poc.LabChemResultValue AS 'First Test Result',               -- POC urinalysis result value
            poc.Units AS 'First Test Result Unit',                       -- Units for POC result (varies by analyte)
            poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When POC test was completed and results available
            REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
            lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
            lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (UA W/ MICROSCOPIC-iQ)
            lab.LabChemResultValue AS 'Second Test Result',              -- Lab urinalysis result value (includes microscopic findings)
            lab.Units AS 'Second Test Result Unit',                      -- Units for lab result (varies by analyte)
            lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
            poc.LocationName AS 'Collection Location',                   -- Location where tests were requested for analysis by department
            [LabTestFamily] = 'Urinalysis'                               -- Test family grouping for consolidated analysis
    INTO    #TEMP_Combined_Urinalysis                                     -- Temporary table stores paired POC/Lab urinalysis comparisons for final consolidation in #TEMP_Combined_Results
    FROM    #TEMP_POC_URINALYSIS AS poc                                   -- POC urinalysis results from previous query
            INNER JOIN [CDWWork].[SPatient].[SPatient] AS patient         -- Patient demographic and identification information
                ON poc.PatientSID = patient.PatientSID                   -- Link POC results to patient records
            INNER JOIN #TEMP_UA_W_MICROSCOPIC AS lab                      -- Lab urinalysis results from previous query
                ON poc.PatientSID = lab.PatientSID                       -- Match lab results to same patients as POC tests
    WHERE   patient.Sta3n = @FacilityStationNumber                       -- Ensure patient belongs to specified facility
            AND ABS(DATEDIFF(MI, poc.LabChemSpecimenDateTime, lab.LabChemSpecimenDateTime)) <= 30;  -- 30-minute comparison window for clinically relevant comparisons

-- =========================================================================
-- FINAL RESULTS CONSOLIDATION
-- =========================================================================
-- Combine all paired test comparison results from individual temp tables into single consolidated dataset
-- This creates the final dataset that will be consumed by PowerBI reporting platform
--
-- PERFORMANCE NOTE: UNION operations are performed on temporary tables rather than base tables
-- for optimal performance. Each temp table is already filtered by facility and date range.
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM    (
            -- Include Glucose paired comparison results
            SELECT * FROM #TEMP_Combined_Glucose
            
            UNION ALL
            
            -- Include Creatinine paired comparison results  
            SELECT * FROM #TEMP_Combined_Creatinine
            
            UNION ALL
            
            -- Include Hematocrit paired comparison results
            SELECT * FROM #TEMP_Combined_Hematocrit
            
            UNION ALL
            
            -- Include Hemoglobin paired comparison results
            SELECT * FROM #TEMP_Combined_Hemoglobin
            
            UNION ALL
            
            -- Include Urinalysis paired comparison results
            SELECT * FROM #TEMP_Combined_Urinalysis
            
            UNION ALL
            
            -- Include Troponin paired comparison results
            SELECT * FROM #TEMP_Combined_Troponin
    ) AS combined_results;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard

    -- Display final execution summary
    DECLARE @FinalRowCount INT;
    SELECT @FinalRowCount = COUNT(*) FROM #TEMP_Combined_Results;
    
    PRINT '============================================================'
    PRINT 'FINAL RESULTS SUMMARY:'
    PRINT '============================================================'
    PRINT 'Combined Results Table Created: #TEMP_Combined_Results'
    PRINT 'Total Paired Comparisons Found: ' + CAST(@FinalRowCount AS VARCHAR(10)) + ' records'
    PRINT 'Query Execution Complete - Outputting Final Results'
    PRINT 'Execution End Time: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
    PRINT '============================================================'

    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- POC test specimen tracking number
            [First Sample Collection Date/Time],       -- When POC specimen was collected
            [First Test Name],                         -- POC test name (POC Glucose, iSTAT Creatinine, etc.)
            [First Test Result],                       -- POC test result value
            [First Test Result Unit],                  -- POC test result units
            [First Test Result Completion Date/Time],  -- When POC test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (Glucose, Creatinine, etc.)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Glucose, Creatinine, etc.)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group

-- =========================================================================
-- CLEANUP AND FINAL STATISTICS
-- =========================================================================
    
    -- Display final statistics
    PRINT '============================================================'
    PRINT 'QUERY EXECUTION COMPLETE!'
    PRINT '============================================================'
    PRINT 'Final Results Displayed Above'
    PRINT 'All temporary tables will be automatically cleaned up when session ends'
    PRINT 'Analysis Period: ' + CONVERT(VARCHAR(20), @StartDate, 120) + ' to ' + CONVERT(VARCHAR(20), @EndDate, 120)
    PRINT 'Facility: Edward Hines Jr. VA Hospital (Station ' + CAST(@FacilityStationNumber AS VARCHAR(10)) + ')'
    PRINT '============================================================'
    
    -- Turn off statistics display
    SET STATISTICS TIME OFF;
    SET STATISTICS IO OFF;
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify individual components of the main analysis.

        -- VALIDATION QUERY 1: Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the main procedure
        -- This ensures all required tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID IN (1000068127, 1000114340, 1000114341, 1000114342, 1000113247, 1000122927) 
                THEN 'Point-of-Care (POC)'
                WHEN LabChemTestSID IN (1000027461, 1000062823, 1000048470, 1000036429, 1600022143, 1000153039) 
                THEN 'Traditional Laboratory'
                ELSE 'Unknown Category'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (
                1000122927,  -- POC Urinalysis
                1000153039,  -- UA with Microscopic Analysis (iQ system)
                1000114340,  -- iSTAT Creatinine
                1000062823,  -- Standard Creatinine
                1000114341,  -- iSTAT Hematocrit
                1000048470,  -- Standard Hematocrit
                1000114342,  -- iSTAT Hemoglobin
                1000036429,  -- Standard Hemoglobin
                1000113247,  -- iSTAT Troponin
                1600022143,  -- High Sensitivity Troponin I
                1000068127,  -- POC Glucose
                1000027461   -- Standard Glucose
        )
        ORDER BY TestCategory, LabChemTestName;

        -- VALIDATION QUERY 2: Data Volume Check by Test Type
        -- Use this to verify data availability and volume for each test type
        DECLARE @StartDate_Check DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0));
        DECLARE @EndDate_Check   DATETIME2(0) = CAST(GETDATE() AS DATE);

        SELECT lt.LabChemTestName,
            COUNT(*) AS RecordCount,
            MIN(plc.LabChemCompleteDateTime) AS EarliestTest,
            MAX(plc.LabChemCompleteDateTime) AS LatestTest
        FROM   [CDWWork].[Chem].[PatientLabChem] plc
            JOIN [CDWWork].[Dim].[LabChemTest] lt ON plc.LabChemTestSID = lt.LabChemTestSID
        WHERE  plc.Sta3n = 578
            AND plc.LabChemTestSID IN (1000068127, 1000027461, 1000114340, 1000062823, 
                                        1000114341, 1000048470, 1000114342, 1000036429,
                                        1000113247, 1600022143, 1000122927, 1000153039)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Output Format Check
        -- Use this to verify the structure and content of the final output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific scenarios
*/

-- ===================================================================================================
-- STORED PROCEDURE MODE ACTIVATION INSTRUCTIONS
-- ===================================================================================================
--
-- *** IMPORTANT: This END statement must be modified together with the CREATE section! ***
-- 
-- TO CONVERT TO STORED PROCEDURE MODE (for production deployment):
--
-- STEP 1: Activate the stored procedure header (around line 260):
--         UNCOMMENT these 4 lines by removing the "--" at the beginning:
--         CREATE OR ALTER PROCEDURE [App].[LabTest_POC_Compare]    
--         AS
--         BEGIN
--         EXEC dbo.sp_SignAppObject [LabTest_POC_Compare]
--
-- STEP 2: Activate the procedure closing statement (THIS SECTION):
--         UNCOMMENT the following line by removing the "--":
-- END
-- GO
--
-- STEP 3: Deploy and secure the stored procedure:
--         1. Execute the modified code to create the procedure in the database
--         2. Sign the procedure: EXEC dbo.sp_SignAppObject 'LabTest_POC_Compare'
--         3. Grant permissions to PowerBI service account and authorized users
--         4. Update PowerBI to call: EXEC [App].[LabTest_POC_Compare]
--
-- TO REVERT TO DIRECT QUERY MODE (for development/testing):
--         1. COMMENT OUT the procedure header lines (add "--" at the beginning)
--         2. COMMENT OUT the END statement below (add "--" at the beginning) 
--         3. Execute as a regular query to see CSV results in the output window
--
-- CURRENT MODE: Direct Query Mode (procedure lines commented out, variables active)
-- FILENAME: Laboratory POC Comparison Analysis Query (LabTest_POC_Compare)
-- ===================================================================================================

-- END
-- GO