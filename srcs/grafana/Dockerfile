FROM	grafana/grafana

RUN		mkdir -pv /etc/grafana/provisioning/provisioning/
#		/usr/share/grafana/conf/provisioning/datasources/ \
#		/usr/share/grafana/conf/provisioning/dashboards
COPY	./files/datasource.yaml /etc/grafana/provisioning/datasources/datasource.yaml
COPY	./files/dashboardcfg.yaml /etc/grafana/provisioning/dashboards/dashboardcfg.yaml
COPY	./files/ /cpfiles/