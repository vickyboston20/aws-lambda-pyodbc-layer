#!/bin/bash

for i in {1..30}; do
    docker exec mssql /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "yourStrong(@)Password" -Q "SELECT 1" -N -C > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "MSSQL is ready!"
        break
    fi
    echo "Waiting for MSSQL to be ready..."
    sleep 5
done

