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
    Project Title:   Laboratory Point-Of-Collection Comparison (HEMATOCRIT ONLY)
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-22 (HEMATOCRIT-ONLY Version)
        Version History:   Specialized version focusing exclusively on hematocrit comparisons
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[usp_PBI_HIN_LabTestCompare_Hematocrit]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have hematocrit tests conducted within short timeframes that yield
        dramatically different results between iSTAT POC and traditional laboratory methods.
        
        CLINICAL RATIONALE:
        Hematocrit tests collected via iSTAT POC methods should ideally produce similar
        results to the same tests performed in traditional laboratory settings within
        a short timeframe. Significant discrepancies between these paired results
        indicate potential issues requiring clinical investigation, such as:
        • Patient condition changes between collections (blood volume fluctuation)
        • Sample collection methodology differences
        • Equipment calibration variations between iSTAT and lab analyzers
        • Processing method discrepancies
        • Sample handling and storage variations
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired hematocrit test results:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • iSTAT Hematocrit vs Lab Hematocrit (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file - Hematocrit Only)
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
        
        Data Volume:       Processes approximately 1,000-6,000 hematocrit test results per fiscal year
        Execution Time:    Typical runtime 30-60 seconds for hematocrit-only analysis
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
        
        Lab Test SIDs:     1000114341 (iSTAT Hematocrit), 1000048470 (Lab Hematocrit)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        This specialized version focuses exclusively on hematocrit test comparisons.
===============================================================================
*/


-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
-- CREATE OR ALTER PROCEDURE [App].[usp_PBI_HIN_LabTestCompare_Hematocrit]    
-- AS
-- BEGIN

    -- Turn off row count to display messages in Messages tab
    SET NOCOUNT OFF;

    -- Initialize timing variables for performance tracking
    DECLARE @StartTime DATETIME2 = SYSDATETIME();
    DECLARE @StepTime DATETIME2;
    DECLARE @RowCount INT;

    PRINT '==========================================';
    PRINT 'HEMATOCRIT COMPARISON QUERY STARTED';
    PRINT '==========================================';
    PRINT 'Query started at: ' + CONVERT(VARCHAR(30), @StartTime, 120);
    PRINT '';

    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare_Hematocrit]
    
    -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
    DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (578)

    -- Date Range Parameters - Automatically sets fiscal year to date range
    -- Fiscal year runs from October 1 of previous calendar year through September 30 of current calendar year
    DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
    DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

-- =========================================================================
-- RAW DATA COLLECTION & CONSOLIDATION - LABORATORY HEMATOCRIT POINT-OF-CARE VS TRADITIONAL LAB COMPARISONS
-- =========================================================================

    -- =======================================================================
    -- HEMATOCRIT ANALYSIS
    -- =======================================================================

        -- ===================================================================
        -- ANALYSIS of "iSTAT HEMATOCRIT" (LabChemTestSID = "1000114341")
        -- ===================================================================
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

        SET @RowCount = @@ROWCOUNT;
        SET @StepTime = SYSDATETIME();
        PRINT 'iSTAT Hematocrit records extracted: ' + CAST(@RowCount AS VARCHAR(10));
        PRINT 'Step completed in: ' + CAST(DATEDIFF(ms, @StartTime, @StepTime) AS VARCHAR(10)) + ' ms';
        PRINT '';

        -- ===================================================================
        -- ANALYSIS of "HEMATOCRIT" (LabChemTestSID = "1000048470")
        -- ===================================================================
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

        -- ===================================================================
        -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT HEMATOCRIT" (LabChemTestSID = "1000114341") versus "HEMATOCRIT" (LabChemTestSID = "1000048470")
        -- ===================================================================
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
-- FINAL RESULTS CONSOLIDATION - HEMATOCRIT ONLY
-- =========================================================================
-- Create the final consolidated results table containing only hematocrit paired test comparisons
-- This table structure matches the full version but contains exclusively hematocrit data
--
-- PERFORMANCE NOTE: Since this is hematocrit-only, no UNION operations are needed
-- The single test family data is directly formatted for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM #TEMP_Combined_Hematocrit;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired hematocrit test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard
    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- iSTAT test specimen tracking number
            [First Sample Collection Date/Time],       -- When iSTAT specimen was collected
            [First Test Name],                         -- iSTAT test name (iSTAT Hematocrit)
            [First Test Result],                       -- iSTAT test result value
            [First Test Result Unit],                  -- iSTAT test result units
            [First Test Result Completion Date/Time],  -- When iSTAT test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (Hematocrit)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Hematocrit only)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table (hematocrit only)
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION - HEMATOCRIT FOCUS
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify hematocrit-specific components of the analysis.

        -- VALIDATION QUERY 1: Hematocrit Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the hematocrit procedure
        -- This ensures all required hematocrit tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID = 1000114341 THEN 'Point-of-Care (iSTAT) Hematocrit'
                WHEN LabChemTestSID = 1000048470 THEN 'Traditional Laboratory Hematocrit'
                ELSE 'Other Test'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (1000114341, 1000048470)
        ORDER BY LabChemTestName;

        -- VALIDATION QUERY 2: Hematocrit Test Volume Check
        -- Use this to verify data availability and volume for hematocrit tests
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
            AND plc.LabChemTestSID IN (1000114341, 1000048470)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Hematocrit Output Format Check
        -- Use this to verify the structure and content of the final hematocrit output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific hematocrit scenarios
*/

-- END
-- GO
