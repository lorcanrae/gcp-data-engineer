-- 01. How large are the tables in a given dataset?
SELECT
  dataset_id,
  table_id,
  -- Convert bytes to GB
  ROUND(size_bytes/pow(10,9), 2) as size_gb,
  -- Convert unix epoch to timestamp
  TIMESTAMP_MILLIS(creation_time) as creation_time,
  TIMESTAMP_MILLIS(last_modified_time) as last_modified_time,
  row_count,
  CASE
    WHEN type = 1 THEN 'table'
    WHEN type = 2 THEN 'view'
  ELSE NULL
  END AS type
FROM
  -- Replace with whatever dataset you want
  `bigquery-public-data.new_york.__TABLES__`
ORDER BY
  size_gb DESC;

-- 02. How many columns of data are present?
SELECT * FROM
  -- Replace baseball with a different dataset:
 `bigquery-public-data.baseball.INFORMATION_SCHEMA.COLUMNS`;

-- 03. Are any columns partitioned or clustered
SELECT * FROM
  -- Replace baseball with a different dataset:
 `bigquery-public-data.baseball.INFORMATION_SCHEMA.COLUMNS`
WHERE
  is_partitioning_column = 'YES' OR clustering_ordinal_position IS NOT NULL;

-- 04. Querying metadata across datastes
-- Question: If you wanted to query across multiple datasets, how could you do it?
-- https://stackoverflow.com/questions/43457651/bigquery-select-tables-from-all-tables-within-project
-- Answer: With a UNION or a python script to iterate through each dataset in `bq ls`
WITH ALL__TABLES__ AS (
  SELECT * FROM `bigquery-public-data.baseball.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.bls.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.census_bureau_usa.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.cloud_storage_geo_index.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.cms_codes.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.fec.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.genomics_cannabis.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.ghcn_d.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.ghcn_m.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.github_repos.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.hacker_news.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.irs_990.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.medicare.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.new_york.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.nlm_rxnorm.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.noaa_gsod.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.open_images.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.samples.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.san_francisco.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.stackoverflow.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.usa_names.__TABLES__` UNION ALL
  SELECT * FROM `bigquery-public-data.utility_us.__TABLES__`
)
SELECT *
FROM ALL__TABLES__
ORDER BY row_count DESC -- Top 10 tables with the most rows
LIMIT 10;

-- 05. View all datasets in a GCP Project
SELECT
 s.*,
 TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), creation_time, DAY) AS days_live,
 option_value AS dataset_description
FROM
 `<your-project-name>.INFORMATION_SCHEMA.SCHEMATA` AS s
 LEFT JOIN `<your-project-name>.INFORMATION_SCHEMA.SCHEMATA_OPTIONS` AS so
 USING (schema_name)
WHERE so.option_name = 'description'
ORDER BY last_modified_time DESC
LIMIT 15;
