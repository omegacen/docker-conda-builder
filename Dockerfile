FROM centos:7

LABEL maintainer="teake.nutma@gmail.com"
LABEL description="Builds linux-64 conda packages. CentOS 7 + dev tools + miniconda."

# Set a UTF-8 locale. Useful for running Python 3 programs.
ENV LANG=en_US.utf-8 \
    LC_ALL=en_US.utf-8

# Fetch updates and install GCC and whatnot.
RUN yum -y update && yum -y group install "Development Tools" && yum clean all
# Install the latest Miniconda with Python 3 and update everything.
RUN curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda config --set show_channel_urls True && \
    /opt/conda/bin/conda update --yes --all && \
    /opt/conda/bin/conda install --yes conda-build conda-verify setuptools && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Add a shell script that activates conda ...
COPY entrypoint.sh /opt/docker/bin/entrypoint.sh
# ... and make it the Docker entrypoint so that conda is available when we run a container.
ENTRYPOINT [ "/bin/bash", "/opt/docker/bin/entrypoint.sh" ]
# Provide a default command (`bash`), which will start if the user doesn't specify one.
CMD [ "/bin/bash" ]
