FROM		nginx:alpine

RUN			mkdir /copy/
RUN			mkdir -pv /fakemnt/wp /fakemnt/pma

# configure ssh
RUN			apk add openssh
COPY		sshd_config /etc/ssh/sshd_config
RUN			ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN			ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN			adduser -D --shell /bin/sh dpattij
RUN			echo "if you read this you are stupid :^) :^) :^)" > /etc/motd
RUN			echo "dpattij:heck" | chpasswd
RUN			echo "root:heck" | chpasswd

# configure nginx
RUN			rm -rf /etc/nginx/conf.d/default.conf
COPY		nginx.conf /etc/nginx/conf.d/main.conf
COPY		certificate.pem /copy/certificate.pem
COPY		key.pem /copy/key.pem
COPY		./site/ /copy/site/

EXPOSE		80 443 22

COPY		entrypoint.sh /copy/entrypoint.sh
ENTRYPOINT	["/bin/sh", "/copy/entrypoint.sh"]
