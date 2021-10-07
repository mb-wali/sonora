############################
## Centos7 with postgresql9.6 installed

# USER postgres PASSWORD testpassword
# USER de PASSWORD testpassword
# ROLE de
########################################
### USER de has the following databases:
# de
# metadata
# notifications
# permissions

############################

FROM centos:7

RUN yum install --assumeyes \
      https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install --assumeyes postgresql96-server


# install server
RUN yum install -y postgresql96 postgresql96-server postgresql96-contrib postgresql96-libs

# initialize DB data files
RUN su - postgres -c '/usr/pgsql-9.6/bin/initdb -D /var/lib/pgsql/data'

# set permissions to allow logins, trust the bridge, this is the default for docker YMMV
RUN echo "host    all             all             0.0.0.0/0           md5" >> /var/lib/pgsql/data/pg_hba.conf

#listen on all interfaces
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf

#expose 5432
EXPOSE 5432

### Creates initial empty database and database user
# Switches user executing next command
USER postgres

# set correct collate value
RUN /usr/pgsql-9.6/bin/initdb --auth ident  --lc-collate C --locale en_US.UTF-8 --pgdata /var/lib/pgsql/9.6/data

## Add seeds to databases
ADD ./seeds/seeds.sql /db-dumps/

# Creates user and database
# change postgresl user password
RUN /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/data -w start \
 && /usr/pgsql-9.6/bin/psql --command "CREATE USER de WITH SUPERUSER PASSWORD 'testpassword';" \
 && /usr/pgsql-9.6/bin/psql --command "ALTER USER postgres PASSWORD 'testpassword';" \
 && /usr/pgsql-9.6/bin/psql -f ./db-dumps/seeds.sql \
#  && /usr/pgsql-9.6/bin/createdb -O de de \
#  && /usr/pgsql-9.6/bin/createdb -O de metadata \
#  && /usr/pgsql-9.6/bin/createdb -O de notifications \
 && /usr/pgsql-9.6/bin/createdb -O de grouper \
 && /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/data -w stop

### Add VOLUMEs to allow persistence of database
VOLUME  ["/usr/pgsql-9.6", "/var/lib/pgsql/data"]

### Starts database as soon as container is being started
CMD ["/usr/pgsql-9.6/bin/postgres", "-D", "/var/lib/pgsql/data/", "-i"]


#######################
## build
# docker build -t mbwali/cyverse-db-seeds:latest ./postgres
#
#######################

#######################
## Find ip address of container
# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 5d4553dc9840
#
## test connection
# psql -U de -h 172.20.0.6 -p 5432
#
## List of databases postgresql
# psql -U de -h 172.20.0.6 -p 5432 -l
#
## Open database of metadata
# psql -U de -d metadata -h 172.20.0.6 -p 5432
#
######################

################################
## Run initialize to db command
#
# java -jar facepalm-standalone.jar -h 172.20.0.6 -m init -U de -d de -f database.tar.gz
# java -jar facepalm-standalone.jar -h 172.20.0.6 -m init -U de -d metadata -f metadata-db.tar.gz
# java -jar facepalm-standalone.jar -h 172.20.0.6 -m init -U de -d notifications -f notification-db.tar.gz
# java -jar facepalm-standalone.jar -h 172.20.0.6 -m init -U de -d permissions -f permissions-db.tar.gz
#
# testpassword
################################

################################
## Dump all databases
# docker exec -it 2b9bc2e60cde pg_dumpall -U de > ./dumpall.sql
################################

################################
## Dump all databases
# psql -f /dumpall.sql
################################
