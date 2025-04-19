WITH user_group_messages AS (
    SELECT 
        hg.hk_group_id,
        COUNT(DISTINCT d.message_from) AS cnt_users_in_group_with_messages
    FROM 
        STV2025032026__STAGING.dialogs d
    INNER JOIN 
        STV2025032026__DWH.h_groups hg ON d.message_group = hg.group_id
    WHERE 
        d.message_group IS NOT NULL  
    GROUP BY 
        hg.hk_group_id
)
SELECT 
    hk_group_id,
    cnt_users_in_group_with_messages
FROM 
    user_group_messages
ORDER BY 
    cnt_users_in_group_with_messages  
LIMIT 10;