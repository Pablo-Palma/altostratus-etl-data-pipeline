#!/bin/bash

# Cambiar a directorio connector y ejecutar terraform apply
echo "Ejecutando terraform apply en el directorio connector..."
cd connector
terraform apply -auto-approve

# Capturar el URL de salida de terraform
CLOUD_FUNCTION_URL=$(terraform output -raw cloud_function_url | tr -d '\r')
echo "URL de la función de cloud: $CLOUD_FUNCTION_URL"

# Cambiar al directorio transformation y ejecutar terraform apply
echo "Ejecutando terraform apply en el directorio transformation..."
cd ../transformation
terraform apply -auto-approve

echo "Haciendo solicitud curl a la función de cloud hasta obtener una respuesta exitosa..."
SUCCESS_MESSAGE="Data loaded successfully"
RETRY_LIMIT=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $RETRY_LIMIT ]; do
  CURL_RESPONSE=$(curl -s $CLOUD_FUNCTION_URL)
  echo "Respuesta de curl: $CURL_RESPONSE"
  if echo "$CURL_RESPONSE" | grep -q "$SUCCESS_MESSAGE"; then
    echo "La solicitud curl fue exitosa."
    break
  else
    echo "La solicitud curl falló. Reintentando en 10 segundos..."
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 10
  fi
done

if [ $RETRY_COUNT -ge $RETRY_LIMIT ]; then
  echo "Se alcanzó el límite de reintentos sin éxito. Abortando el proceso."
  exit 1
fi

echo "Ejecutando consulta SQL en BigQuery..."
bq query --use_legacy_sql=false < transformation.sql

echo "Proceso completado con éxito."

