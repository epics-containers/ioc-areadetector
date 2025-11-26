ARG IMAGE_EXT

ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/epics-base${IMAGE_EXT}-runtime:7.0.9ec5
ARG DEVELOPER=${REGISTRY}/ioc-asyn${IMAGE_EXT}-developer:4.45ec2

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

WORKDIR ${SOURCE_FOLDER}/ibek-support

COPY ibek-support/_ansible _ansible
ENV PATH=$PATH:${SOURCE_FOLDER}/ibek-support/_ansible

COPY ibek-support/ADCore/ ADCore
RUN ansible.sh ADCore

COPY ibek-support/ffmpegServer/ ffmpegServer
RUN ansible.sh ffmpegServer

# this IOC is not useful in its own right so we do not build a runtime image
# this means that testing of the modules is deferred to the detector
# specific generic IOCs that use this as a base image.