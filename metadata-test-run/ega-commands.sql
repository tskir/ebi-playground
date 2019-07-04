-- Commands for importing data from EGA database

-- Select suitable analyses for the test run (further subsampling required!)
SELECT
  ANALYSIS_ID
FROM
  ANALYSIS
WHERE
  EXTRACTVALUE(ANALYSIS_XML, '/ANALYSIS_SET/ANALYSIS/ANALYSIS_TYPE/*/ASSEMBLY/STANDARD/@accession') IS NOT NULL
  AND ANALYSIS_TYPE IN ('PROCESSED_READS', 'REFERENCE_ALIGNMENT', 'SEQUENCE_VARIATION')

-- Fetch studies for the analyses of interest
SELECT DISTINCT
  EXTRACTVALUE(ANALYSIS_XML, '/ANALYSIS_SET/ANALYSIS/STUDY_REF/@accession')
FROM
  ANALYSIS
WHERE
  ANALYSIS_ID IN ('ERZ015305','ERZ015774','ERZ015903','ERZ016049','ERZ016157','ERZ016252','ERZ016381','ERZ016404','ERZ016497','ERZ017095')

-- ANALYSIS-REFSEQ table
SELECT
  ANALYSIS_ID, EXTRACTVALUE(ANALYSIS_XML, '/ANALYSIS_SET/ANALYSIS/ANALYSIS_TYPE/*/ASSEMBLY/STANDARD/@accession')
FROM
  ANALYSIS
WHERE
  ANALYSIS_ID IN ('ERZ015305','ERZ015774','ERZ015903','ERZ016049','ERZ016157','ERZ016252','ERZ016381','ERZ016404','ERZ016497','ERZ017095')
ORDER BY
  ANALYSIS_ID

-- ANALYSIS-SAMPLE-TAXONOMY table
SELECT
  A_S.ANALYSIS_ID, A_S.SAMPLE_ID, EXTRACTVALUE(S.SAMPLE_XML, '/SAMPLE_SET/SAMPLE/SAMPLE_NAME/TAXON_ID')
FROM
  ANALYSIS_SAMPLE A_S
INNER JOIN
  SAMPLE S ON A_S.SAMPLE_ID = S.SAMPLE_ID
WHERE
  A_S.ANALYSIS_ID IN ('ERZ015305','ERZ015774','ERZ015903','ERZ016049','ERZ016157','ERZ016252','ERZ016381','ERZ016404','ERZ016497','ERZ017095')
ORDER BY
  ANALYSIS_ID, SAMPLE_ID
