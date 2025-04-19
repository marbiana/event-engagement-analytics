DROP TABLE IF EXISTS STV2025032026__DWH.l_user_group_activity;

CREATE TABLE STV2025032026__DWH.l_user_group_activity (
    hk_l_user_group_activity BIGINT PRIMARY KEY,
    hk_user_id BIGINT NOT NULL CONSTRAINT fk_l_user_group_activity_user 
        REFERENCES STV2025032026__DWH.h_users(hk_user_id),
    hk_group_id BIGINT NOT NULL CONSTRAINT fk_l_user_group_activity_group 
        REFERENCES STV2025032026__DWH.h_groups(hk_group_id),
    load_dt DATETIME,
    load_src VARCHAR(20))
ORDER BY load_dt
SEGMENTED BY hk_l_user_group_activity ALL NODES
PARTITION BY load_dt::DATE
GROUP BY CALENDAR_HIERARCHY_DAY(load_dt::DATE, 3, 2);  

COMMENT ON TABLE STV2025032026__DWH.l_user_group_activity IS 'Связь пользователей и групп по активности';
COMMENT ON COLUMN STV2025032026__DWH.l_user_group_activity.hk_l_user_group_activity IS 'Суррогатный ключ связи';
COMMENT ON COLUMN STV2025032026__DWH.l_user_group_activity.hk_user_id IS 'Ссылка на пользователя (hub h_users)';
COMMENT ON COLUMN STV2025032026__DWH.l_user_group_activity.hk_group_id IS 'Ссылка на группу (hub h_groups)';