#!/bin/bash

# Cambiar a directorio transformation y ejecutar terraform destroy
echo "Ejecutando terraform destroy en el directorio transformation..."
cd etl/transformation
terraform destroy -auto-approve

# Cambiar al directorio connector y ejecutar terraform destroy
echo "Ejecutando terraform destroy en el directorio connector..."
cd ../connector
terraform destroy -auto-approve

# Cambiar al directorio del Cloud Scheduler y ejecutar terraform destroy
echo "Ejecutando terraform destroy en el directorio cloud_scheduler..."
cd ../../cloud_scheduler
terraform destroy -auto-approve

echo "Ejecutando terraform destroy en el directorio big_query..."
cd ../bigquery
terraform destroy -auto-approve

echo "Proceso de deshacer completado con éxito."

