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
    Project Title:   Laboratory Point-Of-Collection Comparison (HEMOGLOBIN ONLY)
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-22 (HEMOGLOBIN-ONLY Version)
        Version History:   Specialized version focusing exclusively on hemoglobin comparisons
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[usp_PBI_HIN_LabTestCompare_Hemoglobin]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have hemoglobin tests conducted within short timeframes that yield
        dramatically different results between iSTAT POC and traditional laboratory methods.
        
        CLINICAL RATIONALE:
        Hemoglobin tests collected via iSTAT POC methods should ideally produce similar
        results to the same tests performed in traditional laboratory settings within
        a short timeframe. Significant discrepancies between these paired results
        indicate potential issues requiring clinical investigation, such as:
        • Patient condition changes between collections (anemia fluctuation)
        • Sample collection methodology differences
        • Equipment calibration variations between iSTAT and lab analyzers
        • Processing method discrepancies
        • Sample handling and storage variations
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired hemoglobin test results:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • iSTAT Hemoglobin vs Lab Hemoglobin (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file - Hemoglobin Only)
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
        
        Data Volume:       Processes approximately 1,000-6,000 hemoglobin test results per fiscal year
        Execution Time:    Typical runtime 30-60 seconds for hemoglobin-only analysis
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
        
        Lab Test SIDs:     1000114342 (iSTAT Hemoglobin), 1000036429 (Lab Hemoglobin)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        This specialized version focuses exclusively on hemoglobin test comparisons.
===============================================================================
*/


-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
-- CREATE OR ALTER PROCEDURE [App].[usp_PBI_HIN_LabTestCompare_Hemoglobin]    
-- AS
-- BEGIN
    SET NOCOUNT OFF;  -- Allow result counts to be displayed in Messages tab

    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare_Hemoglobin]
    
    -- Performance and diagnostic variables for execution tracking
    DECLARE @StartTime DATETIME2 = SYSDATETIME();
    DECLARE @StepTime DATETIME2;
    DECLARE @RowCount INT;
    
    PRINT '========================================';
    PRINT 'HEMOGLOBIN COMPARISON ANALYSIS STARTED';
    PRINT 'Start Time: ' + FORMAT(@StartTime, 'yyyy-MM-dd HH:mm:ss.fff');
    PRINT '========================================';
    
    -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
    DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (578)

    -- Date Range Parameters - Automatically sets fiscal year to date range
    -- Fiscal year runs from October 1 of previous calendar year through September 30 of current calendar year
    DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
    DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

-- =========================================================================
-- RAW DATA COLLECTION & CONSOLIDATION - LABORATORY HEMOGLOBIN POINT-OF-CARE VS TRADITIONAL LAB COMPARISONS
-- =========================================================================

    -- =======================================================================
    -- HEMOGLOBIN ANALYSIS
    -- =======================================================================

        -- ===================================================================
        -- ANALYSIS of "iSTAT HEMOGLOBIN" (LabChemTestSID = "1000114342")
        -- ===================================================================
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

        SET @RowCount = @@ROWCOUNT;
        SET @StepTime = SYSDATETIME();
        PRINT 'iSTAT Hemoglobin records extracted: ' + CAST(@RowCount AS VARCHAR(10));
        PRINT 'Step completed in: ' + CAST(DATEDIFF(ms, @StartTime, @StepTime) AS VARCHAR(10)) + ' ms';
        PRINT '';

        -- ===================================================================
        -- ANALYSIS of "HEMOGLOBIN" (LabChemTestSID = "1000036429")
        -- ===================================================================
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

        SET @RowCount = @@ROWCOUNT;
        SET @StepTime = SYSDATETIME();
        PRINT 'Traditional Lab Hemoglobin records extracted: ' + CAST(@RowCount AS VARCHAR(10));
        PRINT 'Step completed in: ' + CAST(DATEDIFF(ms, @StartTime, @StepTime) AS VARCHAR(10)) + ' ms';
        PRINT '';

        -- ===================================================================
        -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT HEMOGLOBIN" (LabChemTestSID = "1000114342") versus "HEMOGLOBIN" (LabChemTestSID = "1000036429")
        -- ===================================================================
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
-- FINAL RESULTS CONSOLIDATION - HEMOGLOBIN ONLY
-- =========================================================================
-- Create the final consolidated results table containing only hemoglobin paired test comparisons
-- This table structure matches the full version but contains exclusively hemoglobin data
--
-- PERFORMANCE NOTE: Since this is hemoglobin-only, no UNION operations are needed
-- The single test family data is directly formatted for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM #TEMP_Combined_Hemoglobin;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired hemoglobin test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard
    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- iSTAT test specimen tracking number
            [First Sample Collection Date/Time],       -- When iSTAT specimen was collected
            [First Test Name],                         -- iSTAT test name (POC Hemoglobin)
            [First Test Result],                       -- iSTAT test result value
            [First Test Result Unit],                  -- iSTAT test result units
            [First Test Result Completion Date/Time],  -- When iSTAT test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (Hemoglobin)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Hemoglobin only)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table (hemoglobin only)
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION - HEMOGLOBIN FOCUS
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify hemoglobin-specific components of the analysis.

        -- VALIDATION QUERY 1: Hemoglobin Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the hemoglobin procedure
        -- This ensures all required hemoglobin tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID = 1000114342 THEN 'Point-of-Care (iSTAT) Hemoglobin'
                WHEN LabChemTestSID = 1000036429 THEN 'Traditional Laboratory Hemoglobin'
                ELSE 'Other Test'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (1000114342, 1000036429)
        ORDER BY LabChemTestName;

        -- VALIDATION QUERY 2: Hemoglobin Test Volume Check
        -- Use this to verify data availability and volume for hemoglobin tests
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
            AND plc.LabChemTestSID IN (1000114342, 1000036429)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Hemoglobin Output Format Check
        -- Use this to verify the structure and content of the final hemoglobin output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific hemoglobin scenarios
*/

    -- Display final result set with performance metrics in Messages tab
    DECLARE @FinalRowCount INT = @@ROWCOUNT;
    DECLARE @TotalTime INT = DATEDIFF(ms, @StartTime, SYSDATETIME());
    
    PRINT '=====================================';
    PRINT 'HEMOGLOBIN COMPARISON QUERY COMPLETE';
    PRINT '=====================================';
    PRINT 'Total records returned: ' + CAST(@FinalRowCount AS VARCHAR(10));
    PRINT 'Total execution time: ' + CAST(@TotalTime AS VARCHAR(10)) + ' ms';
    PRINT 'Query completed at: ' + CONVERT(VARCHAR(30), SYSDATETIME(), 120);
    PRINT '';

-- END
-- GO
