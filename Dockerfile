FROM ubuntu:bionic

MAINTAINER yx2@sanger.ac.uk

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      description="tool to produce and post file checksum for dockstore.org"

USER root

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

COPY build/build.sh build/
RUN bash build/build.sh

COPY scripts/run_gridss.sh /usr/bin/
RUN chmod a+x /usr/bin/run_gridss.sh

USER ubuntu
COPY data/ENCFF001TDO_GRCh37.bed /home/ubuntu/
RUN chmod a+r /home/ubuntu/ENCFF001TDO_GRCh37.bed

WORKDIR /home/ubuntu

CMD ["/bin/bash"]
