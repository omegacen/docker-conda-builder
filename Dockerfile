FROM centos:7

LABEL maintainer="teake.nutma@gmail.com"
LABEL description="Builds linux-64 conda packages. CentOS 7 + dev tools + miniconda."

# Fetch some updates first.
RUN yum -y update && yum clean all
# Install GCC and whatnot.
RUN yum -y group install "Development Tools" && yum clean all
# Install the latest Miniconda with Python 3 and update everything.
RUN curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda config --set show_channel_urls True && \
    /opt/conda/bin/conda update --yes --all && \
    /opt/conda/bin/conda install --yes conda-build conda-verify setuptools && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Provide a default command (`bash`), which will start if the user doesn't specify one.
CMD [ "/bin/bash" ]
