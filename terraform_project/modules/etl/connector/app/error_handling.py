import os
from google.cloud import bigquery

def log_failed_requests(client, start_date, end_date, station_id):
    table_id = os.getenv('FAILED_REQUESTS_TABLE_ID')
    if not table_id:
        raise Exception("FAILED_REQUESTS_TABLE_ID not set in environment variables")

    print(f"Logging failed request to table {table_id}")

    row = {
        "FechaInicio": start_date,
        "FechaFin": end_date,
        "Estacion": station_id
    }
    errors = client.insert_rows_json(table_id, [row])
    if errors:
        print(f"Failed to log failed request: {errors}")
    else:
        print(f"Failed request logged successfully: {row}")

def delete_failed_request(client, start_date, end_date, station_id):
    table_id = os.getenv('FAILED_REQUESTS_TABLE_ID')
    if not table_id:
        raise Exception("FAILED_REQUESTS_TABLE_ID not set in environment variables")

    query = f"""
    DELETE FROM `{table_id}`
    WHERE 
      TIMESTAMP(FechaInicio) = TIMESTAMP('{start_date}') AND 
      TIMESTAMP(FechaFin) = TIMESTAMP('{end_date}') AND 
      Estacion = '{station_id}'
    """
    query_job = client.query(query)
    query_job.result()

    print(f"Failed request deleted from table {table_id} for {start_date} to {end_date} at station {station_id}")

def retry_failed_requests(client, api_key, fetch_aemet_data, fetch_data_from_url, format_data, load_data_to_bigquery):
    table_id = os.getenv('FAILED_REQUESTS_TABLE_ID')
    if not table_id:
        raise Exception("FAILED_REQUESTS_TABLE_ID not set in environment variables")

    print(f"Retrying failed requests from table {table_id}")

    query = f"SELECT * FROM `{table_id}`"
    query_job = client.query(query)
    results = query_job.result()
    for row in results:
        try:
            data_url = fetch_aemet_data(api_key, row.FechaInicio, row.FechaFin, row.Estacion)
            if data_url:
                data = fetch_data_from_url(data_url)
                formatted_data = format_data(data)
                load_data_to_bigquery(formatted_data)
                delete_failed_request(client, row.FechaInicio, row.FechaFin, row.Estacion)
            else:
                print(f"Failed to fetch data from AEMET API for dates {row.FechaInicio} to {row.FechaFin} at station {row.Estacion}")
        except Exception as e:
            print(f"Exception during retry of failed request for dates {row.FechaInicio} to {row.FechaFin} at station {row.Estacion}: {e}")

