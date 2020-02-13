# CONFIG
export		NEW_MACHINES=/tmp/ft_services_machines
export		REAL_MACHINES=~/.minikube/machines

logc() {
	echo $1 >> log.txt
	/bin/echo -n $1
}

errc() {
	if [ $? -eq 0 ]; then
		echo "\033[32mOK\033[0m"
		echo "OK" >> log.txt
	else
		echo "\033[31mERROR\033[0m"
		echo "ERROR" >> log.txt
		echo "An error has occured. For more information read log.txt"
		echo ":LOG START:\033[31m"
		tail log.txt
		echo "\033[0m:LOG END:"
		exit
	fi
}

warnc() {
	if [ $? -eq 0 ]; then
		echo "\033[32mOK\033[0m"
		echo "OK" >> log.txt
	else
		echo "\033[1;33mWARN\033[0m"
		echo "WARN" >> log.txt
	fi
}

echo log_start > log.txt

#mkdir -p ~/goinfre/docker
#rm -rf ~/Library/Containers/com.docker.docker
#ln -s ~/goinfre/docker ~/Library/Containers/com.docker.docker

# reset minikube

logc		"Checking if Docker is installed..."
docker		--version >> log.txt 2>>log.txt
errc

logc		"Checking if VirtualBox is installed..."
virtualbox	-h >> log.txt 2>>log.txt
errc

if [ "$1" != "ss" ]; then
logc		"Deleting minikube..."
minikube	delete >> log.txt 2>>log.txt
warnc

# set minikube directory to a temporary one
logc	"Cleaning old machine directory..."
rm		-rf $NEW_MACHINES >> log.txt 2>>log.txt
errc

logc	"Creating new machine directory..."
mkdir	$NEW_MACHINES >> log.txt 2>>log.txt
errc

logc	"Linking machine directory..."
ln		-s $NEW_MACHINES $REAL_MACHINES >> log.txt 2>>log.txt
errc

# reset minikube
logc		"Resetting minikube..."
minikube	delete >> log.txt 2>>log.txt
errc

# set minikube directory to a temporary one
logc	"Cleaning old machine directory..."
rm		-rf $NEW_MACHINES >> log.txt 2>>log.txt
errc

logc	"Creating new machine directory..."
mkdir	$NEW_MACHINES >> log.txt 2>>log.txt
errc

logc	"Linking machine directory..."
ln		-s $NEW_MACHINES $REAL_MACHINES >> log.txt 2>>log.txt
errc

logc	"Resetting VirtualBox DHCP leases..."
kill -9 $(ps aux |grep -i "vboxsvc\|vboxnetdhcp" | awk '{print $2}') >> log.txt 2>>log.txt
if [[ -f ~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.leases ]] ; then
	rm ~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.leases
fi
/bin/echo	-n ""
errc

# start minikube
logc		"Starting minikube (this can take a while)..."
minikube	start \
			--vm-driver=virtualbox \
			--memory=2558 \
			--disk-size=20g \
			--cpus=6 \
			--bootstrapper=kubeadm \
			--extra-config=apiserver.service-node-port-range=10-10000 \
			>> log.txt 2>>log.txt
errc
else
echo	"Skipping minikube setup!"
fi
# enable addons
logc		"Enabling Ingress addon..."
minikube	addons enable ingress >> log.txt 2>>log.txt
errc

logc		"Enabling dashboard addon..."
minikube	addons enable dashboard >> log.txt 2>>log.txt
errc

# build docker images
logc		"Switching to Docker environment..."
eval		$(minikube docker-env)
errc

logc		"Building NGINX Docker image..."
docker		build srcs/nginx/ -t my-nginx >> log.txt 2>>log.txt
errc

logc		"Building FTPS Docker image..."
docker		build srcs/ftps/ -t my-ftps >> log.txt 2>>log.txt
errc

if [ "$1" != "tig" ]; then

logc		"Building MySQL Docker image..."
docker		build srcs/mysql/ -t my-mysql >> log.txt 2>>log.txt
errc

logc		"Building WordPress Docker image..."
docker		build srcs/wordpress/ -t my-wordpress >> log.txt 2>>log.txt
errc

logc		"Building phpMyAdmin Docker image..."
docker		build srcs/phpmyadmin/ -t my-pma >> log.txt 2>>log.txt
errc
else
echo		"Skipping non-TIG!"
fi

logc		"Building Grafana Docker image..."
docker		build srcs/grafana/ -t my-grafana >> log.txt 2>>log.txt
errc

logc		"Building InfluxDB Docker image..."
docker		build srcs/influxdb/ -t my-influxdb >> log.txt 2>>log.txt
errc

logc		"Building Telegraf Docker image..."
docker		build srcs/telegraf/ -t my-telegraf >> log.txt 2>>log.txt
errc

# load configurations
if [ "$1" != "nk" ]; then
logc		"Applying kustomization..."
kubectl		apply -k srcs >> log.txt 2>>log.txt
errc
else
echo		"Skipping kustomization!"
fi

/bin/echo	-n "The server is hosted at: "
touch tmplog
while [ ! -s tmplog ]
do
	grep \
		-o "192.168.99.100" \
		~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.leases \
		> tmplog
done
cat tmplog
rm -f tmplog

echo
minikube dashboard &