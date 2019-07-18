-- Count all studies
SELECT COUNT(*)
FROM evapro.study_browser

-- Fetch importable studies
SELECT DISTINCT p.secondary_study_id
FROM evapro.project p
INNER JOIN evapro.study_browser s
  ON p.project_accession = s.project_accession
WHERE
  s.assembly_accession LIKE 'GCA%'
  AND p.secondary_study_id IS NOT NULL
  AND p.secondary_study_id NOT IN (
    'ERP005503', 'ERP005504',  /* Issue 1.1 */
    'ERP013417', 'ERP023006',  /* Issue 1.2 */
    'ERP113859',               /* Issue 1.4 */
    'ERP115912',               /* Issue 1.6 */
    'ERP115823'                /* Issue 1.7 */
  )
ORDER BY p.secondary_study_id

-- Count analyses of importable studies
SELECT COUNT(DISTINCT p_a.analysis_accession)
FROM evapro.project p
INNER JOIN evapro.study_browser s
  ON p.project_accession = s.project_accession
INNER JOIN evapro.project_analysis p_a
  ON p.project_accession = p_a.project_accession
WHERE
  s.assembly_accession LIKE 'GCA%'
  AND p.secondary_study_id IS NOT NULL
  AND p.secondary_study_id NOT IN (
    'ERP005503', 'ERP005504',  /* Issue 1.1 */
    'ERP013417', 'ERP023006',  /* Issue 1.2 */
    'ERP113859',               /* Issue 1.4 */
    'ERP115912',               /* Issue 1.6 */
    'ERP115823'                /* Issue 1.7 */
  )
