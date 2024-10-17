# Use the latest Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Define arguments for versions
ARG PYTHON_VERSION
ARG MSODBC_VERSION
ARG UNIXODBC_VERSION

# Install pyenv dependencies and required build tools
RUN yum -y update && \
    yum -y install gcc gcc-c++ make automake autoconf libtool bison flex \
                   openssl-devel zlib-devel glibc-devel tar gzip zip \
                   patch zlib-devel bzip2 bzip2-devel readline-devel \
                   sqlite sqlite-devel tk-devel \
                   libffi-devel xz-devel git curl wget

# Install pyenv
RUN curl https://pyenv.run | bash

# Set up environment for pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN echo 'eval "$(pyenv init --path)"' >> $HOME/.bashrc

# Install Python using pyenv and set it as global version
RUN source $HOME/.bashrc && \
    pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}

# Download and build unixODBC
RUN curl ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-${UNIXODBC_VERSION}.tar.gz -O && \
    tar xzvf unixODBC-${UNIXODBC_VERSION}.tar.gz && \
    cd unixODBC-${UNIXODBC_VERSION} && \
    ./configure --sysconfdir=/opt --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE --prefix=/opt && \
    make && make install && \
    cd .. && rm -rf unixODBC-${UNIXODBC_VERSION}.tar.gz unixODBC-${UNIXODBC_VERSION}

# Conditional ODBC Driver Installation Logic
RUN if [[ "${MSODBC_VERSION}" == "18" || "${MSODBC_VERSION}" == "17" ]]; then \
        curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
        ACCEPT_EULA=Y yum install -y msodbcsql${MSODBC_VERSION}; \
    elif [[ "${MSODBC_VERSION}" == "13.1" ]]; then \
        curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
        ACCEPT_EULA=Y yum  install -y msodbcsql; \
    elif [[ "${MSODBC_VERSION}" == "13" ]]; then \
        curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
        ACCEPT_EULA=Y yum install -y msodbcsql-13.0.1.0-1; \
    else \
        echo "Unsupported ODBC version"; \
        exit 1; \
    fi

# Configure ODBC
RUN echo "[ODBC Driver ${MSODBC_VERSION} for SQL Server]" > /opt/odbcinst.ini && \
    echo "Description=Microsoft ODBC Driver ${MSODBC_VERSION} for SQL Server" >> /opt/odbcinst.ini && \
    echo "Driver=/opt/msodbcsql${MSODBC_VERSION}/lib64/libmsodbcsql-${MSODBC_VERSION}.so" >> /opt/odbcinst.ini && \
    echo "UsageCount=1" >> /opt/odbcinst.ini && \
    echo "[ODBC Driver ${MSODBC_VERSION} for SQL Server]" > /opt/odbc.ini && \
    echo "Driver = ODBC Driver ${MSODBC_VERSION} for SQL Server" >> /opt/odbc.ini && \
    echo "Description = My ODBC Driver ${MSODBC_VERSION} for SQL Server" >> /opt/odbc.ini && \
    echo "Trace = No" >> /opt/odbc.ini

# Install pyodbc Python library
RUN mkdir /opt/python/ && pip install pyodbc -t /opt/python/

# Package the layer into a zip file
RUN cd /opt && zip -r9 /opt/pyodbc-layer.zip .

# Final step to make zip available
CMD ["cat", "/opt/pyodbc-layer.zip"]