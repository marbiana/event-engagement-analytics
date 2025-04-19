INSERT INTO STV2025032026__DWH.l_user_group_activity (
    hk_l_user_group_activity, 
    hk_user_id, 
    hk_group_id, 
    load_dt, 
    load_src
)
SELECT DISTINCT
    HASH(hu.hk_user_id, hg.hk_group_id) AS hk_l_user_group_activity,
    hu.hk_user_id,
    hg.hk_group_id,
    NOW() AS load_dt,
    's3' AS load_src
FROM STV2025032026__STAGING.group_log AS gl
INNER JOIN STV2025032026__DWH.h_users hu ON gl.user_id = hu.user_id
INNER JOIN STV2025032026__DWH.h_groups hg ON gl.group_id = hg.group_id;


-- проверка
-- проверка количества записей
SELECT COUNT(*) FROM STV2025032026__DWH.l_user_group_activity;

-- поиск дубликатов в первичном ключе
SELECT hk_l_user_group_activity, COUNT(*)
FROM STV2025032026__DWH.l_user_group_activity
GROUP BY hk_l_user_group_activity
HAVING COUNT(*) > 1;

-- проверка NULL в ключах
SELECT * 
FROM STV2025032026__DWH.l_user_group_activity 
WHERE hk_user_id IS NULL OR hk_group_id IS NULL;