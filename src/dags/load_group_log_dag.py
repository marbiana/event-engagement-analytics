from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.vertica.hooks.vertica import VerticaHook
from airflow.decorators import dag
import pendulum
import os
import pandas as pd

VERTICA_CONN_ID = 'vertica_conn'
DATA_DIR = '/data'

def preprocess_group_log(file_path: str):
    """Обработка NULL в user_id_from и сохранение в новый CSV"""
    df = pd.read_csv(file_path, parse_dates=['datetime'])
    df['user_id_from'] = pd.array(df['user_id_from'], dtype="Int64")
    processed_path = os.path.join(DATA_DIR, 'processed_group_log.csv')
    df.to_csv(processed_path, index=False)
    return processed_path

def load_to_vertica(table_name: str, file_name: str, columns: list):
    hook = VerticaHook(vertica_conn_id=VERTICA_CONN_ID)
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    try:
        cursor.execute(f"""
            COPY {table_name} ({','.join(columns)})
            FROM LOCAL '{os.path.join(DATA_DIR, file_name)}'
            DELIMITER ','
            SKIP 1
            ENCLOSED BY '"'
            NULL ''     
            REJECTED DATA AS TABLE {table_name}_rejected;
        """)
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()

@dag(
    schedule_interval=None,
    start_date=pendulum.parse('2023-01-01'),
    catchup=False
)
def load_group_log_dag():
    
    preprocess_task = PythonOperator(
        task_id='preprocess_group_log',
        python_callable=preprocess_group_log,
        op_kwargs={'file_path': os.path.join(DATA_DIR, 'group_log.csv')}
    )
    
    load_group_log = PythonOperator(
        task_id='load_group_log',
        python_callable=load_to_vertica,
        op_kwargs={
            'table_name': 'STV2025032026__STAGING.group_log',
            'file_name': 'processed_group_log.csv',
            'columns': ['group_id', 'user_id', 'user_id_from', 'event', 'datetime']
        }
    )

    preprocess_task >> load_group_log

load_group_log_workflow = load_group_log_dag()