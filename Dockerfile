FROM docker-registry-proxy.internal.stuart.com/python:3.8-slim as base_image
LABEL maintainer="Stuart Delivery"

ARG NEXUS_IP
ARG TOX_VER=3.20.1

ENV APP_DIR=/opt/data-platform-ui
ENV PYTHONPATH=${APP_DIR}

WORKDIR ${APP_DIR}

COPY ./de-conf/pip.conf /etc/pip.conf
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . ${APP_DIR}

RUN pip3 install tox==${TOX_VER}

EXPOSE 8000