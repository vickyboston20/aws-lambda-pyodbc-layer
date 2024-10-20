import json
import os
import pyodbc

def lambda_handler(event, context):
    msodbc_version = event.get('msodbc_version', '17')
    mssql_password = os.getenv('MSSQL_SA_PASSWORD', 'yourStrong(@)Password')
    try:
        conn = pyodbc.connect(
            f'DRIVER={{ODBC Driver {msodbc_version} for SQL Server}};'
            'SERVER=mssql;'
            'DATABASE=master;'
            'UID=sa;'
            f'PWD={mssql_password};'
            'TrustServerCertificate=yes;'
            'Encrypt=yes;'
        )
        cursor = conn.cursor()
        cursor.execute("SELECT @@VERSION;")
        row = cursor.fetchone()
        return {
            'statusCode': 200,
            'body': json.dumps(f'MSSQL Version: {row[0]}')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
