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
    Project Title:   Laboratory Point-Of-Collection Comparison (GLUCOSE ONLY)
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-22 (GLUCOSE-ONLY Version)
        Version History:   Specialized version focusing exclusively on glucose comparisons
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[usp_PBI_HIN_LabTestCompare_Glucose]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have glucose tests conducted within short timeframes that yield
        dramatically different results between POC and traditional laboratory methods.
        
        CLINICAL RATIONALE:
        Glucose tests collected in outpatient settings should ideally produce similar
        results to the same tests performed shortly thereafter in inpatient settings.
        Significant discrepancies between these paired results indicate potential
        issues requiring clinical investigation, such as:
        • Patient condition changes between collections
        • Sample collection methodology differences
        • Equipment calibration variations
        • Processing method discrepancies
        • Sample handling and storage variations
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired glucose test results:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • POC Glucose vs Lab Glucose (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file - Glucose Only)
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
        
        Data Volume:       Processes approximately 2,000-10,000 glucose test results per fiscal year
        Execution Time:    Typical runtime 30-60 seconds for glucose-only analysis
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
        
        Lab Test SIDs:     1000068127 (POC Glucose), 1000027461 (Lab Glucose)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        This specialized version focuses exclusively on glucose test comparisons.
===============================================================================
*/


-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
-- CREATE OR ALTER PROCEDURE [App].[usp_PBI_HIN_LabTestCompare_Glucose]    
-- AS
-- BEGIN

    -- Turn off row count to display messages in Messages tab
    SET NOCOUNT OFF;

    -- Initialize timing variables for performance tracking
    DECLARE @StartTime DATETIME2 = SYSDATETIME();
    DECLARE @StepTime DATETIME2;
    DECLARE @RowCount INT;

    PRINT '==========================================';
    PRINT 'GLUCOSE COMPARISON QUERY STARTED';
    PRINT '==========================================';
    PRINT 'Query started at: ' + CONVERT(VARCHAR(30), @StartTime, 120);
    PRINT '';

    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare_Glucose]
    
    -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
    DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (578)

    -- Date Range Parameters - Automatically sets fiscal year to date range
    -- Fiscal year runs from October 1 of previous calendar year through September 30 of current calendar year
    DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
    DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

-- =========================================================================
-- RAW DATA COLLECTION & CONSOLIDATION - LABORATORY GLUCOSE POINT-OF-CARE VS TRADITIONAL LAB COMPARISONS
-- =========================================================================

    -- =======================================================================
    -- GLUCOSE ANALYSIS
    -- =======================================================================

        -- ===================================================================
        -- ANALYSIS of "POC GLUCOSE" (LabChemTestSID = "1000068127")
        -- ===================================================================
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

        SET @RowCount = @@ROWCOUNT;
        SET @StepTime = SYSDATETIME();
        PRINT 'POC Glucose records extracted: ' + CAST(@RowCount AS VARCHAR(10));
        PRINT 'Step completed in: ' + CAST(DATEDIFF(ms, @StartTime, @StepTime) AS VARCHAR(10)) + ' ms';
        PRINT '';

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

        SET @RowCount = @@ROWCOUNT;
        SET @StepTime = SYSDATETIME();
        PRINT 'Traditional Lab Glucose records extracted: ' + CAST(@RowCount AS VARCHAR(10));
        PRINT 'Step completed in: ' + CAST(DATEDIFF(ms, @StartTime, @StepTime) AS VARCHAR(10)) + ' ms';
        PRINT '';

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
-- FINAL RESULTS CONSOLIDATION - GLUCOSE ONLY
-- =========================================================================
-- Create the final consolidated results table containing only glucose paired test comparisons
-- This table structure matches the full version but contains exclusively glucose data
--
-- PERFORMANCE NOTE: Since this is glucose-only, no UNION operations are needed
-- The single test family data is directly formatted for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM #TEMP_Combined_Glucose;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired glucose test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard
    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- POC test specimen tracking number
            [First Sample Collection Date/Time],       -- When POC specimen was collected
            [First Test Name],                         -- POC test name (POC GLUCOSE)
            [First Test Result],                       -- POC test result value
            [First Test Result Unit],                  -- POC test result units
            [First Test Result Completion Date/Time],  -- When POC test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (GLUCOSE)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Glucose only)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table (glucose only)
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION - GLUCOSE FOCUS
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify glucose-specific components of the analysis.

        -- VALIDATION QUERY 1: Glucose Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the glucose procedure
        -- This ensures all required glucose tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID = 1000068127 THEN 'Point-of-Care (POC) Glucose'
                WHEN LabChemTestSID = 1000027461 THEN 'Traditional Laboratory Glucose'
                ELSE 'Other Test'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (1000068127, 1000027461)
        ORDER BY LabChemTestName;

        -- VALIDATION QUERY 2: Glucose Test Volume Check
        -- Use this to verify data availability and volume for glucose tests
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
            AND plc.LabChemTestSID IN (1000068127, 1000027461)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Glucose Output Format Check
        -- Use this to verify the structure and content of the final glucose output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific glucose scenarios
*/

    -- Display final result set with performance metrics in Messages tab
    DECLARE @FinalRowCount INT = @@ROWCOUNT;
    DECLARE @TotalTime INT = DATEDIFF(ms, @StartTime, SYSDATETIME());
    
    PRINT '=====================================';
    PRINT 'GLUCOSE COMPARISON QUERY COMPLETE';
    PRINT '=====================================';
    PRINT 'Total records returned: ' + CAST(@FinalRowCount AS VARCHAR(10));
    PRINT 'Total execution time: ' + CAST(@TotalTime AS VARCHAR(10)) + ' ms';
    PRINT 'Query completed at: ' + CONVERT(VARCHAR(30), SYSDATETIME(), 120);
    PRINT '';

-- END
-- GO
