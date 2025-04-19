DROP TABLE IF EXISTS STV2025032026__STAGING.group_log;

CREATE TABLE STV2025032026__STAGING.group_log (
    group_id INT,
    user_id INT,
    user_id_from INT,
    event VARCHAR(10) NOT NULL,
    datetime TIMESTAMP NOT NULL
)
ORDER BY datetime
SEGMENTED BY HASH(group_id, user_id) ALL NODES
PARTITION BY (
    YEAR(datetime)::VARCHAR || '-' || 
    MONTH(datetime)::VARCHAR 
);