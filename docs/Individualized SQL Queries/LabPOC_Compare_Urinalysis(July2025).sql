USE [D03_VISN12Collab]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================================================
USAGE LICENSE:
===============================================================================
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

-- =========================================================================
-- PROJECT/BUSINESS INFORMATION:
-- =========================================================================
    Project Title:   Laboratory Point-Of-Collection Comparison (URINALYSIS ONLY)
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-22 (URINALYSIS-ONLY Version)
        Version History:   Specialized version focusing exclusively on urinalysis comparisons
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[usp_PBI_HIN_LabTestCompare_Urinalysis]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have urinalysis tests conducted within short timeframes that yield
        dramatically different results between POC and traditional laboratory methods.
        
        CLINICAL RATIONALE:
        Urinalysis tests collected in outpatient settings should ideally produce similar
        results to the same tests performed shortly thereafter in inpatient settings.
        Significant discrepancies between these paired results indicate potential
        issues requiring clinical investigation, such as:
        • Patient condition changes between collections
        • Sample collection methodology differences
        • Equipment calibration variations
        • Processing method discrepancies
        • Sample handling and storage variations
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired urinalysis test results:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • POC Urinalysis vs UA W/ MICROSCOPIC-iQ (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file - Urinalysis Only)
        2. PowerBI Report Dashboard (automated GUI)
        3. Documentation Package
        
    POWERBI REPORT:
        Published Location: https://app.powerbigov.us/groups/f9a21156-7cbd-49e0-8cec-3b7b6e47b9e9/reports/9f36833b-42ca-43f3-a090-6bf48c15bcb7/c72abfeb1ac2073a3247
        Update Frequency:  Automated refresh from stored procedure execution
        End Users:         Laboratory Management, Pathology Staff, Clinical Quality

    TECHNICAL SPECIFICATIONS:
        Dependencies:      CDWWork.Chem.PatientLabChem (Primary data source)
                           CDWWork.Dim.Location (Location dimension)
                           CDWWork.SPatient.SPatient (Patient demographics)
                           CDWWork.Dim.LabChemTest (Lab test definitions)
        
        Performance:       Utilizes temporary tables for optimal query execution
                           Indexed on PatientSID for efficient joins
                           Date range filtering applied early for performance
        
        Data Volume:       Processes approximately 2,000-10,000 urinalysis test results per fiscal year
        Execution Time:    Typical runtime 30-60 seconds for urinalysis-only analysis
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
        
        Lab Test SIDs:     1000122927 (POC Urinalysis), 1000153039 (UA W/ MICROSCOPIC-iQ)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        This specialized version focuses exclusively on urinalysis test comparisons.
===============================================================================
*/


-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
-- CREATE OR ALTER PROCEDURE [App].[usp_PBI_HIN_LabTestCompare_Urinalysis]    
-- AS
-- BEGIN
    SET NOCOUNT ON;  -- Prevents extra result sets from interfering with SELECT statements

    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare_Urinalysis]
    
    -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
    DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (578)

    -- Date Range Parameters - Automatically sets fiscal year to date range
    -- Fiscal year runs from October 1 of previous calendar year through September 30 of current calendar year
    DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
    DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

