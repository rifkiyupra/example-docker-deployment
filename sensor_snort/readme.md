# Mata Elang Sensor Snort
---

Mata Elang Sensor Snort is an open-source network intrusion detection system (NIDS) that provides real-time traffic analysis and packet logging. It is designed to detect and prevent network attacks and security threats. Mata Elang Sensor uses the Snort engine to analyze network traffic and generate alerts for suspicious activity.

## Components
Mata Elang Sensor Snort consists of the following components:
- Snort Engine: Analyzes network traffic and generates alerts for suspicious activity.
- Snort Parser: Parses Snort alerts and logs into a readable format and sends them to the Mata Elang Defense Center.

## Features
Mata Elang Sensor Snort provides the following features:
- Real-time traffic analysis
- Packet logging
- Alert generation for suspicious activity
- Integration with Mata Elang Defense Center

## Pre-requisites
- [Docker and Docker Compose](https://docs.docker.com/get-docker/)
- [Promiscuous Mode](https://www.blumira.com/glossary/promiscuous-mode) enabled on the network interface for packet capture. [optional]

## Installation
1. **Preparation**: Clone the repository and navigate to the `sensor_snort` directory.
    ```bash
    git clone https:// && cd sensor_snort
    ```

2. **Configuration**: Copy the example configuration file and update the configuration settings.
    ```bash
    cp .env.example .env
    ```

    Configurations required to be updated:
    - `NETWORK_INTERFACE`: The network interface to capture packets. (e.g., `eth0`)
    - `MES_CLIENT_SERVER`: The Mata Elang Defense Center server address. (e.g., `172.17.0.1`). Leave it as it is if you are deploying the Mata Elang Defense Center on the same machine.
    - `MES_CLIENT_PORT`: The Mata Elang Defense Center server port. (e.g., `50051`). Leave it as it is if you are deploying the Mata Elang Defense Center on the same machine.
    - `MES_CLIENT_SENSOR_ID`: The Mata Elang Sensor ID. (e.g., `snort-1`)
    

3. **Pull Images**: Pull the required Docker images.
    ```bash
    docker-compose pull
    ```

4. **Start Services**: Start the Docker services.
    ```bash
    docker-compose up -d
    ```

## Usage

### Defining custom rules
You can create custom rules for Snort by adding them to [custom.rules](custom.rules) file. The rules should be written in the Snort rule format.
Then, restart the Snort service to apply the new rules.
```bash
docker-compose restart snort
```
### Using Compresed Snort Rules
You can use compressed Snort rules collected from the snort.org website. To use compressed rules, download the rules from the [Snort website](https://www.snort.org/downloads/community/community-rules.tar.gz) and place the compressed file in the `rules` directory. 

Adjust the `SNORT_COMPRESSED_RULES_FILE_PATH` in the `.env` file to point to the compressed rules file.
```bash
SNORT_COMPRESSED_RULES_FILE_PATH=/tmp/rules/community-rules.tar.gz
```

> **Note**: 
> - The compressed rules file should be in the `tar.gz` format.
> - The `SNORT_COMPRESSED_RULES_FILE_PATH` should point to `/tmp/rules` directory and follow the format `/tmp/rules/<compressed_file_name>.tar.gz`.  This is based on the default configuration in [compose.yml line 24](compose.yml#L24).


Then, restart the Snort service to apply the new rules.
```bash
docker-compose restart snort
```

