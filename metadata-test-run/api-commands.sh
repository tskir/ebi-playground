# Functions & commands to extract the information from API

extract_accessions () { jq -r '.accessionVersionId | .accession'; }
export -f extract_accessions

# Count the total number of imported studies
IMPORTED_STUDY_COUNT=`curl -s http://localhost:8080/studies | jq -r '.page | .totalElements'`

# Fetch all browsable studies
ORIGINAL_STUDY_COUNT=`wc -l < input-studies.txt`
parallel -j 16 -k \
curl -s http://localhost:8080/studies/{} '|' extract_accessions \
::: $(seq 0 $(( ORIGINAL_STUDY_COUNT - 1 ))) \
| grep -v null | sort > studies-result.txt

# Generate the list of studies which failed to import
grep -v -f studies-result.txt input-studies.txt | sort > missing-studies.txt

# Count the total number of analyses
IMPORTED_ANALYSIS_COUNT=`curl -s http://localhost:8080/analyses | jq -r '.page | .totalElements'`

# Obsolete - Functions & commands to extract the information from API

extract_analysis_accession () { jq -r '.accessionVersionId | .accession'; }
extract_samples_accessions () { jq -r '._embedded | .samples | .[] | .accessionVersionId | .accession'; }
extract_sample_taxonomylink () { jq -r '._embedded | .samples | .[] | ._links | .taxonomies | .href'; }
extract_taxonomy_id () { jq -r '._embedded | .taxonomies | .[] | .taxonomyId'; }
extract_refseq_accessions() {  jq -r '._embedded | ."reference-sequences" | .[] | .accessions | .[]'; }

analysis_sample_taxonomy_table () {
  for ANALYSIS in {1..10}; do
    export ANALYSIS
    ANALYSIS_ID=$(
      curl -s http://localhost:8080/analyses/$ANALYSIS \
      | extract_analysis_accession)
    ANALYSIS_SAMPLE_ACCESSIONS=$(
      curl -s http://localhost:8080/analyses/$ANALYSIS/samples \
      | extract_samples_accessions)
    export ANALYSIS_SAMPLES_TAXONOMY_LINKS=$(
      curl -s http://localhost:8080/analyses/$ANALYSIS/samples \
      | extract_sample_taxonomylink)
    ANALYSIS_SAMPLE_TAXONOMIES=$(parallel curl -s {} '|' extract_taxonomy_id ::: $ANALYSIS_SAMPLES_TAXONOMY_LINKS)
    parallel --link echo ::: $ANALYSIS_ID ::: $ANALYSIS_SAMPLE_ACCESSIONS ::: $ANALYSIS_SAMPLE_TAXONOMIES
  done
}

export -f extract_analysis_accession extract_samples_accessions extract_sample_taxonomylink extract_taxonomy_id extract_taxonomy_id extract_refseq_accessions

# Fetch the list of all analyses
curl -q http://localhost:8080/analyses \
  | jq -r '._embedded | .analyses | .[] | .accessionVersionId | .accession' | sort > analysis-result.txt

# Fetch the list of all studies
curl -q http://localhost:8080/studies \
  | jq -r '._embedded | .studies | .[] | .accessionVersionId | .accession' | sort > studies-result.txt

# Create the ANALYSIS-REFSEQ table
paste -d, \
  <(curl -q http://localhost:8080/analyses | jq -r '._embedded | .analyses | .[] | .accessionVersionId | .accession') \
  <(parallel -k curl -s http://localhost:8080/analyses/{}/referenceSequences  '|' extract_refseq_accessions ::: {1..10}) \
| sort -t, -k1,1 > reference-sequences-result.txt

# Create the ANALYSIS-SAMPLE-TAXONOMY table
analysis_sample_taxonomy_table | sort -k1,2 | tr ' ' ',' > analysis-sample-taxonomy-result.txt
