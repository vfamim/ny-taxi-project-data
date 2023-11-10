import pandas as pd
from prefect import flow, task
from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket

# TODO: Salvar os arquivos parquet com o nome do mês e ano
# TODO: Transformar o arquivo em dimensão -> fato
# TODO: Configurar arquivo dockers
# TODO: Criar restrição para arquivos faltantes (checar se o mês existe)


@task()
def file_to_extract(color: str, year: int, month: int) -> str:
    """String with file name to upload in GCS"""
    file_name = f'{color}_tripdata_{year}-{month:02}'
    return file_name


@task(retries=3)
def fetch_data(file_name: str) -> pd.DataFrame:
    """Read data from web into pandas DataFrame"""
    dataset_url = (
        'https://d37ci6vzurychx.cloudfront.net/trip-data/'
        f'{file_name}.parquet'
    )
    df = pd.read_parquet(dataset_url)
    return df


@task()
def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    """Transform data"""
    passenger_count = df['passenger_count'].isin([0]).sum()
    print(f'pre: missing passenger count: {passenger_count}')
    df = df[df['passenger_count'] != 0]
    print(f'pos: missing passenger count: {passenger_count}')
    df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
    df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
    return df


@task()
def upload_to_gcs(dataframe: pd.DataFrame, file_name: str) -> None:
    """Upload Dataframe parquet file to Google Cloud Storage"""
    gcs_block = GcsBucket.load('project-marte-gcs-bucket')
    gcs_block.upload_from_dataframe(
        dataframe,
        f'raw/{file_name}',
        'parquet',
    )


@task()
def write_BQ(dataframe: pd.DataFrame) -> None:
    """Write Dataframe to Big Query"""
    gcp_cred_block = GcpCredentials.load('project-marte-gcp-credentials')
    dataframe.to_gbq(
        destination_table='marte.rides',
        project_id='ny-trip-data',
        credentials=gcp_cred_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists='append',
    )


@flow()
def etl_parent_flow(color: str = 'yellow', year: int = 1, months: int = 1):
    """Main ETL flow to load data into GCS and Big Query"""
    file_name = file_to_extract(color, year, months)
    raw_df = fetch_data(file_name)
    df = transform_data(raw_df)
    upload_to_gcs(df, file_name)
    write_BQ(df)


if __name__ == '__main__':
    color = 'yellow'
    year = 2023
    month = 1
    etl_parent_flow(color, year, month)
