CREATE SCHEMA IF NOT EXISTS transaction_data2;
USE transaction_data2;

WITH LAGDATA AS (
	SELECT
        `Sender Account ID`,
        `Timestamp`,
        
        LAG(`Timestamp`, 1) OVER (
            PARTITION BY `Sender Account ID`
            ORDER BY `Timestamp`
        ) AS previous_timestamp,
        
        `Geolocation (Latitude/Longitude)` AS current_location,

        LAG(`Geolocation (Latitude/Longitude)`, 1) OVER (
			PARTITION BY `Sender Account ID`
            ORDER BY `Timestamp`
        ) AS previous_location,
        `Fraud Flag`

    FROM transaction_data
	)
    
SELECT
    `Sender Account ID`,
    `Timestamp`,
    current_location,
    previous_timestamp,
    previous_location,
    `Fraud Flag`
FROM
    LAGDATA
WHERE
    previous_location IS NOT NULL
    AND previous_timestamp IS NOT NULL AND
    `Fraud Flag` = 'True';