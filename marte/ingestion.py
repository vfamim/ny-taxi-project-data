import pandas as pd


def fetch_data(color: str, year: int, month: int) -> pd.DataFrame:
    """Read data from web into pandas DataFrame"""
    dataset_url = (
        'https://d37ci6vzurychx.cloudfront.net/trip-data/'
        f'{color}_tripdata_{year}-{month:02}.parquet'
    )
    df = pd.read_parquet(dataset_url)
    df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
    df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
    return df


if __name__ == '__main__':
    color = 'yellow'
    year = 2023
    month = 1
    df = fetch_data(color, year, month)
