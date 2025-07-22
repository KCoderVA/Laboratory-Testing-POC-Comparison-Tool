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
    Project Title:   Laboratory Point-Of-Collection Comparison (TROPONIN ONLY)
    Requestor:       Carrie Carlson (Carrie.Carlson@va.gov)
    Department:      Pathology and Laboratory Medicine Service
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-02-10
        Project Completed: 2025-03-21
        Last Modified:     2025-07-22 (TROPONIN-ONLY Version)
        Version History:   Specialized version focusing exclusively on troponin comparisons
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [App].[usp_PBI_HIN_LabTestCompare_Troponin]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Develop an automatically populated GUI report enabling Laboratory Management
        at Edward Hines Jr. VA Hospital to identify and investigate outliers when
        patients have troponin tests conducted within short timeframes that yield
        dramatically different results between iSTAT POC and traditional laboratory methods.
        
        CLINICAL RATIONALE:
        Troponin tests collected via iSTAT POC methods should ideally produce similar
        results to high sensitivity troponin tests performed in traditional laboratory
        settings within a short timeframe. Significant discrepancies between these paired
        results indicate potential issues requiring clinical investigation, such as:
        • Patient condition changes between collections (cardiac event progression)
        • Sample collection methodology differences
        • Equipment calibration variations between iSTAT and lab analyzers
        • Processing method discrepancies (standard vs high-sensitivity assays)
        • Sample handling and storage variations
        
    SCOPE:
        Fiscal Year To Date (FYTD) comparison of paired troponin test results:
        
        POC Tests vs Traditional Lab Tests (Time Windows):
        • iSTAT Troponin vs High Sensitivity Troponin I (30 minutes)

    DELIVERABLES:
        1. SQL Stored Procedure (This file - Troponin Only)
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
        
        Data Volume:       Processes approximately 500-3,000 troponin test results per fiscal year
        Execution Time:    Typical runtime 30-60 seconds for troponin-only analysis
        
        Output Format:     Structured for PowerBI consumption with standardized column names
                           Includes data refresh timestamp for cache management
                           Special numeric formatting for troponin precision requirements
        
        Lab Test SIDs:     1000113247 (iSTAT Troponin), 1600022143 (High Sensitivity Troponin I)

    ACKNOWLEDGMENTS:
        This solution was developed building upon foundational analysis concepts
        from previous work by Nik Ljubic (Nikola.Ljubic@va.gov) at Milwaukee VAMC.
        This specialized version focuses exclusively on troponin test comparisons.
===============================================================================
*/


-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
-- CREATE OR ALTER PROCEDURE [App].[usp_PBI_HIN_LabTestCompare_Troponin]    
-- AS
-- BEGIN
    SET NOCOUNT ON;  -- Prevents extra result sets from interfering with SELECT statements

    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare_Troponin]
    
    -- Establish the VA facility's station number as a parameter that will be referenced throughout the procedure
    DECLARE @FacilityStationNumber INT = 578  -- Defaulted to Edward Hines Jr. VA Hospital (578)

    -- Date Range Parameters - Automatically sets fiscal year to date range
    -- Fiscal year runs from October 1 of previous calendar year through September 30 of current calendar year
    DECLARE @StartDate DATETIME2(0) = CAST('10/1/' + CAST(YEAR(GETDATE()) - 1 AS VARCHAR) AS DATETIME2(0)); -- Fiscal year start: October 1st
    DECLARE @EndDate   DATETIME2(0) = CAST(GETDATE() AS DATE);                                              -- Current date for FYTD analysis

-- =========================================================================
-- RAW DATA COLLECTION & CONSOLIDATION - LABORATORY TROPONIN POINT-OF-CARE VS TRADITIONAL LAB COMPARISONS
-- =========================================================================

    -- =======================================================================
    -- TROPONIN ANALYSIS
    -- =======================================================================

        -- ===================================================================
        -- ANALYSIS of "iSTAT TROPONIN" (LabChemTestSID = "1000113247")
        -- ===================================================================
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

        -- ===================================================================
        -- ANALYSIS of "HIGH SENSITIVITY TROPONIN I" (LabChemTestSID = "1600022143")
        -- ===================================================================
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

        -- ===================================================================
        -- COMPARISON & CONSOLIDATION OF TESTING FAMILY: "iSTAT TROPONIN" (LabChemTestSID = "1000113247") versus "HIGH SENSITIVITY TROPONIN I" (LabChemTestSID = "1600022143")
        -- ===================================================================
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
-- FINAL RESULTS CONSOLIDATION - TROPONIN ONLY
-- =========================================================================
-- Create the final consolidated results table containing only troponin paired test comparisons
-- This table structure matches the full version but contains exclusively troponin data
--
-- PERFORMANCE NOTE: Since this is troponin-only, no UNION operations are needed
-- The single test family data is directly formatted for PowerBI consumption
    DROP TABLE IF EXISTS #TEMP_Combined_Results;
    SELECT  *, 
            FORMAT(GETDATE(), 'MM/dd/yyyy HH:mm:ss') AS [Data_Refresh_Timestamp]
    INTO #TEMP_Combined_Results
    FROM #TEMP_Combined_Troponin;

