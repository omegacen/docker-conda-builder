FROM centos:7

LABEL maintainer="teake.nutma@gmail.com"
LABEL description="Builds linux-64 conda packages. CentOS 7 + miniconda + conda-build."

# Configuration options.
ARG CONDA_PREFIX=/opt/conda
ARG CONDA_FORGE_PINNING=2022.02.15.10.00.06

# Set a UTF-8 locale. Useful for running Python 3 programs.
ENV LANG en_US.utf-8
ENV LC_ALL en_US.utf-8

# Fetch updates and install dependencies.
# bzip2 is required for installing conda.
# git and openssh-clients are required for cloning git repositories in recipes.
# patch is required for applying patches in recipes.
RUN yum -y update \
    && yum -y install bzip2 git openssh-clients patch \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install the latest Miniconda with Python 3 and update everything.
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
    && sh miniconda.sh -b -p ${CONDA_PREFIX} \
    && rm miniconda.sh \
    && ${CONDA_PREFIX}/bin/conda config --set show_channel_urls True \
    # There are just too many packages that clobber paths. So don't set to
    # path_conflict to `prevent` -- else we'll be overriding this setting to
    # `warn` in lots of projects.
    && ${CONDA_PREFIX}/bin/conda config --set path_conflict warn \
    && ${CONDA_PREFIX}/bin/conda config --set notify_outdated_conda false \
    # Solely use conda-forge.
    && ${CONDA_PREFIX}/bin/conda config --add channels conda-forge \
    && ${CONDA_PREFIX}/bin/conda config --remove channels defaults \
    # Set the variant file to the one from conda-forge-pinning.
    # The conda-forge-pinning package (installed below) puts its variant
    # file in $CONDA_PREFIX. Pointing conda-build to that variant file
    # ensures we're compiling against libraries compatible with the wider
    # conda-forge ecosystem.
    && ${CONDA_PREFIX}/bin/conda config --set conda_build.config_file ${CONDA_PREFIX}/conda_build_config.yaml \
    # Explicitly fail when overlinking shared libraries. This will prevent dynamic library linking issues,
    # and will be the default setting in conda build 4.0 anyway.
    && ${CONDA_PREFIX}/bin/conda config --set conda_build.error_overlinking True \
    # Update and install packages.
    && ${CONDA_PREFIX}/bin/conda update --yes --all \
    && ${CONDA_PREFIX}/bin/conda install --yes conda-build conda-verify conda-libmamba-solver mamba boa coverage coverage-fixpaths conda-forge-pinning=${CONDA_FORGE_PINNING} \
    && ${CONDA_PREFIX}/bin/conda clean -tipy \
    && ${CONDA_PREFIX}/bin/conda-build purge-all \
    # conda init wants to edit ~/.bashrc, but if that doesn't exist it fails.
    && touch ~/.bashrc \
    && ${CONDA_PREFIX}/bin/conda init bash

# Add a shell script that activates conda ...
COPY entrypoint.sh /opt/docker/bin/entrypoint.sh
# ... and make it the Docker entrypoint so that conda is available when we run a container.
ENTRYPOINT [ "/bin/bash", "/opt/docker/bin/entrypoint.sh" ]
# Provide a default command (`bash`), which will start if the user doesn't specify one.
CMD [ "/bin/bash" ]
