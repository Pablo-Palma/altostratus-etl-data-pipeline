#!/bin/bash

# Cambiar a directorio transformation y ejecutar terraform destroy
echo "Ejecutando terraform destroy en el directorio transformation..."
cd transformation
terraform destroy -auto-approve

# Cambiar al directorio connector y ejecutar terraform destroy
echo "Ejecutando terraform destroy en el directorio connector..."
cd ../connector
terraform destroy -auto-approve

echo "Proceso de deshacer completado con éxito."

