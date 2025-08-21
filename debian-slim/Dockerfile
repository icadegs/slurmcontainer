# use rebuild.sh to remake this
# I've been running it on macos via:
# colima start --mount-type=virtiofs --mount $HOME/slurm
# docker run -h slurmofanton -it --rm -v ~/slurm:/slurm slurmcontroller bash
# note:  you might have to update ~/.colima/default/colima.yaml to make
#        The mount writable
#
# next: mariadb-install-db --user=mysql --basedir=/usr --datadir=/slurm/mysql
# mysqld --datadir=/slurm/mysql
# you need to run mysql_secure_installation  in the image


FROM debian:12
#mariadb didn't want to install on slim??
#FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install tools needed to install .deb files
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    nano \
    procps \
    gnupg \
    less \
    ca-certificates \
    vim \
    zsh \
    screen 
    
    
#    \
#    && rm -rf /var/lib/apt/lists/*

# Block any service start/stop during build (canonical Debian way)
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
 && chmod +x /usr/sbin/policy-rc.d \
 # No-op stubs for systemctl/initctl some packages call
 && ln -sf /bin/true /bin/systemctl || true \
 && ln -sf /bin/true /sbin/initctl || true

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    mariadb-server-core 

# we're going to use an external mount, but I want these here to see if I got my configs correct    
RUN mkdir -p /var/lib/mysql /run/mysqld \
 && chown -R mysql:mysql /var/lib/mysql /run/mysqld


# Clean up and re-allow services for runtime containers
RUN rm -f /usr/sbin/policy-rc.d && rm -rf /var/lib/apt/lists/*
    

# Create mount point and override datadir
#RUN mkdir -p /slurm/mysql && \
#    sed -i 's|^datadir.*|datadir = /slurm/mysql|' /etc/mysql/mariadb.conf.d/50-server.cnf
#copy the script over
COPY conf/start-mariadb.sh /usr/local/bin/start-mariadb.sh
RUN chmod +x /usr/local/bin/start-mariadb.sh


# Copy local files into the image
# Copy .deb package and optional config file into the image
COPY deb/slurm-master_25.05.1_amd64.deb /tmp/slurm-master.deb


# Create slurm user and group before installing the package
RUN groupadd -r slurm && useradd -r -g slurm -d /var/lib/slurm -s /usr/sbin/nologin slurm


# Install the SLURM .deb file
RUN dpkg -i /tmp/slurm-master.deb || apt-get install -f -y
COPY conf/cgroup_allowed_devices_file.conf /etc/slurmica/cgroup_allowed_devices_file.conf
COPY conf/cgroup.conf /etc/slurmica/cgroup.conf
COPY conf/slurm.conf /etc/slurmica/slurm.conf
COPY conf/slurmdb.conf /etc/slurmica/slurmdb.conf

# Cleanup
RUN rm /tmp/slurm-master.deb

#set the hostname
# you apparently can use -h at runtime to override this
#RUN echo "slurmofanton" > /etc/hostname \
# && hostname slurmofanton

WORKDIR /app
CMD ["/usr/local/bin/start-mariadb.sh"]
#CMD ["/bin/bash"]
