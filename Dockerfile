# Use the Amazon Lambda Python base image
ARG LAMBDA_BASE_IMAGE
FROM ${LAMBDA_BASE_IMAGE}

# Set build arguments for Microsoft ODBC and UnixODBC versions
ARG MSODBC_VERSION
ARG UNIXODBC_VERSION

# Set environment variables for ODBC configuration
ENV ODBCINI=/opt/odbc.ini
ENV ODBCSYSINI=/opt

# Install necessary build dependencies (using dnf or yum fallback)
RUN (dnf install -y gcc gcc-c++ make automake autoconf libtool bison flex openssl-devel zlib-devel glibc-devel tar gzip) || \
    (yum install -y gcc gcc-c++ make automake autoconf libtool bison flex openssl-devel zlib-devel glibc-devel tar gzip)

# Download and build unixODBC
RUN curl ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-${UNIXODBC_VERSION}.tar.gz -O && \
    tar xzvf unixODBC-${UNIXODBC_VERSION}.tar.gz && \
    cd unixODBC-${UNIXODBC_VERSION} && \
    ./configure --sysconfdir=/opt --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE --prefix=/opt && \
    make && make install && \
    cd .. && rm -rf unixODBC-${UNIXODBC_VERSION}.tar.gz unixODBC-${UNIXODBC_VERSION}

# Download and install Microsoft ODBC driver for SQL Server
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
    ACCEPT_EULA=Y dnf install -y msodbcsql${MSODBC_VERSION}

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
