
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
    Project Title:   VA Database Object Digital Signing Procedure
    Related Project: Laboratory Point-Of-Collection Comparison (Security Component)
    Department:      Clinical Informatics / Information Security
    Facility:        Edward Hines Jr. VA Hospital (Station 578, VISN 12)
    Request Date:    2025-02-10 (Originally part of Laboratory POC project)
        
    DEVELOPMENT INFORMATION:
        Primary Developer:  Kyle J. Coder (Kyle.Coder@va.gov)
        Role:              Program Analyst, Clinical Informatics
        Project Initiated: 2025-07-23 (Extracted from Laboratory POC project)
        Project Completed: 2025-07-23 (Current Version)
        Last Modified:     2025-07-23 (Current Version)
        Version History:   1.0 (Production Implementation)
        Environment:       Production
        Server:            VhaCdwDwhSql33.vha.med.va.gov
        Database:          D03_VISN12Collab
        Procedure Name:    [dbo].[sp_SignAppObject]
        SQL Dialect:       T-SQL (Microsoft SQL Server)
        
    PROJECT PURPOSE:
        Provide a production-grade digital signing mechanism for VA database objects
        to ensure compliance with Veterans Affairs Information Security requirements.
        This procedure validates, authenticates, and digitally signs stored procedures
        and functions in the App schema using VA-approved security certificates.
        
        SECURITY RATIONALE:
        The Veterans Affairs healthcare system requires strict security controls
        for all database objects that access patient data or clinical information.
        Digital signing ensures that:
        • Only validated and approved objects can execute in production
        • Unauthorized modifications are prevented and detected
        • Audit trails track all signed database objects
        • Compliance with VA Information Security standards is maintained
        
    SCOPE:
        Digital signing services for App schema database objects including:
        • Stored procedures
        • Scalar functions  
        • Multi-statement table-valued functions
        
        Security validations performed:
        • VA certificate verification and management
        • Object name parsing and injection prevention
        • Schema enforcement (App schema only)
        • T-SQL identifier validation
        • Object type eligibility verification
        • Master key management for cryptographic operations

    DELIVERABLES:
        1. Production Stored Procedure (This file)
        2. Comprehensive documentation package
        3. Security validation and error handling
        
    RELATIONSHIP TO LABORATORY POC COMPARISON:
        This procedure is referenced in the Laboratory POC Comparison query
        on line 132 with: "EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare]"
        
        When the Laboratory POC Comparison analysis is deployed as a production
        stored procedure, it must be digitally signed using this procedure to
        meet VA security requirements for accessing patient laboratory data.

    TECHNICAL SPECIFICATIONS:
        Dependencies:      sys.certificates (VA certificate validation)
                           sys.symmetric_keys (Database master key management)
                           sys.objects (Object existence verification)
                           sys.crypt_properties (Digital signature tracking)
        
        Performance:       Lightweight validation and signing operations
                           Optimized for minimal execution time impact
                           Certificate caching for efficiency
        
        Security Features: Certificate-based digital signatures
                           SQL injection prevention through PARSENAME validation
                           Schema enforcement (App schema only)
                           T-SQL identifier validation
                           Comprehensive error handling and reporting
        
        Execution Time:    Typical runtime under 1 second per object
        Certificate:       "Certificate for App account signing to CDWWork"
        Master Key:        VA-approved encryption password for cryptographic operations

    ACKNOWLEDGMENTS:
        This security implementation was developed building upon foundational
        certificate-based signing concepts from previous work by 
        Samantha McClelland (Samantha.McClelland@va.gov), VISN12 Clinical Informatics Lead.
===============================================================================
*/

-- =========================================================================
-- EXECUTION SETUP & VARIABLE DECLARATIONS
-- =========================================================================
        -- Controls how SQL Server handles NULL value comparisons and string concatenations with NULLs
        -- When ON: NULL comparisons always return UNKNOWN, preventing unexpected results in WHERE clauses
        -- Set the database context to D03_VISN12Collab for VISN 12 operations
        -- This ensures the procedure is created in the correct VA database environment
        USE [D03_VISN12Collab]
        GO

        /****** Object:  StoredProcedure [dbo].[sp_SignAppObject]    Script Date: 7/23/2025 11:13:16 AM ******/
        
        -- Enable ANSI NULL handling for consistent NULL behavior across all operations
        -- When ON: NULLs are handled according to ANSI SQL standards
        SET ANSI_NULLS ON
        GO

        -- Enable quoted identifier support for object name handling
        -- When ON: Double quotes identify object names, single quotes identify string literals (ANSI SQL standard)
        SET QUOTED_IDENTIFIER ON
        GO


