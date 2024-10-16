# AWS Lambda Layer for PyODBC with Microsoft SQL Server


## Description
This repository provides a framework for building AWS Lambda layers that enable connectivity to Microsoft SQL Server databases using the [pyodbc](https://pypi.org/project/pyodbc) library. Each artifact is version-specific, tailored for a particular combination of Python and Microsoft ODBC driver versions. The GitHub Actions CI/CD pipeline automates the building and deployment of these artifacts as zip files, allowing developers to easily create and utilize layers in their AWS Lambda functions.

## Features
- **Version-Specific Artifacts**: Each layer is built for a specific combination of [Python](https://gallery.ecr.aws/lambda/python) (3.9, 3.10, 3.11, 3.12) and [Microsoft ODBC driver versions](https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server) (18, 17, 13.1, 13, 11).

- **Automated Builds**: The GitHub Actions workflow automates the process of building and packaging the layers, making it easy for developers to access the latest versions without manual setup

- **Easy Layer Integration**: Developers can download the zip files and integrate them into their Lambda functions effortlessly.

## Acknowledgments
- This layer utilizes the pyodbc library, maintained by the open-source community. More information can be found at the [pyodbc GitHub repository](https://github.com/mkleehammer/pyodbc).
- The Microsoft ODBC Driver for SQL Server is developed and maintained by Microsoft. Refer to the official [Microsoft documentation](https://learn.microsoft.com/en-us/sql/connect/python/pyodbc/python-sql-driver-pyodbc) for installation instructions and driver information.

## License
This project is licensed under the MIT License. Feel free to use, modify, and distribute this project in accordance with the terms of the license.

## Contributions
Contributions are welcome! If you have suggestions for improvements or find any issues, please open an issue or submit a pull request.

## Credits
This project was developed by [Vigneshwar Thiyagarajan](www.linkedin.com/in/vigneshwar-thiyagarajan-87220a124). Special thanks to the community for their contributions and support.
