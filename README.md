# AWS Lambda Layer for PyODBC with Microsoft SQL Server

## Description

This repository provides a framework for building AWS Lambda layers that enable connectivity to Microsoft SQL Server databases using the [pyodbc](https://pypi.org/project/pyodbc) library. Each artifact is version-specific, tailored for a particular combination of Python, Microsoft ODBC driver and UNIXODBC versions. The GitHub Actions CI/CD pipeline automates the building, packaging and deployment of these artifacts as zip files, allowing developers to easily create and utilize layers in their AWS Lambda functions.

## Important

Currently, this project supports only x86_64 architecture. Future updates will include support for arm64 architecture.

## Features

- **Version-Specific Artifacts**: Lambda layers are built for specific combinations of:
  - **Python versions**: ```3.9```, ```3.10```,```3.11```, ```3.12```, ```3.13``` (using [pyenv](https://github.com/pyenv/pyenv))
  - **Microsoft ODBC driver versions**: ```17```, ```18```(using [Microsoft ODBC driver versions](https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server))
  - **UNIXODBC versions**: ```2.3.12``` (with support for [multiple ODBC versions](https://www.unixodbc.org/download.html))

- **Automated CI/CD with GitHub Actions**: The build, test and release pipeline is fully automated using GitHub Actions. This setup ensures the latest Lambda layer artifacts are built, tested, and made available for download whenever a new version is pushed or a pull request is created.

- **Effortless Lambda Integration**: Developers can easily download the pre-built zip files and directly use them in their Lambda functions without having to build or configure the pyodbc setup manually.

## Usage

### Steps to Use the PyODBC Layer in AWS Lambda

1. **Download the Pre-built Zip**: The zip files for the required Python version, ODBC driver version, and UNIXODBC version can be downloaded from the GitHub release section.
2. **Upload the Layer to AWS Lambda**:
   - Go to the AWS Lambda console.
   - Create a new Lambda layer and upload the downloaded zip file.
3. **Add the Layer to Your Lambda Function**: Once the layer is uploaded, you can add it to any Lambda function where pyodbc and Microsoft SQL Server connectivity are needed.

## GitHub Actions Workflow

The GitHub Actions workflow [build.yml](.github/workflows/build.yml) builds the Docker image, testing the layer and packages the Lambda layers as zip using the following steps:

1. **Docker Build**: The Docker image is built with the specified Python, Microsoft ODBC, and UNIXODBC versions. The pyodbc library is installed for each Python version.
2. **Artifacts Creation**: Zip files are created for each combination of Python and ODBC versions. These are stored in the ```/opt/artifacts/``` directory.
3. **Testing**: Each Lambda layer is tested against a live SQL Server instance running in Docker. The test framework ensures that the pyodbc library and ODBC driver are functioning correctly.
4. **Release**: Upon pushing a version tag (e.g., ```v1.0.0```), the workflow automatically creates a new GitHub release and includes the relevant zip files for easy download.

### Build Matrix

  The workflow supports building layers for multiple versions using a matrix strategy, allowing for simultaneous builds of:

- MSODBC Version: ```18```, ```17```
- UNIXODBC Version: ```2.3.12```

### Updating Python Versions for Build

  In the [build.yml](.github/workflows/build.yml#L32), Python versions can be modified under the build job by adjusting the  ```--build-arg PYTHON_VERSIONS="3.12,3.11"```.

## How to Build Locally

To build the Lambda layers locally, you can follow these steps:

1. Clone the repository.
2. Install Docker if you haven’t already.
3. Run the following command to build the image and create the Lambda layer artifacts:

    ```bash
    docker build \
      --platform linux/amd64 \ 
      --build-arg PYTHON_VERSIONS="3.13,3.12,3.11,3.10,3.9" \
      --build-arg MSODBC_VERSION=18 \
      --build-arg UNIXODBC_VERSION=2.3.12 \
      -t pyodbc-lambda-layer:multi-python .
    ```

4. Extract the zip files from the Docker container:

    ```bash
    CONTAINER_ID=$(docker create pyodbc-lambda-layer:multi-python)
    docker cp $CONTAINER_ID:/opt/artifacts/. .
    docker rm $CONTAINER_ID
    ```

5. The zip files will be available in the current directory for you to use.

## How to Test

If you want to test the Lambda layers, simply push your code to the relevant branch in the repository. The CI pipeline will automatically handle building and testing the Lambda layers based on the configuration in the build.yml file.

## Roadmap

- **Current Support**: The layers support the x86_64 architecture for Python ```3.9```, ```3.10```, ```3.11```, ```3.12```, ```3.13``` with Microsoft ODBC Driver versions ```17``` and ```18```, and UNIXODBC ```2.3.12```.
- **Future Updates**:
  - **ARM64 Support**: In future releases, support for the arm64 architecture will be added, allowing for broader compatibility across different AWS Lambda runtime environments.

## Acknowledgments

- **PyODBC**: This project uses the ```pyodbc``` library, which is maintained by the open-source community. More information can be found in the [pyodbc GitHub repository](https://github.com/mkleehammer/pyodbc).

- **Microsoft ODBC Driver for SQL Server**: The Microsoft ODBC Driver is developed and maintained by Microsoft. Refer to the [Microsoft documentation](https://learn.microsoft.com/en-us/sql/connect/python/pyodbc/python-sql-driver-pyodbc) for more information.

- **unixODBC**: unixODBC is used to facilitate ODBC connections on Unix systems. See the [official unixODBC documentation](https://www.unixodbc.org/download.html) for more details.

## License

This project is licensed under the [MIT](LICENSE). Feel free to use, modify, and distribute this project under the terms of the license.

## Contributions

Contributions are welcome! If you have suggestions for improvements or encounter issues, feel free to open an issue or submit a pull request.

## Credits

This project was developed by [Vigneshwar Thiyagarajan](https://www.linkedin.com/in/vigneshwar-thiyagarajan-87220a124/). Special thanks to the open-source community for their contributions and support.
