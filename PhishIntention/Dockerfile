# Use Ubuntu 20.04 as base image
FROM ubuntu:20.04

# Avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive

# Install basic tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Add conda to PATH
ENV PATH="/opt/miniconda/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Clone PhishIntention
RUN git clone https://github.com/lindsey98/PhishIntention.git

# Move into project
WORKDIR /workspace/PhishIntention

# Fix line endings and permissions
RUN dos2unix setup.sh
RUN chmod +x setup.sh
RUN bash setup.sh || true

# Activate conda env by default
RUN echo "source /opt/miniconda/etc/profile.d/conda.sh && conda activate phishintention" >> ~/.bashrc

# Default command
CMD ["bash"]
