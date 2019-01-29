FROM ubuntu:18.04
LABEL maintainer="Lara Lloret Iglesias <lloret@ifca.unican.es>"
LABEL version="0.1"
LABEL description="DEEP as a Service: Container for conus classification"

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
        python-setuptools \
        python-pip

# We could shrink the dependencies, but this is a demo container, so...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         build-essential \
         python-dev \
         python-wheel \
         python-numpy \
         python-scipy \
         python-tk

RUN pip install --upgrade https://github.com/Theano/Theano/archive/master.zip
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

WORKDIR /srv

RUN apt-get install -y nano


#Install conus classification package

RUN git clone https://github.com/indigo-dc/conus-classification-theano -b package  && \
    cd conus-classification-theano && \
    pip install -e . && \
    cd ..

#Install deepaas
RUN pip install deepaas


ENV SWIFT_CONTAINER_conus https://cephrgw01.ifca.es:8080/swift/v1/conus/
ENV THEANO_TR_WEIGHTS_conus resnet50_70classes_100epochs.npz
ENV THEANO_TR_JSON_conus resnet50_70classes_100epochs.json
ENV SYNSETS_conus synsets.txt
ENV INFO_conus info.txt


RUN curl -o ./conus-classification-theano/conus_classification/training_weights/${THEANO_TR_WEIGHTS_conus} ${SWIFT_CONTAINER_conus}${THEANO_TR_WEIGHTS_conus}

RUN curl -o ./conus-classification-theano/conus_classification/training_info/${THEANO_TR_JSON_conus} ${SWIFT_CONTAINER_conus}${THEANO_TR_JSON_conus}

RUN curl -o ./conus-classification-theano/data/data_splits/synsets.txt  ${SWIFT_CONTAINER_conus}${SYNSETS_conus}



EXPOSE 5000

RUN apt-get install nano

CMD deepaas-run --listen-ip 0.0.0.0
