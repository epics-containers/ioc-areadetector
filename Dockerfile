ARG IMAGE_EXT

ARG BASE=4.45ec1
ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/ioc-asyn${IMAGE_EXT}-runtime:${BASE}
ARG DEVELOPER=${REGISTRY}/ioc-asyn${IMAGE_EXT}-developer:${BASE}

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# Get the current version of ibek
COPY requirements.txt requirements.txt
RUN uv pip install --upgrade -r requirements.txt

WORKDIR ${SOURCE_FOLDER}/ibek-support

COPY ibek-support/_ansible _ansible
ENV PATH=$PATH:${SOURCE_FOLDER}/ibek-support/_ansible

COPY ibek-support/ADCore/ ADCore
RUN ansible.sh ADCore

COPY ibek-support/ffmpegServer/ ffmpegServer
RUN ansible.sh ffmpegServer

##### runtime preparation stage ################################################
FROM developer AS runtime_prep

# get the products from the build stage and reduce to runtime assets only
# TODO /python is created by uv - add to apt-install-runtime-packages' defaults
RUN ibek ioc extract-runtime-assets /assets /python

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=runtime_prep /assets /

# install runtime system dependencies, collected from install.sh scripts
RUN ibek support apt-install-runtime-packages

# launch the startup script with stdio-expose to allow console connections
CMD ["bash", "-c", "${IOC}/start.sh"]