-- =========================================================================
-- RAW DATA COLLECTION & CONSOLIDATION - LABORATORY URINALYSIS POINT-OF-CARE VS TRADITIONAL LAB COMPARISONS
-- =========================================================================

    -- =======================================================================
    -- URINALYSIS ANALYSIS
    -- =======================================================================

        -- ===================================================================
        -- ANALYSIS of "POC URINALYSIS" (LabChemTestSID = "1000122927")
        -- ===================================================================
        -- Extract POC Urinalysis test results from PatientLabChem table
        -- POC (Point of Care) urinalysis tests are performed at bedside or in clinical areas for rapid results
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
                poc_urinalysis.Units,                          -- Units of measurement for result
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

        -- ===================================================================
        -- ANALYSIS of "UA W/ MICROSCOPIC-iQ" (LabChemTestSID = "1000153039")
        -- ===================================================================
        -- Extract traditional Laboratory UA W/ MICROSCOPIC-iQ test results from PatientLabChem table
        -- Lab urinalysis tests are processed in central laboratory using automated analyzers with microscopic examination
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
                lab_urinalysis.Units,                          -- Units of measurement for result
                lab_urinalysis.LabChemSpecimenDateTime,        -- Date and time specimen was collected from patient
                lab_urinalysis.LabChemSpecimenDateSID,         -- Date system identifier for specimen collection tracking
                lab_urinalysis.LabChemCompleteDateTime,        -- Date and time test was completed and results became available
                lab_urinalysis.LabChemCompleteDateSID,         -- Date system identifier for test completion tracking
                lab_urinalysis.LabChemResultValue,             -- Test result value as text (urinalysis findings)
                lab_urinalysis.TopographySID,                  -- Anatomical location identifier (where specimen was obtained)
                location.LocationName,                         -- Name of requesting location/department for analysis by service
                location.PatientFriendlyLocationName,          -- User-friendly location name for PowerBI reporting
                [LabChemTestName] = 'UA W/ MICROSCOPIC-iQ'    -- Standardized test name for reporting consistency
        INTO    #TEMP_UA_W_MICROSCOPIC                         -- Temporary table stores traditional lab urinalysis results for later comparison with POC urinalysis in #TEMP_Combined_Urinalysis
        FROM    [CDWWork].[Chem].[PatientLabChem] AS lab_urinalysis
                JOIN [CDWWork].[Dim].[Location] AS location    -- Join to get human-readable location names instead of just SID numbers
                    ON lab_urinalysis.RequestingLocationSID = location.LocationSID
        WHERE   lab_urinalysis.Sta3n = @FacilityStationNumber  -- Filter for specified VA facility
                AND lab_urinalysis.LabChemTestSID = 1000153039  -- UA W/ MICROSCOPIC-iQ Test SID (traditional laboratory test)
                AND lab_urinalysis.LabChemCompleteDateTime >= @StartDate  -- Fiscal year start date
                AND lab_urinalysis.LabChemCompleteDateTime <= @EndDate;   -- Current date

        -- Add index for optimal join performance with patient table and time comparisons
        CREATE CLUSTERED INDEX CIX_PatientSID ON #TEMP_UA_W_MICROSCOPIC (PatientSID);
        CREATE NONCLUSTERED INDEX IX_SpecimenDateTime ON #TEMP_UA_W_MICROSCOPIC (LabChemSpecimenDateTime);

        -- ===================================================================
        -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "POC URINALYSIS" (LabChemTestSID = "1000122927") versus "UA W/ MICROSCOPIC-iQ" (LabChemTestSID = "1000153039")
        -- ===================================================================
        -- Combine POC and Lab Urinalysis results for the same patients when tests were performed within 30 minutes
        -- This creates paired comparisons to identify potential discrepancies between urinalysis testing methods
        DROP TABLE IF EXISTS #TEMP_Combined_Urinalysis;
        SELECT  patient.PatientName AS 'Patient Name',                        -- Patient full name for identification purposes
                RIGHT(patient.PatientSSN, 4) AS 'Last4 SSN',                 -- Last 4 digits of SSN for privacy compliance and identification
                REPLACE(poc.ShortAccessionNumber, ' ', '') AS 'First Sample Accession Number',  -- POC test accession number (spaces removed for consistency)
                poc.LabChemSpecimenDateTime AS 'First Sample Collection Date/Time',             -- When POC specimen was collected from patient
                poc.LabChemTestName AS 'First Test Name',                     -- Name of POC test (POC Urinalysis)
                poc.LabChemResultValue AS 'First Test Result',               -- POC urinalysis result value
                poc.Units AS 'First Test Result Unit',                       -- Units for POC result
                poc.LabChemCompleteDateTime AS 'First Test Result Completion Date/Time',        -- When POC test was completed and results available
                REPLACE(lab.ShortAccessionNumber, ' ', '') AS 'Second Sample Accession Number', -- Lab test accession number (spaces removed for consistency)
                lab.LabChemSpecimenDateTime AS 'Second Sample Collection Date/Time',            -- When lab specimen was collected from patient
                lab.LabChemTestName AS 'Second Test Name',                    -- Name of lab test (UA W/ MICROSCOPIC-iQ)
                lab.LabChemResultValue AS 'Second Test Result',              -- Lab urinalysis result value
                lab.Units AS 'Second Test Result Unit',                      -- Units for lab result
                lab.LabChemCompleteDateTime AS 'Second Test Result Completion Date/Time',       -- When lab test was completed and results available
                poc.LocationName AS 'Collection Location',                   -- Location where tests were requested (for analysis by department)
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
-- FINAL RESULTS CONSOLIDATION - URINALYSIS ONLY
-- =========================================================================
-- Create the final consolidated results table containing only urinalysis paired test comparisons
-- This table structure matches the full version but contains exclusively urinalysis data
--
-- PERFORMANCE NOTE: Since this is urinalysis-only, no UNION operations are needed
-- The single test family data is directly formatted for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM #TEMP_Combined_Urinalysis;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired urinalysis test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard
    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- POC test specimen tracking number
            [First Sample Collection Date/Time],       -- When POC specimen was collected
            [First Test Name],                         -- POC test name (POC Urinalysis)
            [First Test Result],                       -- POC test result value
            [First Test Result Unit],                  -- POC test result units
            [First Test Result Completion Date/Time],  -- When POC test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (UA W/ MICROSCOPIC-iQ)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Urinalysis only)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table (urinalysis only)
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION - URINALYSIS FOCUS
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify urinalysis-specific components of the analysis.

        -- VALIDATION QUERY 1: Urinalysis Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the urinalysis procedure
        -- This ensures all required urinalysis tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID = 1000122927 THEN 'Point-of-Care (POC) Urinalysis'
                WHEN LabChemTestSID = 1000153039 THEN 'Traditional Laboratory Urinalysis'
                ELSE 'Other Test'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (1000122927, 1000153039)
        ORDER BY LabChemTestName;

        -- VALIDATION QUERY 2: Urinalysis Test Volume Check
        -- Use this to verify data availability and volume for urinalysis tests
        -- This helps determine if sufficient data exists for meaningful analysis
        DECLARE @StartDate_Check DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0));
        DECLARE @EndDate_Check   DATETIME2(0) = CAST(GETDATE() AS DATE);
        
        SELECT lt.LabChemTestName,
               COUNT(*) AS TestCount,
               MIN(plc.LabChemCompleteDateTime) AS EarliestTest,
               MAX(plc.LabChemCompleteDateTime) AS LatestTest
        FROM   [CDWWork].[Chem].[PatientLabChem] plc
            JOIN [CDWWork].[Dim].[LabChemTest] lt ON plc.LabChemTestSID = lt.LabChemTestSID
        WHERE  plc.Sta3n = 578
            AND plc.LabChemTestSID IN (1000122927, 1000153039)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Urinalysis Output Format Check
        -- Use this to verify the structure and content of the final urinalysis output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific urinalysis scenarios
*/

-- END
-- GO
