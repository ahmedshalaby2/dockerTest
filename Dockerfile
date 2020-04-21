FROM registry.access.redhat.com/ubi8/ubi:8.0

MAINTAINER AhmedShalaby

ENV DOCROOT=/var/www/html

RUN   yum install -y  --disableplugin=subscription-manager httpd && \ 
      yum clean all --disableplugin=subscription-manager -y && \
      echo "Hello from the httpd-parent container!" > ${DOCROOT}/index.html

# Labels consumed by OpenShift
LABEL io.k8s.description="A basic Apache HTTP Server child image, uses ONBUILD" \
      io.k8s.display-name="Apache HTTP Server" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="apache, httpd"

COPY src/ ${DOCROOT}/
# Change web server port to 8080
RUN sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf

# Permissions to allow container to run on OpenShift
RUN chgrp -R 0 /var/log/httpd /var/run/httpd && \
    chmod -R g=u /var/log/httpd /var/run/httpd

# Run as a non-privileged user
USER 1001

CMD /usr/sbin/httpd -DFOREGROUND
EXPOSE 8080