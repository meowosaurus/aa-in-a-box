FROM ubuntu:noble

RUN apt update && apt upgrade -y 
RUN apt install build-essential -y
RUN apt install gettext -y
RUN apt install python3 \
                python3-dev \
                python3-venv \
                python3-setuptools \
                python3-pip -y
RUN apt install unzip \
                git \
                curl \
                libssl-dev \
                libbz2-dev \
                libffi-dev \
                pkg-config -y
RUN apt install mysql-server \
                mysql-client \
                libmysqlclient-dev -y
RUN apt install vim nano -y

# Update apt repo for redis-server
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:redislabs/redis
RUN apt update
RUN apt install redis-server -y

RUN apt clean

# Configure MySQL to listen on localhost and run as root
RUN usermod -d /var/lib/mysql/ mysql
RUN sed -i 's/bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Setup MySQL database and user in the same RUN command
RUN service mysql start && \
    mysql -uroot -e "CREATE DATABASE aa_dev CHARACTER SET utf8mb4;" && \
    mysql -uroot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'securepassword';" && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON aa_dev.* TO 'admin'@'localhost';" && \
    mysql -uroot -e "FLUSH PRIVILEGES;"

# Verify that the database is created
RUN service mysql start && \
    mysql -uroot -e "SHOW DATABASES LIKE 'aa_dev';" | grep -q aa_dev && \
    echo "Database aa_dev exists" || \
    echo "Database aa_dev does not exist"

RUN service mysql start && \
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

RUN mkdir /opt/aa-dev
WORKDIR /opt/aa-dev

# Create virtual environment and activate it
RUN python3 -m venv venv
ENV PATH=/opt/aa-dev/venv/bin:$PATH

# Install pip dependencies
RUN pip3 install --upgrade pip
RUN pip3 install setuptools wheel
RUN pip3 install allianceauth

# Setup Alliance Auth app
RUN allianceauth start myauth

RUN mkdir /opt/aa-dev/plugins
COPY start-services.sh /opt/aa-dev/start-services.sh
RUN chmod a+x /opt/aa-dev/start-services.sh
COPY local.py /opt/aa-dev/myauth/myauth/settings/local.py

EXPOSE 8000