FROM python:3.6-slim

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip==20.2.4 && \
    pip install tensorflow==1.13.1 protobuf==3.19.4 tqdm numpy pandas tflearn