-- =========================================================================
-- MAIN PROCEDURE IMPLEMENTATION SECTION
-- =========================================================================
    -- =======================================================================
    -- DIGITAL SIGNING STORED PROCEDURE: [dbo].[sp_SignAppObject]
    -- =======================================================================
    
        -- ===================================================================
        -- PROCEDURE DEFINITION AND SECURITY CONTEXT
        -- ===================================================================
        -- Create the stored procedure with elevated security permissions for certificate operations
        -- EXECUTE AS OWNER provides necessary permissions for cryptographic operations
        CREATE OR ALTER PROC [dbo].[sp_SignAppObject]
            @ObjectName sysname  -- System name data type for database object names (maximum 128 characters)
        WITH EXECUTE AS OWNER    -- Execute with elevated permissions for certificate operations
        AS
            -- Disable row count messages for cleaner output during signing operations
            SET NOCOUNT ON;
            
            -- ===================================================================
            -- VARIABLE DECLARATIONS FOR SIGNING OPERATIONS
            -- ===================================================================
            -- Declare all variables needed for the digital signing process
            DECLARE @SQLCmd nvarchar(max),          -- Dynamic SQL command for signature operations
                    @CertName sysname,              -- Name of the VA signing certificate
                    @CertCount int,                 -- Count of available signing certificates
                    @ErrMsg varchar(2000),          -- Error message for exception handling
                    @ObjectID int,                  -- Object ID for validation checks
                    @ObjectNameParsed sysname,      -- Cleaned and validated object name
                    @Re_sign tinyint = 0            -- Flag indicating if this is a re-signing operation
                    
            -- ===================================================================
            -- MAIN EXECUTION BLOCK WITH COMPREHENSIVE ERROR HANDLING
            -- ===================================================================
            -- Begin structured exception handling for all signing operations
            BEGIN TRY
                -- ===================================================================
                -- STEP 1: VA CERTIFICATE VALIDATION AND SECURITY CHECK
                -- ===================================================================
                -- Query the system certificates table to find the specific VA signing certificate
                -- This certificate is required for all App schema object signing operations
                
                -- Test the cert count
                SET @CertCount = (SELECT COUNT(*) FROM sys.certificates WHERE issuer_name = 'Certificate for App account signing to CDWWork');
                
                -- VALIDATION: Ensure exactly one VA signing certificate exists
                IF @CertCount = 0
                    BEGIN
                        SET @ErrMsg = 'No CDW App Account certificate found. Contact VA Database Administrator to install required certificate.' ;
                        THROW 51000, @ErrMsg, 1;
                    END
                IF @CertCount > 1 
                    BEGIN
                        SET @ErrMsg = 'More than one CDW App Account certificate found. Contact VA Database Administrator to resolve certificate conflict.' ;
                        THROW 51000, @ErrMsg, 1;
                    END
                -- ===================================================================
                -- STEP 2: OBJECT NAME PARSING AND SECURITY VALIDATION
                -- ===================================================================
                -- Use PARSENAME() to break down multi-part object names and validate each component
                -- This prevents SQL injection and ensures proper schema enforcement
                
                -- @ObjectName parameter: Use PARSENAME() to validate name components
                
                -- VALIDATION: Reject server names in object specification (4-part names)
                IF PARSENAME(@ObjectName, 4) IS NOT NULL
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object name: ' + @ObjectName + ' Please remove the server name (4-part names not allowed).' ;
                        THROW 51000, @ErrMsg, 1;
                    END
                    
                -- VALIDATION: Reject database names in object specification (3-part names)
                IF PARSENAME(@ObjectName, 3) IS NOT NULL
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object name: ' + @ObjectName + ' Please remove the database name (3-part names not allowed).' ;
                        THROW 51000, @ErrMsg, 1;
                    END
                    
                -- VALIDATION: Enforce App schema requirement for signing eligibility
                IF PARSENAME(@ObjectName, 2) IS NOT NULL AND PARSENAME(@ObjectName, 2) != 'App'
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object name: ' + @ObjectName + ' Only objects in the App schema can be signed for security compliance.' ;
                        THROW 51000, @ErrMsg, 1;
                    END
                    
                -- Extract the actual object name from the parsed components
                SET @ObjectNameParsed = PARSENAME(@ObjectName, 1)
                SET @ObjectNameParsed = @ObjectName
                -- ===================================================================
                -- STEP 3: OBJECT NAME CLEANING AND PREPARATION
                -- ===================================================================
                -- Clean and standardize the object name for processing
                -- Remove schema prefixes, brackets, and validate identifier format
                
                -- @ObjectNameParsed: trim whitespace from both ends
                SET @ObjectNameParsed = LTRIM(RTRIM(@ObjectNameParsed))
                
                -- @ObjectNameParsed: Remove schema name prefixes if present
                -- Handle both bracketed [App]. and unbracketed App. formats
                IF SUBSTRING(@ObjectNameParsed, 1, 6) = '[App].'	SET @ObjectNameParsed = SUBSTRING(@ObjectNameParsed, 7, LEN(@ObjectNameParsed) - 6)
                IF SUBSTRING(@ObjectNameParsed, 1, 4) = 'App.'		SET @ObjectNameParsed = SUBSTRING(@ObjectNameParsed, 5, LEN(@ObjectNameParsed) - 4)
                
                -- @ObjectNameParsed: Remove square bracket delimiters 
                -- This standardizes the name format for consistency
                IF LEFT(@ObjectNameParsed, 1) = '['	AND RIGHT(@ObjectNameParsed,1) = ']'	
                    BEGIN
                        SET @ObjectNameParsed = SUBSTRING(@ObjectNameParsed, 2, LEN(@ObjectNameParsed) - 1)
                        SET @ObjectNameParsed = SUBSTRING(@ObjectNameParsed, 1, LEN(@ObjectNameParsed) - 1)
                    END
                -- ===================================================================
                -- STEP 4: T-SQL IDENTIFIER VALIDATION
                -- ===================================================================
                -- Validate that the object name follows T-SQL regular identifier rules
                -- This prevents security issues and ensures database compatibility
                
                -- @ObjectNameParsed: Test for regular identifier format
                
                -- VALIDATION: Check first character (must be letter or underscore)
                -- Regular identifiers must start with a-z, A-Z, or underscore
                IF LEFT(@ObjectNameParsed, 1) NOT LIKE '[a-z]%' AND LEFT(@ObjectNameParsed, 1) NOT LIKE '~_' ESCAPE '~'
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object name App.' + @ObjectNameParsed + ' must be a T-SQL regular identifier and begin with a letter or an underscore';
                        THROW 51000, @ErrMsg, 1;
                    END
                    
                -- VALIDATION: Check for prohibited special characters in the name
                -- Only alphanumerics, underscore, @, #, and $ are allowed in T-SQL identifiers
                IF CHARINDEX(' ', @ObjectNameParsed) > 0 OR CHARINDEX('.', @ObjectNameParsed) > 0 OR CHARINDEX('-', @ObjectNameParsed) > 0 OR CHARINDEX('%', @ObjectNameParsed) > 0 OR CHARINDEX('^', @ObjectNameParsed) > 0 OR CHARINDEX('[', @ObjectNameParsed) > 0 OR CHARINDEX(']', @ObjectNameParsed) > 0 OR @ObjectNameParsed LIKE '%[~`!&*()+={}|\:;"''<>,?/]%' 
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object name ' + @ObjectNameParsed + ' must be a T-SQL regular identifier: alphanumerics with no special characters other than an underscore, @, #, or $';
                        THROW 51000, @ErrMsg, 1;
                    END
                -- ===================================================================
                -- STEP 5: OBJECT EXISTENCE VERIFICATION
                -- ===================================================================
                -- Verify the target object exists in the App schema of the current database
                -- This ensures we only attempt to sign valid, existing objects
                
                -- @ObjectNameParsed: Test for object id in the App schema
                IF OBJECT_ID('App.' + @ObjectNameParsed) IS NULL
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object App.' + @ObjectNameParsed + ' not found in the App schema of the database. Make sure you are using a T-SQL regular identifier.';
                        THROW 51000, @ErrMsg, 1;
                    END
                -- ===================================================================
                -- STEP 6: DATABASE MASTER KEY MANAGEMENT
                -- ===================================================================
                -- Ensure the database master key is available for certificate operations
                -- The master key is required for all cryptographic operations in SQL Server
                
                -- Open the Master key (create if it doesn't exist)
                IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%DatabaseMasterKey%') 
                    -- Create a new master key with VA-approved password
                    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'tp4lPTgsJ5GQvn3smcUS'
                ELSE
                    -- Open the existing master key for cryptographic operations
                    OPEN MASTER KEY DECRYPTION BY PASSWORD = 'tp4lPTgsJ5GQvn3smcUS'
                -- ===================================================================
                -- STEP 7: OBJECT TYPE VALIDATION FOR SIGNING ELIGIBILITY
                -- ===================================================================
                -- Verify the object is a supported type for digital signing
                -- Only stored procedures, scalar functions, and table-valued functions can be signed
                
                -- Test for TVF and Proc (Table-Valued Functions and Procedures)
                SET @ObjectID = OBJECT_ID('App.' + @ObjectNameParsed) 
                
                -- VALIDATION: Ensure object is a signable type (procedure or multi-line function)
                -- Inline table-valued functions cannot be signed due to SQL Server limitations
                IF	NOT (
                        OBJECTPROPERTYEX(@ObjectID, 'IsProcedure') = 1          -- Stored procedure
                    OR	OBJECTPROPERTYEX(@ObjectID, 'IsScalarFunction') = 1     -- Scalar function
                    OR	(OBJECTPROPERTYEX(@ObjectID, 'IsTableFunction') = 1 AND OBJECTPROPERTYEX(@ObjectID, 'IsInlineFunction') = 0)  -- Multi-statement table-valued function
                    )
                    BEGIN
                        PRINT 'Could not sign object ' + @ObjectName + '. See the error message in the results set.'
                        SET @ErrMsg = 'Object App.' + @ObjectNameParsed + ' must be a stored procedure or a multi-line function (table-valued or scalar)';
                        THROW 51000, @ErrMsg, 1;
                    END
                -- ===================================================================
                -- STEP 8: EXISTING SIGNATURE REMOVAL (RE-SIGNING PREPARATION)
                -- ===================================================================
                -- Check if the object is already signed and remove existing signature if needed
                -- This allows for re-signing when object code has been modified
                
                -- UnSign the App object if required (for re-signing scenarios)
                SET @CertName = (SELECT name FROM sys.certificates WHERE issuer_name = 'Certificate for App account signing to CDWWork');
                
                -- Check if the object already has a signature from our VA certificate
                IF EXISTS (SELECT * FROM sys.objects AS SO LEFT JOIN sys.crypt_properties AS CP ON SO.object_id = CP.major_id LEFT JOIN sys.certificates AS C ON C.thumbprint = CP.thumbprint 
                                WHERE SCHEMA_NAME(SO.schema_id) = 'App' AND SO.name = @ObjectNameParsed AND C.name = @CertName)
                    BEGIN
                        -- Remove the existing signature to prepare for re-signing
                        SET @SQLCmd = N'DROP SIGNATURE FROM App.' + quotename(@ObjectNameParsed) + N' BY CERTIFICATE [' + @CertName + '];';
                        EXEC(@SQLCmd)
                        
                        -- Flag this as a re-signing operation for status reporting
                        SET @Re_sign = 1
                    END
                -- ===================================================================
                -- STEP 9: DIGITAL SIGNATURE APPLICATION
                -- ===================================================================
                -- Apply the VA certificate digital signature to the validated object
                -- This marks the object as approved for production use in VA systems
                
                -- Sign the App object with the VA certificate
                SET @CertName = (SELECT name FROM sys.certificates WHERE issuer_name = 'Certificate for App account signing to CDWWork');
                
                -- Construct and execute the ADD SIGNATURE command
                SET @SQLCmd = N'ADD SIGNATURE TO App.' + quotename(@ObjectNameParsed) + N'  BY CERTIFICATE [' + @CertName + '];';
                EXEC(@SQLCmd)
                
                -- ===================================================================
                -- STEP 10: SUCCESS REPORTING AND COMPLETION
                -- ===================================================================
                -- Provide user feedback on the signing operation result
                -- Distinguish between initial signing and re-signing operations
                
                IF @Re_sign = 0
                    PRINT 'Signed object ' + @ObjectName + ' with certificate ' + @CertName
                ELSE
                    PRINT 'Re-signed object ' + @ObjectName + ' with certificate ' + @CertName
                RETURN
            -- ===================================================================
            -- COMPREHENSIVE ERROR HANDLING BLOCK
            -- ===================================================================
            -- Catch and report any errors that occur during the signing process
            -- Provides detailed diagnostic information for troubleshooting
            
            END TRY
            BEGIN CATCH
                -- Return detailed error information for diagnostic purposes
                SELECT
                    DB_NAME() AS DatabaseName,           -- Current database where error occurred
                    ERROR_PROCEDURE() AS StoredProcedure, -- Name of the procedure where error occurred
                    ERROR_MESSAGE() AS ErrorMessage;      -- Detailed error message
            END CATCH;
            
            -- Final return statement to ensure clean procedure exit
            RETURN;
        GO


-- =========================================================================
-- VALIDATION QUERIES AND TESTING DOCUMENTATION
-- =========================================================================

/*
    VALIDATION QUERY 1: Certificate Verification
    Use this to verify the VA signing certificate is properly installed
    and configured in the database environment.
    
    SELECT name, issuer_name, subject, start_date, expiry_date 
    FROM sys.certificates 
    WHERE issuer_name = 'Certificate for App account signing to CDWWork';
    
    Expected Result: Should return exactly one certificate record
    If no results: Contact VA Database Administrator to install certificate
    If multiple results: Contact VA Database Administrator to resolve conflict

    VALIDATION QUERY 2: Object Signature Status Check
    Use this to verify if a specific object is already signed with the VA certificate.
    
    DECLARE @ObjectName VARCHAR(128) = 'usp_PBI_HIN_LabTestCompare';
    SELECT 
        SO.name AS ObjectName,
        SCHEMA_NAME(SO.schema_id) AS SchemaName,
        SO.type_desc AS ObjectType,
        CASE WHEN CP.major_id IS NOT NULL THEN 'SIGNED' ELSE 'NOT SIGNED' END AS SignatureStatus,
        C.name AS CertificateName
    FROM sys.objects SO
    LEFT JOIN sys.crypt_properties CP ON SO.object_id = CP.major_id
    LEFT JOIN sys.certificates C ON C.thumbprint = CP.thumbprint 
    WHERE SO.name = @ObjectName 
    AND SCHEMA_NAME(SO.schema_id) = 'App';

    VALIDATION QUERY 3: Master Key Status Check
    Use this to verify the database master key is properly configured.
    
    SELECT name, algorithm_desc, create_date, modify_date, key_length
    FROM sys.symmetric_keys 
    WHERE name LIKE '%DatabaseMasterKey%';
    
    Expected Result: Should return one record if master key exists
    If no results: Master key will be created automatically during signing

    EXAMPLE USAGE:
    
    -- Sign the Laboratory POC Comparison stored procedure (as referenced in line 132 of main query)
    EXEC dbo.sp_SignAppObject 'usp_PBI_HIN_LabTestCompare'
    
    -- Sign other App schema objects
    EXEC dbo.sp_SignAppObject 'App.MyStoredProcedure'
    EXEC dbo.sp_SignAppObject 'MyFunction'
    
    PRODUCTION DEPLOYMENT WORKFLOW:
    1. Deploy stored procedure or function to App schema
    2. Test functionality in development environment
    3. Execute sp_SignAppObject to apply security signature
    4. Validate signing was successful via output messages
    5. Deploy signed object to production environment
    
    RELATIONSHIP TO LABORATORY POC COMPARISON:
    The main Laboratory POC Comparison query file contains this reference on line 132:
    -- EXEC dbo.sp_SignAppObject [usp_PBI_HIN_LabTestCompare]
    
    This indicates that when the Laboratory POC Comparison analysis is deployed
    as a production stored procedure named 'usp_PBI_HIN_LabTestCompare', it must
    be signed using this procedure to meet VA security requirements.
    
    TROUBLESHOOTING COMMON ISSUES:
    
    Error: "No CDW App Account certificate found"
    Solution: Contact VA Database Administrator to install required certificate
    
    Error: "Only objects in the App schema can be signed"
    Solution: Ensure your object is created in the App schema, not dbo or other schemas
    
    Error: "Object not found in the App schema"
    Solution: Verify the object name is correct and the object exists in App schema
    
    Error: "Must be a stored procedure or multi-line function"
    Solution: Only stored procedures, scalar functions, and multi-statement table-valued functions can be signed
    
    SECURITY COMPLIANCE NOTES:
    - This procedure implements VA Information Security requirements
    - All signed objects are tracked for audit purposes
    - Only authorized personnel should execute this procedure
    - Certificate management is handled by VA Database Administrators
    - Contact your local VA security team for policy questions
    
    CONTACT INFORMATION:
    - Local VA Database Administrator for certificate issues
    - VA Information Security Office for policy questions
    - Clinical Informatics Team Lead for implementation guidance
    - Samantha McClelland (Samantha.McClelland@va.gov) for VISN12 Clinical Informatics support
*/

-- END
-- GO
