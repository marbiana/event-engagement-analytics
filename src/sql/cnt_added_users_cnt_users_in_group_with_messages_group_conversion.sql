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
),
user_group_messages AS (
    SELECT 
        hg.hk_group_id,
        COUNT(DISTINCT d.message_from) AS cnt_users_in_group_with_messages
    FROM 
        STV2025032026__STAGING.dialogs d
    INNER JOIN 
        STV2025032026__DWH.h_groups hg ON d.message_group = hg.group_id
    INNER JOIN (
        SELECT 
            hk_group_id
        FROM 
            STV2025032026__DWH.h_groups
        ORDER BY 
            registration_dt
        LIMIT 10
    ) top_groups ON hg.hk_group_id = top_groups.hk_group_id
    WHERE 
        d.message_group IS NOT NULL
    GROUP BY 
        hg.hk_group_id
)

SELECT 
    ugl.hk_group_id,
    ugl.cnt_added_users,
    COALESCE(ugm.cnt_users_in_group_with_messages, 0) AS cnt_users_in_group_with_messages,
    ROUND(COALESCE(ugm.cnt_users_in_group_with_messages, 0) * 1.0 / ugl.cnt_added_users, 2) AS group_conversion
FROM 
    user_group_log ugl
LEFT JOIN 
    user_group_messages ugm ON ugl.hk_group_id = ugm.hk_group_id
ORDER BY 
    group_conversion DESC;