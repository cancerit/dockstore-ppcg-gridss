FROM ubuntu:bionic

MAINTAINER yx2@sanger.ac.uk

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      description="tool to produce and post file checksum for dockstore.org"

USER root

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
RUN mkdir -p $OPT/bin
COPY scripts/run_gridss.sh $OPT/bin
RUN chmod a+x $OPT/bin/run_gridss.sh

COPY build/build.sh build/
RUN bash build/build.sh

WORKDIR /home/ubuntu

CMD ls
