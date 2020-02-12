FROM		alpine

# mariadb is a mysql database.
RUN			apk add mariadb mariadb-client

COPY		./files/socketfix.cnf /etc/my.cnf.d/socketfix.cnf
COPY		./files/ /cpfiles/
VOLUME		/var/lib/mysql

ENTRYPOINT	["/bin/sh", "/cpfiles/entrypoint.sh"]
