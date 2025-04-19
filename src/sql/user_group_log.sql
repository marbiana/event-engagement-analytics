WITH user_group_log AS (
    SELECT 
        luga.hk_group_id,
        COUNT(DISTINCT luga.hk_l_user_group_activity) AS cnt_added_users
    FROM 
        STV2025032026__DWH.s_auth_history sah
    INNER JOIN STV2025032026__DWH.l_user_group_activity luga 
        ON sah.hk_l_user_group_activity = luga.hk_l_user_group_activity
    INNER JOIN (
        SELECT 
            hk_group_id
        FROM 
            STV2025032026__DWH.h_groups
        ORDER BY 
            registration_dt
        LIMIT 10
    ) hg ON luga.hk_group_id = hg.hk_group_id
    WHERE 
        sah.event = 'add'
    GROUP BY 
        luga.hk_group_id
)
SELECT 
    hk_group_id,
    cnt_added_users
FROM 
    user_group_log
ORDER BY 
    cnt_added_users
LIMIT 10;

hk_l_user_group_activity