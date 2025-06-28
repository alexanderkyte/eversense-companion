# Use Ubuntu as base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    openjdk-11-jdk \
    curl \
    ca-certificates \
    xvfb \
    scrot \
    imagemagick \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Download and install Garmin Connect IQ SDK
ENV SDK_VERSION=4.2.4
ENV SDK_PATH=/opt/garmin-sdk
RUN mkdir -p ${SDK_PATH} \
    && wget -O /tmp/connectiq-sdk.zip "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-${SDK_VERSION}.zip" \
    && unzip /tmp/connectiq-sdk.zip -d ${SDK_PATH} \
    && rm /tmp/connectiq-sdk.zip \
    && chmod +x ${SDK_PATH}/bin/monkeyc \
    && chmod +x ${SDK_PATH}/bin/connectiq

# Add SDK to PATH
ENV PATH="${SDK_PATH}/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy Garmin project files
COPY . .

# Build script to compile both apps for all devices
COPY docker-build.sh /usr/local/bin/docker-build.sh
RUN chmod +x /usr/local/bin/docker-build.sh

# Default command
CMD ["/usr/local/bin/docker-build.sh"]