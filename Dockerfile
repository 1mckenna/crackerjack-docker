FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ocl-icd-libopencl1 \
        clinfo && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
################################ end nvidia opencl driver ################################

ENV HASHCAT_VERSION        v6.1.1
ENV HASHCAT_UTILS_VERSION  v1.9
ENV HCXTOOLS_VERSION       6.0.2
ENV HCXDUMPTOOL_VERSION    6.0.6
ENV HCXKEYS_VERSION        master

# Update & install packages for installing hashcat and nginx
RUN apt-get update && \
    apt-get install -y wget make clinfo build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev libcurl4-openssl-dev libssl-dev screen python3-venv python3-pip sqlite3 nginx

WORKDIR /root

RUN git clone https://github.com/hashcat/hashcat.git && cd hashcat && git checkout ${HASHCAT_VERSION} && make install -j4

RUN git clone https://github.com/hashcat/hashcat-utils.git && cd hashcat-utils/src && git checkout ${HASHCAT_UTILS_VERSION} && make
RUN ln -s /root/hashcat-utils/src/cap2hccapx.bin /usr/bin/cap2hccapx

RUN git clone https://github.com/ZerBea/hcxtools.git && cd hcxtools && git checkout ${HCXTOOLS_VERSION} && make install

RUN git clone https://github.com/ZerBea/hcxdumptool.git && cd hcxdumptool && git checkout ${HCXDUMPTOOL_VERSION} && make install

RUN git clone https://github.com/hashcat/kwprocessor.git && cd kwprocessor && git checkout ${HCXKEYS_VERSION} && make
RUN ln -s /root/kwprocessor/kwp /usr/bin/kwp

#Install CrackerJack
ENV LC_ALL=C.UTF-8 
ENV LANG=C.UTF-8
RUN git clone https://github.com/ctxis/crackerjack
WORKDIR /root/crackerjack
RUN python3 -m venv venv && . venv/bin/activate && pip install -r requirements.txt && flask db init && flask db migrate && flask db upgrade && deactivate
RUN chown -R www-data:www-data /root/crackerjack
RUN mkdir -p /root/crackerjack/data/config/http
COPY ./vhost.conf /etc/nginx/sites-enabled/crackerjack
RUN mkdir /var/www/.hashcat && chown -R www-data:www-data /var/www/.hashcat
COPY ./entrypoint.sh .
RUN chmod 755 ./entrypoint.sh
#Run the App once the container launches
CMD [ "/bin/bash","/root/crackerjack/entrypoint.sh" ]
EXPOSE 443
