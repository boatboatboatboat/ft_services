FROM		alpine

RUN			apk add vsftpd
RUN			apk add openssl

# setup dir
COPY		./files/ /srv/ftp
COPY		./vsftpd.conf /etc/vsftpd/vsftpd.conf

RUN			chown nobody:nogroup /srv/ftp

# gen keys
COPY		./keys/ /serverkeys/
COPY		./entrypoint.sh /entrypoint.sh

EXPOSE 20 21 420-423

ENTRYPOINT	["/bin/sh", "/entrypoint.sh"]
