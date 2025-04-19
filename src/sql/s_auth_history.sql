DROP TABLE IF EXISTS STV2025032026__DWH.s_auth_history;

CREATE TABLE STV2025032026__DWH.s_auth_history (
    hk_l_user_group_activity BIGINT NOT NULL CONSTRAINT fk_s_auth_history_link 
        REFERENCES STV2025032026__DWH.l_user_group_activity(hk_l_user_group_activity),
    user_id_from INT,
    event VARCHAR(10) NOT NULL,
    event_dt TIMESTAMP NOT NULL,
    load_dt DATETIME,
    load_src VARCHAR(20))
ORDER BY event_dt
SEGMENTED BY hk_l_user_group_activity ALL NODES
PARTITION BY (
    YEAR(event_dt)::VARCHAR || '-' || MONTH(event_dt)::VARCHAR  -- Партицирование по году и месяцу (YYYY-MM)
);

INSERT INTO STV2025032026__DWH.s_auth_history (
    hk_l_user_group_activity, 
    user_id_from, 
    event, 
    event_dt, 
    load_dt, 
    load_src
)
SELECT 
    luga.hk_l_user_group_activity,
    gl.user_id_from::INT,
    gl.event,
    gl.datetime,
    NOW() AS load_dt,
    's3' AS load_src
FROM STV2025032026__STAGING.group_log AS gl
INNER JOIN STV2025032026__DWH.h_groups hg ON gl.group_id = hg.group_id
INNER JOIN STV2025032026__DWH.h_users hu ON gl.user_id = hu.user_id
INNER JOIN STV2025032026__DWH.l_user_group_activity luga 
    ON hg.hk_group_id = luga.hk_group_id 
    AND hu.hk_user_id = luga.hk_user_id;