-- =========================================================================
-- FINAL OUTPUT FOR POWERBI CONSUMPTION
-- =========================================================================
-- Return the consolidated paired troponin test comparison results for PowerBI reporting
-- This is the final output that will be consumed by the PowerBI dashboard
    SELECT  [Patient Name],                            -- Patient identification for analysis
            [Last4 SSN],                               -- Privacy-compliant patient identifier
            [First Sample Accession Number],           -- iSTAT test specimen tracking number
            [First Sample Collection Date/Time],       -- When iSTAT specimen was collected
            [First Test Name],                         -- iSTAT test name (TROPONIN ISTAT)
            [First Test Result],                       -- iSTAT test result value (formatted)
            [First Test Result Unit],                  -- iSTAT test result units
            [First Test Result Completion Date/Time],  -- When iSTAT test was completed
            [Second Sample Accession Number],          -- Lab test specimen tracking number
            [Second Sample Collection Date/Time],      -- When lab specimen was collected
            [Second Test Name],                        -- Lab test name (HIGH SENSITIVITY TROPONIN I)
            [Second Test Result],                      -- Lab test result value
            [Second Test Result Unit],                 -- Lab test result units
            [Second Test Result Completion Date/Time], -- When lab test was completed
            [Collection Location],                     -- Department/location where tests were requested
            [LabTestFamily],                          -- Test family grouping (Troponin only)
            [Data_Refresh_Timestamp],                 -- Timestamp for data refresh tracking in PowerBI
            LEFT([First Sample Collection Date/Time], 10) AS 'Simple_Date'  -- Simplified date format for PowerBI filtering
    FROM    #TEMP_Combined_Results                     -- Final consolidated results table (troponin only)
    ORDER BY [LabTestFamily],                         -- Group by test type for organized reporting
             [First Sample Collection Date/Time] DESC; -- Most recent tests first within each group
/*
    -- =========================================================================
    -- REFERENCE QUERIES FOR TROUBLESHOOTING AND VALIDATION - TROPONIN FOCUS
    -- =========================================================================

        The following queries are provided for troubleshooting and validation purposes.
        They can be run independently to verify troponin-specific components of the analysis.

        -- VALIDATION QUERY 1: Troponin Lab Chemistry Test Names and SIDs Verification
        -- Use this to verify test names and SIDs used in the troponin procedure
        -- This ensures all required troponin tests are properly identified in the CDW system
        SELECT DISTINCT 
            LabChemTestSID,
            LabChemTestName,
            CASE 
                WHEN LabChemTestSID = 1000113247 THEN 'Point-of-Care (iSTAT) Troponin'
                WHEN LabChemTestSID = 1600022143 THEN 'Traditional Laboratory High Sensitivity Troponin I'
                ELSE 'Other Test'
            END AS TestCategory
        FROM   [CDWWork].[Dim].[LabChemTest]
        WHERE  LabChemTestSID IN (1000113247, 1600022143)
        ORDER BY LabChemTestName;

        -- VALIDATION QUERY 2: Troponin Test Volume Check
        -- Use this to verify data availability and volume for troponin tests
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
            AND plc.LabChemTestSID IN (1000113247, 1600022143)
            AND plc.LabChemCompleteDateTime >= @StartDate_Check
            AND plc.LabChemCompleteDateTime <= @EndDate_Check
        GROUP BY lt.LabChemTestName
        ORDER BY lt.LabChemTestName;

        -- VALIDATION QUERY 3: Sample Troponin Output Format Check
        -- Use this to verify the structure and content of the final troponin output
        -- (This would execute a limited version of the main procedure)
        -- Note: Uncomment and modify as needed for testing specific troponin scenarios
*/

-- END
-- GO
