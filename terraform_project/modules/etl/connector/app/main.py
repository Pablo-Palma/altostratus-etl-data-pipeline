import os
import requests
import json
from google.cloud import bigquery
from flask import Flask, jsonify, request

app = Flask(__name__)

def fetch_aemet_data(api_key, start_date, end_date, station_id):
    url = f'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/{start_date}/fechafin/{end_date}/estacion/{station_id}'
    headers = {'api_key': api_key}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    json_response = response.json()
    if 'datos' in json_response:
        return json_response['datos']
    else:
        print(f"Error: {json_response.get('descripcion', 'No se pudo obtener la URL de los datos')}")
        return None

def fetch_data_from_url(data_url):
    response = requests.get(data_url)
    response.raise_for_status()
    return response.json()

def format_data(data):
    formatted_data = []
    for item in data:
        formatted_data.append({
            "Fecha": item.get("fecha"),
            "Estacion": item.get("nombre"),
            "Provincia": item.get("provincia"),
            "Temperatura_Media_C": float(item.get("tmed", "0").replace(",", ".")),
            "Temperatura_Maxima_C": float(item.get("tmax", "0").replace(",", ".")),
            "Temperatura_Minima_C": float(item.get("tmin", "0").replace(",", ".")),
            "Precipitacion_mm": float(item.get("prec", "0").replace(",", ".")),
            "Humedad_Relativa_Media": float(item.get("hrMedia", "0").replace(",", ".")),
            "Presion_Maxima_hPa": float(item.get("presMax", "0").replace(",", ".")),
            "Presion_Minima_hPa": float(item.get("presMin", "0").replace(",", ".")),
            "Velocidad_Media_Viento_ms": float(item.get("velmedia", "0").replace(",", ".")),
            "Racha_Maxima_Viento_ms": float(item.get("racha", "0").replace(",", "."))
        })
    return formatted_data

def load_data_to_bigquery(data):
    client = bigquery.Client()
    table_id = os.getenv('BIGQUERY_TABLE_ID')
    errors = client.insert_rows_json(table_id, data)
    if errors:
        raise Exception(f"Failed to insert rows: {errors}")

@app.route('/', methods=['POST'])
def main(request):
    try:
        api_key = os.getenv('API_KEY')
        if not api_key:
            raise Exception("API_KEY not found in environment variables")
        
        # Imprimir la API key para depuración
        print(f"API_KEY: {repr(api_key)}")
        
        # Verificar y limpiar la API key
        api_key = api_key.strip()
        
        start_date = '2024-05-23T00:00:00UTC'
        end_date = '2024-05-24T23:59:59UTC'
        station_id = '3195'  # ID de estación de Madrid - Retiro

        data_url = fetch_aemet_data(api_key, start_date, end_date, station_id)
        if data_url:
            data = fetch_data_from_url(data_url)
            formatted_data = format_data(data)
            load_data_to_bigquery(formatted_data)
            return jsonify({"message": "Data loaded successfully"}), 200
        else:
            return jsonify({"error": "No se pudieron obtener los datos de AEMET"}), 500
    except Exception as e:
        print(f"Exception: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
