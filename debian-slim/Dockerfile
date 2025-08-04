FROM debian:12-slim

# Install tools needed to install .deb files
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    nano \
    procps \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy local files into the image
# Copy .deb package and optional config file into the image
COPY deb/slurm-master_25.05.1_amd64.deb /tmp/slurm-master.deb
l
# Install the SLURM .deb file
RUN dpkg -i /tmp/slurm-master.deb || apt-get install -f -y
COPY conf/cgroup_allowed_devices_file.conf /etc/slurmica/cgroup_allowed_devices_file.conf
COPY conf/cgroup.conf /etc/slurmica/cgroup.conf
COPY conf/slurm.conf /etc/slurmica/slurm.conf
COPY conf/slurmdb.conf /etc/slurmica/slurmdb.conf

# Cleanup
RUN rm /tmp/mypackage.deb

WORKDIR /app
CMD ["/bin/bash"]