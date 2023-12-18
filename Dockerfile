FROM python:3.11.3-slim

# Install prerequisites
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libcurl3-dev \
    libleptonica-dev \
    liblog4cplus-dev \
    libopencv-dev \
    libtesseract-dev \
    wget

# Install prerequisites
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y cmake 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y curl 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y git 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y libcurl3-dev 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y libleptonica-dev 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y liblog4cplus-dev 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y libopencv-dev 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y libtesseract-dev 
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y wget

# Copy all data
RUN git clone https://github.com/gustavozantut/openalpr /srv/

WORKDIR /srv/openalpr

RUN pip install -r /srv/openalpr/requirements.txt
RUN rm /srv/openalpr/requirements.txt

# Setup the build directory
RUN mkdir /srv/openalpr/src/build
WORKDIR /srv/openalpr/src/build

# Setup the compile environment
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc .. && \
    make -j2 && \
    make install

WORKDIR /srv/openalpr/src

ENTRYPOINT ["python", "persist_folder_predict.py"]