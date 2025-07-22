SELECT TOP (1000) [LabChemTestSID]
      ,[LabChemTestIEN]
      ,[Sta3n]
      ,[LabChemTestName] AS [LabChemTestName_VISTA]
      ,[LabChemPrintTestName]
      ,[NLTNationalVALabCodeSID]
      ,[NationalVALabCodeSID]
      ,[LabChemTestLocation]
      ,[LabTestType]
      ,[RequiredTestFlag]
      ,[TestCost]
      ,[SNOMEDProcedureSID]
      ,[HighestLabChemTestUrgencySID]
      ,[ForcedLabChemTestUrgencySID]
      ,[DefaultSpecimenSiteCPTSID]
      ,[HCSPCSCPTSID]
      ,[CollectionSampleSID]
      ,[BillableFlag]
      ,[UniqueCollectionSampleFlag]
      ,[UniqueAccessionNumberFlag]
      ,*
  FROM [CDWWork].[Dim].[LabChemTest]
  WHERE [Sta3n] LIKE '578' 
  	AND ([LabChemTestSID] = 1000122927 --POC_URINALYSIS
			OR [LabChemTestSID] = 1000153039 --TEMP_UA_W/_MICROSCOPIC-iQ
			OR [LabChemTestSID] = 1000114340 --ISTAT CREATININE
			OR [LabChemTestSID] = 1000062823 --CREATININE
			OR [LabChemTestSID] = 1000114341 --ISTAT HEMATOCRIT
			OR [LabChemTestSID] = 1000048470 --HEMATOCRIT
			OR [LabChemTestSID] = 1000114342 --ISTAT HEMOGLOBIN
			OR [LabChemTestSID] = 1000036429 --HEMOGLOBIN
			OR [LabChemTestSID] = 1000113247 --TROPONIN ISTAT
			OR [LabChemTestSID] = 1600022143 --HIGH SENSITIVITY TROPONIN I
 			OR [LabChemTestSID] = 1000068127 --POC GLUCOSE
 			OR [LabChemTestSID] = 1000027461 --GLUCOSE
			)
	--AND ([LabChemTestName] LIKE '%TROPONIN%')
	--		--OR [LabChemTestName] LIKE '%top%')
  ORDER BY [LabChemTestName_VISTA]