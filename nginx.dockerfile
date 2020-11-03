FROM nginx
USER root
ARG project_name
ENV project_name=${project_name}
COPY config/nginx /etc/confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd
RUN confd -onetime -backend env
RUN cp /home/nginx.conf /etc/nginx/conf.d/default.conf
#RUN cp /home/nginx.conf /etc/nginx/sites-available/nginx.conf
#RUN ln /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf 