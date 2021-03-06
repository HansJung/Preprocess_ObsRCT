-- --------------------------------------------------------
-- Title: Find the glasgow coma *MOTOR* score for each adult patient
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------
DROP TABLE IF EXISTS gcs_tbl;
CREATE TABLE gcs_tbl AS
WITH agetbl AS
(
    SELECT ad.subject_id
    FROM mimiciii.admissions ad
    INNER JOIN mimiciii.patients p
    ON ad.subject_id = p.subject_id
    WHERE
     -- filter to only adults
    EXTRACT(EPOCH FROM (ad.admittime - p.dob))/60.0/60.0/24.0/365.242 > 15
    -- group by subject_id to ensure there is only 1 subject_id per row
    group by ad.subject_id
)
, gcs as
(
    SELECT width_bucket(valuenum, 1, 30, 30) AS bucket
    FROM mimiciii.chartevents ce
    INNER JOIN agetbl
    ON ce.subject_id = agetbl.subject_id
    WHERE itemid IN
    (
        454 -- "Motor Response"
      , 223900 -- "GCS - Motor Response"
    )
)
SELECT bucket as GCS_Motor_Response, count(*)
FROM gcs
GROUP BY bucket
ORDER BY bucket;