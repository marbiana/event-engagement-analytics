from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.decorators import dag
import pendulum
import boto3
import os

AWS_ACCESS_KEY_ID = "YCAJEiyNFq4wiOe_eMCMCXmQP"
AWS_SECRET_ACCESS_KEY = "YCP1e96y4QI8OmcB4Eaf4q0nMHwhmtvGbDTgBeqS"
BUCKET_NAME = "sprint6"
DATA_DIR = '/data'
FILE_TO_DOWNLOAD = 'group_log.csv'  

def fetch_s3_file_group_log(bucket: str, key: str):
    session = boto3.session.Session()
    s3_client = session.client(
        service_name='s3',
        endpoint_url='https://storage.yandexcloud.net',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )
    
    os.makedirs(DATA_DIR, exist_ok=True)
    s3_client.download_file(
        Bucket=bucket,
        Key=key,
        Filename=os.path.join(DATA_DIR, key)
    )

bash_command_tmpl = """
echo "===== {{ params.file }} ====="
head {{ params.file }}
echo "\n"
"""

@dag(schedule_interval=None, start_date=pendulum.parse('2022-07-13'), catchup=False)
def group_log_dag():

    download_group_log = PythonOperator(
        task_id='download_group_log',
        python_callable=fetch_s3_file_group_log,
        op_kwargs={'bucket': BUCKET_NAME, 'key': FILE_TO_DOWNLOAD}
    )
    

    print_10_lines = BashOperator(
        task_id='print_10_lines',
        bash_command=bash_command_tmpl,
        params={'file': os.path.join(DATA_DIR, FILE_TO_DOWNLOAD)}
    )
    

    download_group_log >> print_10_lines

group_log_workflow = group_log_dag()