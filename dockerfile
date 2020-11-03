FROM python:3.8-alpine
WORKDIR /home/
RUN apk add --update py3-pip
RUN apk add py3-virtualenv
ARG project_name
ENV project_name=${project_name}
RUN mkdir /home/${project_name}
WORKDIR /home/${project_name}
RUN virtualenv venv
RUN source venv/bin/activate
RUN apk add jpeg-dev
RUN apk add zlib-dev
RUN apk add gcc
RUN apk add linux-headers
RUN apk add musl-dev
RUN pip3 install wagtail
RUN wagtail start ${project_name}
WORKDIR /home/${project_name}/${project_name}
RUN pip install -r requirements.txt
RUN python3 manage.py migrate
RUN python3 manage.py collectstatic
USER root
RUN pip3 install uwsgi
RUN apk add supervisor
RUN mkdir /etc/supervisor
RUN mkdir /etc/supervisor/conf.d
RUN mkdir /etc/uwsgi
RUN mkdir /etc/uwsgi/vassals
RUN mkdir /var/log/supervisor
COPY config/confd /etc/confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd
RUN confd -onetime -backend env
RUN ln /home/uwsgi.ini /etc/uwsgi/vassals/${project_name}_uwsgi.ini
RUN ln /home/uwsgi-runner.conf /etc/supervisor/conf.d/uwsgi-runner.conf
EXPOSE 3000
RUN echo "files = /etc/supervisor/conf.d/*" >> /etc/supervisord.conf
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

#RUN supervisorctl restart uwsgi-runner.conf
