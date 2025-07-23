# Technical Implementation Guide

This guide provides detailed technical information for IT professionals, database administrators, and informatics specialists implementing the Laboratory Testing POC Comparison project.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Database Requirements](#database-requirements)
- [Installation Guide](#installation-guide)
- [Stored Procedure Deployment](#stored-procedure-deployment)
- [Configuration Management](#configuration-management)
- [Performance Optimization](#performance-optimization)
- [Security Implementation](#security-implementation)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Integration Patterns](#integration-patterns)
- [Troubleshooting](#troubleshooting)

## Architecture Overview

### System Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │  SQL Processing │    │   Presentation  │
│                 │    │                 │    │                 │
│ • CDWWork Lab   │───▶│ • [App].[LabTest│───▶│ • PowerBI       │
│   Database      │    │   _POC_Compare] │    │   Dashboard     │
│ • Test Results  │    │ • Security      │    │ • SQL Results   │
│ • Patient Data  │    │   Signing       │    │ • Reports       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Data Flow
1. **Data Extraction:** SQL queries access CDWWork laboratory tables
2. **Data Processing:** Time-based correlation and statistical analysis  
3. **Security Signing:** VA-compliant digital signature via sp_SignAppObject
4. **Data Presentation:** Results via PowerBI DirectQuery or SQL output
5. **Quality Monitoring:** Automated alerts and trending analysis

### Technology Stack
- **Database:** SQL Server 2016+ with VA CDW access
- **Analytics:** T-SQL stored procedures (`[App].[LabTest_POC_Compare]`)
- **Security:** Certificate-based signing (`[dbo].[sp_SignAppObject]`)
- **Visualization:** Microsoft PowerBI Desktop/Service with DirectQuery
- **Development:** VS Code with SQL extensions or SSMS
- **Version Control:** Git with secure file handling
- **Documentation:** Comprehensive markdown documentation

## Database Requirements

### VA-Specific Requirements
- **CDW Access:** Connection to `VhaCdwDwhSql33.vha.med.va.gov`
- **NDS Operational Access:** PHI/Real SSN data access approval
- **Database Schema:** Write access to facility's App schema (for stored procedures)
- **Security Certificate:** VA-approved signing certificate installed

### Minimum Technical Requirements
- **SQL Server 2016 or later** (Enterprise edition recommended for CDW)
- **Memory:** 8GB RAM minimum for large dataset processing
- **Storage:** 50GB+ for typical facility data volume
- **Network:** Secure VA network connectivity
- **CPU:** 2 cores minimum, 4+ cores recommended

### Database Permissions
```sql
-- Minimum required permissions for execution account
GRANT SELECT ON [dbo].[Dim_Location] TO [LabPOCUser]
GRANT SELECT ON [dbo].[Chem_PatientLabChem] TO [LabPOCUser]
GRANT SELECT ON [dbo].[Dim_LabChemTest] TO [LabPOCUser]
GRANT SELECT ON [dbo].[Sta3n_SPatient_SPatientSID] TO [LabPOCUser]

-- Optional: Create dedicated schema for POC analysis
CREATE SCHEMA [LabPOC]
GRANT ALL ON SCHEMA::[LabPOC] TO [LabPOCUser]
```

### Table Dependencies
**Required Tables:**
- `Dim_Location` - Facility and location information
- `Chem_PatientLabChem` - Laboratory test results
- `Dim_LabChemTest` - Test definitions and metadata
- `Sta3n_SPatient_SPatientSID` - Patient demographic information

**Table Relationships:**
```sql
-- Key relationships used in queries
Chem_PatientLabChem.Sta3n = Dim_Location.Sta3n
Chem_PatientLabChem.LabChemTestSID = Dim_LabChemTest.LabChemTestSID
Chem_PatientLabChem.PatientSID = Sta3n_SPatient_SPatientSID.PatientSID
```

### Indexing Strategy
**Recommended Indexes:**
```sql
-- Performance critical indexes
CREATE NONCLUSTERED INDEX IX_Chem_PatientLabChem_Performance
ON [dbo].[Chem_PatientLabChem] (
    [LabChemTestSID],
    [LabChemCompleteDateTime],
    [Sta3n]
) INCLUDE ([PatientSID], [LabChemNumericResult])

CREATE NONCLUSTERED INDEX IX_Chem_PatientLabChem_Patient_Date
ON [dbo].[Chem_PatientLabChem] (
    [PatientSID],
    [LabChemCompleteDateTime]
) INCLUDE ([LabChemTestSID], [LabChemNumericResult])
```

## Installation Guide

### Step 1: Environment Preparation
```powershell
# Verify SQL Server version
sqlcmd -Q "SELECT @@VERSION"

# Check available memory
sqlcmd -Q "SELECT physical_memory_kb/1024 AS Memory_MB FROM sys.dm_os_sys_info"

# Verify database permissions
sqlcmd -d YourDatabase -Q "SELECT HAS_PERMS_BY_NAME('Chem_PatientLabChem', 'OBJECT', 'SELECT')"
```

### Step 2: Database Setup
```sql
-- Create dedicated database (optional)
CREATE DATABASE [LabPOCAnalysis]
GO

-- Set database options for performance
ALTER DATABASE [LabPOCAnalysis] SET RECOVERY SIMPLE
ALTER DATABASE [LabPOCAnalysis] SET AUTO_UPDATE_STATISTICS_ASYNC ON
ALTER DATABASE [LabPOCAnalysis] SET READ_COMMITTED_SNAPSHOT ON
```

### Step 3: Deploy SQL Objects
```sql
-- Deploy main stored procedure
-- Execute: Laboratory POC Comparison (updated July 2025).sql

-- Deploy individual test procedures
-- Execute each: LabPOC_Compare_[TestType](July2025).sql

-- Verify deployment
SELECT name, create_date, modify_date 
FROM sys.objects 
WHERE type = 'P' AND name LIKE '%LabPOC%'
```

### Step 4: PowerBI Configuration
```powershell
# Install PowerBI Desktop (if not already installed)
# Download from: https://powerbi.microsoft.com/desktop
```

## Stored Procedure Deployment

### Overview
The Laboratory POC Comparison tool can operate in two modes:
1. **Query Mode:** Direct SQL execution with CSV-like results
2. **Stored Procedure Mode:** Database-deployed procedure for PowerBI integration

### Deployment Prerequisites
- Database write permissions to facility's App schema
- VA signing certificate installed (`Certificate for App account signing to CDWWork`)
- Access to deploy `[dbo].[sp_SignAppObject]` security procedure

### Step-by-Step Deployment

#### 1. Prepare the Main Analysis File
```sql
-- Open: LabTest_POC_Compare_Analysis.sql
-- Locate lines around 260 and UNCOMMENT the following:

CREATE OR ALTER PROCEDURE [App].[LabTest_POC_Compare]    
AS
BEGIN
EXEC dbo.sp_SignAppObject [LabTest_POC_Compare]

-- [All existing query logic remains here]

-- Locate end of file and UNCOMMENT:
END
GO
```

#### 2. Deploy Security Signing Procedure
```sql
-- First deploy the security procedure from: [dbo].[sp_SignAppObject].sql
-- This must be deployed BEFORE the main procedure for signing to work

-- Verify certificate exists:
SELECT name, issuer_name, subject, start_date, expiry_date 
FROM sys.certificates 
WHERE issuer_name = 'Certificate for App account signing to CDWWork';

-- Expected: One certificate record, otherwise contact VA DBA
```

#### 3. Execute Main Procedure Deployment
```sql
-- Execute the modified LabTest_POC_Compare_Analysis.sql file
-- This creates [App].[LabTest_POC_Compare] in your facility's database

-- Verify creation:
SELECT name, create_date, modify_date, type_desc
FROM sys.objects 
WHERE name = 'LabTest_POC_Compare' AND type = 'P';
```

#### 4. Apply Security Signature
```sql
-- Sign the procedure for VA compliance:
EXEC dbo.sp_SignAppObject 'LabTest_POC_Compare'

-- Expected output: "Signed object LabTest_POC_Compare with certificate [CertName]"

-- Verify signature:
SELECT 
    SO.name AS ObjectName,
    SCHEMA_NAME(SO.schema_id) AS SchemaName,
    CASE WHEN CP.major_id IS NOT NULL THEN 'SIGNED' ELSE 'NOT SIGNED' END AS SignatureStatus,
    C.name AS CertificateName
FROM sys.objects SO
LEFT JOIN sys.crypt_properties CP ON SO.object_id = CP.major_id
LEFT JOIN sys.certificates C ON C.thumbprint = CP.thumbprint 
WHERE SO.name = 'LabTest_POC_Compare';
```

#### 5. Grant Execution Permissions
```sql
-- Grant permissions to PowerBI service account and authorized users:
GRANT EXECUTE ON [App].[LabTest_POC_Compare] TO [PowerBI_ServiceAccount];
GRANT EXECUTE ON [App].[LabTest_POC_Compare] TO [Laboratory_Users];

-- Replace with your facility's actual account names
```

#### 6. Test Procedure Execution
```sql
-- Test the deployed procedure:
EXEC [App].[LabTest_POC_Compare];

-- Expected: Same results as query mode, but from stored procedure
-- Verify execution time and result set structure
```

### PowerBI Integration with Stored Procedure

#### DirectQuery Connection
```sql
-- PowerBI Connection Settings:
-- Server: VhaCdwDwhSql33.vha.med.va.gov  
-- Database: [Your_Facility_Database]
-- Data Connectivity mode: DirectQuery
-- Custom SQL Query: EXEC [App].[LabTest_POC_Compare]
```

#### Automated Refresh Configuration
```sql
-- Schedule procedure execution via SQL Server Agent (optional):
USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'Laboratory POC Comparison - Daily Refresh',
    @enabled = 1;

EXEC dbo.sp_add_jobstep
    @job_name = N'Laboratory POC Comparison - Daily Refresh',
    @step_name = N'Execute Analysis',
    @command = N'EXEC [App].[LabTest_POC_Compare]',
    @database_name = N'[Your_Facility_Database]';

-- Configure schedule as needed for your facility's reporting requirements
```

### Deployment Validation Checklist

- [ ] `[dbo].[sp_SignAppObject]` deployed successfully
- [ ] VA signing certificate verified and accessible
- [ ] `[App].[LabTest_POC_Compare]` created without errors
- [ ] Procedure signed with security certificate
- [ ] Execution permissions granted to appropriate accounts
- [ ] Test execution returns expected results
- [ ] PowerBI connection established (if applicable)
- [ ] Performance meets expectations (<30 seconds typical)

### Rollback Procedures

#### Remove Stored Procedure
```sql
-- If deployment needs to be reversed:
DROP PROCEDURE IF EXISTS [App].[LabTest_POC_Compare];

-- Verify removal:
SELECT name FROM sys.objects WHERE name = 'LabTest_POC_Compare';
-- Should return no results
```

#### Revert to Query Mode
1. Re-comment the stored procedure lines in the SQL file
2. Uncomment the variable declarations
3. Use direct query execution instead of stored procedure calls
# Download from: https://powerbi.microsoft.com/desktop/

# Configure data source in PowerBI
# 1. Open Laboratory Testing POC Comparison.pbix
# 2. Transform Data > Data Source Settings
# 3. Update server and database connections
# 4. Configure authentication (Windows or SQL)
# 5. Refresh data to test connection
```

### Step 5: Validation Testing
```sql
-- Test execution with small date range
EXEC [App].[LabTest_POC_Compare]

-- For query mode testing, use the LabTest_POC_Compare_Analysis.sql file directly
-- Verify performance
SET STATISTICS IO ON
SET STATISTICS TIME ON
-- Re-run test query
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
```

## Configuration Management

### Environment Configuration
```sql
-- Environment-specific configuration table
CREATE TABLE [LabPOC].[Configuration] (
    ConfigKey NVARCHAR(100) PRIMARY KEY,
    ConfigValue NVARCHAR(500),
    Description NVARCHAR(1000),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(100) DEFAULT SYSTEM_USER
)

-- Insert default configuration
INSERT INTO [LabPOC].[Configuration] VALUES
('FacilityStationNumber', '578', 'Default facility station number', GETDATE(), SYSTEM_USER),
('DefaultTimeWindow', '240', 'Default comparison time window in minutes', GETDATE(), SYSTEM_USER),
('MaxExecutionMinutes', '30', 'Maximum allowed query execution time', GETDATE(), SYSTEM_USER)
```

### Test SID Mapping
```sql
-- Test SID mapping table for multi-facility support
CREATE TABLE [LabPOC].[TestMapping] (
    MappingID INT IDENTITY(1,1) PRIMARY KEY,
    FacilityStationNumber VARCHAR(10),
    TestFamily VARCHAR(50),
    POCTestSID VARCHAR(50),
    StandardTestSID VARCHAR(50),
    TimeWindowMinutes INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE()
)

-- Example mappings
INSERT INTO [LabPOC].[TestMapping] VALUES
('578', 'Glucose', '800000000025', '800000000058', 60, 1, GETDATE()),
('578', 'Creatinine', '800000000042', '800000000043', 240, 1, GETDATE())
```

### PowerBI Configuration Files
```json
// PowerBI.config.json (for automated deployment)
{
  "dataSource": {
    "server": "your-sql-server.database.windows.net",
    "database": "YourLabDatabase",
    "authentication": "Windows"
  },
  "refresh": {
    "schedule": "daily",
    "time": "06:00",
    "timezone": "Eastern Standard Time"
  },
  "performance": {
    "queryTimeout": 1800,
    "maxRowsPerTable": 1000000
  }
}
```

## Performance Optimization

### Query Optimization
```sql
-- Enable query plan caching
ALTER DATABASE [YourDatabase] SET PARAMETERIZATION FORCED

-- Update statistics before large analyses
UPDATE STATISTICS [dbo].[Chem_PatientLabChem] WITH FULLSCAN

-- Monitor query performance
SELECT 
    qs.sql_handle,
    qs.total_elapsed_time/1000 AS total_elapsed_time_ms,
    qs.total_logical_reads,
    qs.execution_count,
    qt.text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE qt.text LIKE '%LabPOC%'
ORDER BY total_elapsed_time_ms DESC
```

### Indexing Strategy
```sql
-- Analyze index usage
SELECT 
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_NAME(s.object_id) = 'Chem_PatientLabChem'

-- Create filtered indexes for specific facilities
CREATE NONCLUSTERED INDEX IX_Chem_PatientLabChem_Facility578
ON [dbo].[Chem_PatientLabChem] (
    [LabChemTestSID],
    [LabChemCompleteDateTime]
) 
WHERE [Sta3n] = '578'
```

### Memory Configuration
```sql
-- Configure SQL Server memory (adjust based on system)
sp_configure 'max server memory (MB)', 6144  -- 6GB for 8GB system
RECONFIGURE WITH OVERRIDE

-- Enable lock pages in memory (Windows only)
sp_configure 'lock pages in memory', 1
RECONFIGURE WITH OVERRIDE
```

### Parallel Processing
```sql
-- Configure parallelism for large datasets
sp_configure 'max degree of parallelism', 4  -- Adjust based on CPU cores
sp_configure 'cost threshold for parallelism', 25
RECONFIGURE WITH OVERRIDE

-- Use query hints for specific queries
SELECT /* OPTION (MAXDOP 4) */ 
    poc.PatientSID,
    -- rest of query
FROM Chem_PatientLabChem poc
-- rest of query
OPTION (MAXDOP 4, RECOMPILE)
```

## Security Implementation

### Access Control
```sql
-- Create role-based security
CREATE ROLE [LabPOC_ReadOnly]
CREATE ROLE [LabPOC_Analyst] 
CREATE ROLE [LabPOC_Admin]

-- Grant permissions by role
GRANT SELECT ON [dbo].[Chem_PatientLabChem] TO [LabPOC_ReadOnly]
GRANT SELECT, INSERT, UPDATE, DELETE ON [LabPOC].[Configuration] TO [LabPOC_Admin]
GRANT EXECUTE ON [App].[LabTest_POC_Compare] TO [LabPOC_Analyst]

-- Add users to roles
ALTER ROLE [LabPOC_Analyst] ADD MEMBER [DOMAIN\LabAnalyst]
ALTER ROLE [LabPOC_ReadOnly] ADD MEMBER [DOMAIN\LabTech]
```

### Data Encryption
```sql
-- Enable Transparent Data Encryption (TDE)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword123!'

CREATE CERTIFICATE TDECert WITH SUBJECT = 'LabPOC TDE Certificate'

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECert

ALTER DATABASE [LabPOCAnalysis] SET ENCRYPTION ON
```

### Audit Configuration
```sql
-- Create audit for data access
CREATE SERVER AUDIT [LabPOC_Audit]
TO FILE (FILEPATH = 'C:\Audit\LabPOC_Audit.sqlaudit')

-- Create database audit specification
CREATE DATABASE AUDIT SPECIFICATION [LabPOC_Database_Audit]
FOR SERVER AUDIT [LabPOC_Audit]
ADD (SELECT ON [dbo].[Chem_PatientLabChem] BY [public])

-- Enable audit
ALTER SERVER AUDIT [LabPOC_Audit] WITH (STATE = ON)
ALTER DATABASE AUDIT SPECIFICATION [LabPOC_Database_Audit] WITH (STATE = ON)
```

### Connection Security
```sql
-- Force encrypted connections
ALTER LOGIN [LabPOCUser] WITH CHECK_POLICY = ON, CHECK_EXPIRATION = ON

-- Configure SSL/TLS for connections
-- In SQL Server Configuration Manager:
-- 1. Enable "Force Encryption"
-- 2. Install valid SSL certificate
-- 3. Restart SQL Server service
```

## Monitoring and Maintenance

### Performance Monitoring
```sql
-- Create performance monitoring views
CREATE VIEW [LabPOC].[vw_PerformanceMetrics] AS
SELECT 
    DATEPART(hour, LabChemCompleteDateTime) AS HourOfDay,
    COUNT(*) AS TestCount,
    AVG(DATEDIFF(minute, LabChemSpecimenDateTime, LabChemCompleteDateTime)) AS AvgTATMinutes
FROM [dbo].[Chem_PatientLabChem] 
WHERE LabChemCompleteDateTime >= DATEADD(day, -7, GETDATE())
GROUP BY DATEPART(hour, LabChemCompleteDateTime)

-- Monitor query execution
SELECT 
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(object_id) AS ObjectName,
    cached_time,
    last_execution_time,
    execution_count,
    total_elapsed_time/execution_count AS avg_elapsed_time_ms
FROM sys.dm_exec_procedure_stats 
WHERE OBJECT_NAME(object_id) LIKE '%LabPOC%'
```

### Automated Maintenance
```sql
-- Create maintenance jobs
USE [msdb]
GO

-- Index maintenance job
EXEC dbo.sp_add_job
    @job_name = N'LabPOC Index Maintenance',
    @enabled = 1,
    @description = N'Reorganize and rebuild indexes for LabPOC tables'

EXEC dbo.sp_add_jobstep
    @job_name = N'LabPOC Index Maintenance',
    @step_name = N'Reorganize Indexes',
    @command = N'
    ALTER INDEX ALL ON [dbo].[Chem_PatientLabChem] REORGANIZE
    UPDATE STATISTICS [dbo].[Chem_PatientLabChem] WITH SAMPLE 25 PERCENT'

-- Schedule daily at 2 AM
EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily 2AM',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 20000

EXEC dbo.sp_attach_schedule
    @job_name = N'LabPOC Index Maintenance',
    @schedule_name = N'Daily 2AM'
```

### Health Checks
```sql
-- Create health check procedure
CREATE PROCEDURE [LabPOC].[sp_HealthCheck]
AS
BEGIN
    -- Check data freshness
    SELECT 
        'Data Freshness' AS CheckType,
        CASE 
            WHEN MAX(LabChemCompleteDateTime) >= DATEADD(hour, -2, GETDATE()) 
            THEN 'PASS' 
            ELSE 'FAIL' 
        END AS Status,
        MAX(LabChemCompleteDateTime) AS LastTestTime
    FROM [dbo].[Chem_PatientLabChem]
    
    UNION ALL
    
    -- Check index fragmentation
    SELECT 
        'Index Health' AS CheckType,
        CASE 
            WHEN AVG(avg_fragmentation_in_percent) < 30 
            THEN 'PASS' 
            ELSE 'FAIL' 
        END AS Status,
        CAST(AVG(avg_fragmentation_in_percent) AS VARCHAR(10)) + '%' AS Details
    FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Chem_PatientLabChem'), NULL, NULL, 'SAMPLED')
    WHERE index_id > 0
END
```

### Alerting Configuration
```sql
-- Create alert for long-running queries
EXEC msdb.dbo.sp_add_alert
    @name = N'LabPOC Long Running Query',
    @message_id = 0,
    @severity = 0,
    @performance_condition = N'SQLServer:SQL Statistics|Batch Requests/sec||>|100'

-- Create alert for blocking
EXEC msdb.dbo.sp_add_alert
    @name = N'LabPOC Blocking Alert',
    @message_id = 0,
    @severity = 0,
    @performance_condition = N'SQLServer:General Statistics|Processes blocked||>|5'
```

## Integration Patterns

### ETL Integration
```sql
-- Sample SSIS package configuration for automated data loads
-- Create staging tables for external data integration
CREATE TABLE [LabPOC].[Staging_ExternalResults] (
    ExternalTestID VARCHAR(50),
    PatientIdentifier VARCHAR(50),
    TestDateTime DATETIME2,
    TestResult DECIMAL(10,3),
    TestUnits VARCHAR(20),
    LoadDateTime DATETIME2 DEFAULT GETDATE()
)

-- Merge procedure for data integration
CREATE PROCEDURE [LabPOC].[sp_MergeExternalData]
AS
BEGIN
    MERGE [LabPOC].[ExternalResults] AS target
    USING [LabPOC].[Staging_ExternalResults] AS source
    ON target.ExternalTestID = source.ExternalTestID
    WHEN MATCHED THEN 
        UPDATE SET 
            TestResult = source.TestResult,
            ModifiedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (ExternalTestID, PatientIdentifier, TestDateTime, TestResult, TestUnits)
        VALUES (source.ExternalTestID, source.PatientIdentifier, source.TestDateTime, source.TestResult, source.TestUnits)
END
```

### API Integration
```csharp
// Sample C# code for API integration
public class LabPOCService
{
    private readonly string _connectionString;
    
    public async Task<List<ComparisonResult>> GetComparisonResults(
        string facilityNumber, 
        DateTime startDate, 
        DateTime endDate)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("[App].[LabTest_POC_Compare]", connection);
        command.CommandType = CommandType.StoredProcedure;
        
        // Execute and return results
    }
}
```

### PowerBI Service Integration
```powershell
# PowerShell script for automated PowerBI refresh
$workspaceId = "your-workspace-id"
$datasetId = "your-dataset-id"

# Authenticate to PowerBI Service
Connect-PowerBIServiceAccount

# Trigger dataset refresh
Invoke-PowerBIRestMethod -Url "datasets/$datasetId/refreshes" -Method POST -Body "{}"

# Monitor refresh status
$refreshes = Invoke-PowerBIRestMethod -Url "datasets/$datasetId/refreshes" -Method GET | ConvertFrom-Json
$latestRefresh = $refreshes.value[0]
Write-Host "Refresh Status: $($latestRefresh.status)"
```

## Troubleshooting

### Common Issues and Solutions

#### Performance Issues
**Problem:** Query execution takes too long
```sql
-- Diagnosis queries
SELECT 
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK')
ORDER BY wait_time_ms DESC

-- Solutions
-- 1. Update statistics
UPDATE STATISTICS [dbo].[Chem_PatientLabChem] WITH FULLSCAN

-- 2. Rebuild indexes
ALTER INDEX ALL ON [dbo].[Chem_PatientLabChem] REBUILD

-- 3. Add query hints
-- Use OPTION (RECOMPILE) for parameter sniffing issues
```

#### Connection Issues
**Problem:** Cannot connect to database
```powershell
# Diagnosis steps
# 1. Test basic connectivity
Test-NetConnection -ComputerName "sql-server.domain.com" -Port 1433

# 2. Check SQL Server configuration
sqlcmd -S "sql-server.domain.com" -Q "SELECT @@SERVERNAME"

# 3. Verify authentication
sqlcmd -S "sql-server.domain.com" -E -Q "SELECT SYSTEM_USER"

# Solutions
# 1. Enable TCP/IP protocol
# 2. Configure Windows Firewall
# 3. Check SQL Server Browser service
# 4. Verify login permissions
```

#### Memory Issues
**Problem:** Out of memory errors
```sql
-- Diagnosis
SELECT 
    counter_name,
    cntr_value 
FROM sys.dm_os_performance_counters 
WHERE object_name = 'SQLServer:Memory Manager'

-- Solutions
-- 1. Increase max server memory
sp_configure 'max server memory (MB)', 8192
RECONFIGURE WITH OVERRIDE

-- 2. Enable lock pages in memory
-- 3. Reduce query complexity
-- 4. Implement data archiving
```

#### Data Quality Issues
**Problem:** Unexpected or missing results
```sql
-- Diagnosis queries
-- Check data availability
SELECT 
    LabChemTestSID,
    COUNT(*) AS RecordCount,
    MIN(LabChemCompleteDateTime) AS EarliestDate,
    MAX(LabChemCompleteDateTime) AS LatestDate
FROM [dbo].[Chem_PatientLabChem]
WHERE Sta3n = 'YOUR_STATION'
    AND LabChemCompleteDateTime >= DATEADD(day, -30, GETDATE())
GROUP BY LabChemTestSID
ORDER BY RecordCount DESC

-- Check for data gaps
SELECT 
    CAST(LabChemCompleteDateTime AS DATE) AS TestDate,
    COUNT(*) AS TestCount
FROM [dbo].[Chem_PatientLabChem]
WHERE Sta3n = 'YOUR_STATION'
    AND LabChemCompleteDateTime >= DATEADD(day, -30, GETDATE())
GROUP BY CAST(LabChemCompleteDateTime AS DATE)
ORDER BY TestDate
```

### Error Codes and Messages
**Common Error Codes:**
- **2:** Cannot open database - Check connection and permissions
- **208:** Invalid object name - Verify table names and schema
- **229:** Permission denied - Check user permissions
- **1222:** Lock request timeout - Reduce query complexity or increase timeout

### Support Escalation
**Level 1 Support (IT Help Desk):**
- Basic connectivity issues
- User account problems
- PowerBI desktop issues

**Level 2 Support (Database Administrators):**
- Performance optimization
- Index maintenance
- Security configuration

**Level 3 Support (Vendor/Developer):**
- Complex query issues
- Integration problems
- Custom development needs

---

## Deployment Checklist

### Pre-Deployment
- [ ] Server requirements verified
- [ ] Database permissions configured
- [ ] Backup strategy implemented
- [ ] Security policies reviewed
- [ ] Testing completed in non-production

### Deployment
- [ ] SQL objects deployed successfully
- [ ] PowerBI reports configured
- [ ] User accounts created
- [ ] Documentation updated
- [ ] Training materials prepared

### Post-Deployment
- [ ] Performance monitoring enabled
- [ ] Health checks scheduled
- [ ] User training completed
- [ ] Support procedures documented
- [ ] Success metrics defined

---

**For additional technical support, please refer to the project documentation or create a GitHub issue with detailed technical information.**
