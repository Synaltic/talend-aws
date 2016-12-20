#!/usr/bin/env bash

tomcat_home="/opt/tomcat"
app_name="Talend"
app_version="6.2.1"
environment_cf="{{environment}}"
region_cf="{{region}}"

local_ip="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
local_hostname="$(hostname)"
sed -i "s/^127.0.0.1 ${local_hostname}$//" /etc/hosts
echo "${local_ip} ${local_hostname} ${local_hostname}.${environment_cf}" >> /etc/hosts

echo "############installation TAC###########"
echo "stop tomcat if started"
service tomcat8 stop

echo "download TAC application"
aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/Talend-AdministrationCenter-20160704_1411-V6.2.1.zip /tmp/ --region ${region_cf}


echo "Unzip Talend Administration Center installation file"
cd /tmp/
unzip /tmp/Talend-AdministrationCenter-20160704_1411-V6.2.1.zip

echo "Copy TAC war to tomcat webapps"
cp /tmp/Talend-AdministrationCenter-20160704_1411-V6.2.1/org.talend.administrator-6.2.1.war ${tomcat_home}/webapps/org.talend.administrator.war

echo "change privileges of war"
chown talend:tomcat ${tomcat_home}/webapps/org.talend.administrator.war

echo "start tomcat for deployment"
service tomcat8 start

echo "wait deployment end"
until $(curl --output /dev/null --silent --head --fail http://localhost:8080/org.talend.administrator); do
    printf '.'
    sleep 5
done

echo "stop tomcat after deployment"
service tomcat8 stop

echo "get configuration file from S3"
aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/configuration.properties ${tomcat_home}/webapps/org.talend.administrator/WEB-INF/classes/ --region ${region_cf}
chown talend:tomcat /opt/tomcat/webapps/org.talend.administrator/WEB-INF/classes/configuration.properties

echo "add log libraries to tomcat"
#aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/slf4j-jdk14-1.7.2.jar ${tomcat_home}/lib/ --region ${region_cf}
#aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/slf4j-api-1.7.2.jar ${tomcat_home}/lib/ --region ${region_cf}

echo "remove installation and temp files"
rm -rf /tmp/Talend-AdministrationCenter-20160704_1411-V6.2.1
rm /tmp/Talend-AdministrationCenter-20160704_1411-V6.2.1.zip

echo "############installation AMC###########"
echo "download AMC application"
aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/Talend-AMC_Web-20160704_1411-V6.2.1.zip /tmp/ --region ${region_cf}

echo "unzip AMC installation file"
unzip  /tmp/Talend-AMC_Web-20160704_1411-V6.2.1.zip

echo "copy war file to tomcat"
cp /tmp/Talend-AMC_Web-20160704_1411-V6.2.1/amc.war -d ${tomcat_home}/webapps/

echo "change privilege of war"
chown talend:tomcat ${tomcat_home}/webapps/amc.war

echo "delete installations files"
rm -f /tmp/Talend-AMC_Web-20160704_1411-V6.2.1.zip
rm -rf /tmp/Talend-AMC_Web-20160704_1411-V6.2.1/

echo "############installation Talend LogServer###########"
echo "download LogServer application"
aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/Talend-LogServer-V6.0.0.4.zip /tmp/ --region ${region_cf}

echo "unzip installation files"
unzip /tmp/Talend-LogServer-V6.0.0.4.zip -d /opt/

echo "unzip and copy kibana to tomcat"
unzip /opt/Talend-LogServer/kibana-3.1.2.zip -d /tmp/
cp -R /tmp/kibana-3.1.2 ${tomcat_home}/webapps/kibana
chown -R talend:tomcat ${tomcat_home}/webapps/kibana

echo "download service file and define it as system service"
aws s3 cp s3://applications.${environment_cf}/${app_name}/${app_version}/tlogserver /etc/init.d/ --region ${region_cf}
chmod +x /etc/init.d/tlogserver
chkconfig --add tlogserver
chkconfig --level 234 tlogserver on

echo "add execute permission to logserver files"
chmod +x /opt/Talend-LogServer/start_logserver.sh
chmod +x /opt/Talend-LogServer/stop_logserver.sh
chmod +x /opt/Talend-LogServer/elasticsearch-1.5.2/bin/elasticsearch
chmod +x /opt/Talend-LogServer/logstash-1.5.0/bin/logstash
chmod -R +x /opt/Talend-LogServer/logstash-1.5.0/vendor/jruby/bin/

echo "change owner of logserver files"
chown -R talend:talend /opt/Talend-LogServer

echo "add permissions to elasticsearch security"
sed -i '$a http.cors.enabled: true'  /opt/Talend-LogServer/elasticsearch-1.5.2/config/elasticsearch.yml
sed -i '$a http.cors.allow-origin: \"http://'$(hostname -I | xargs)':8080\"' /opt/Talend-LogServer/elasticsearch-1.5.2/config/elasticsearch.yml

echo "start tlogserver service"
service tlogserver start

echo "start tomcat"
service tomcat8 start

echo "delete installation files"
rm /tmp/Talend-LogServer-V6.0.0.4.zip
rm -rf /tmp/kibana-3.1.2
rm /opt/Talend-LogServer/kibana-3.1.2.zip

echo "wait for tac..."
until $(curl --output /dev/null --silent --head --fail http://localhost:8080/org.talend.administrator); do
    printf '.'
    sleep 5
done

service tomcat8 restart
