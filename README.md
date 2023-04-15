# Electronic Health Record System on Blockchain
---

This project leverages a hyperledger fabric (v2.0) network maintained by hospital to store a medical record of the patient securely with keeping the patient at the center. That means the medical record of any patient cannot be accessed without the consent of his/her. All the participants of the network like doctors, hospitals, pharmacies and private clinics will be given digital certificates by the Offical Medical board of the country to join the network. Doctors will able to perform all the CRUD operations on their patient records.

## Installation

### Install Docker
    > chmod +x docker.sh
    > sudo ./docker.sh
    > usermod -a -G docker ${USER}

### Install binaries
    > curl -sSL https://goo.gl/6wtTN5 | bash -s 2.3.2 1.5.0
    > export PATH=<location of fabric-samples/bin>:$PATH 

### Create artifacts and crypto
    > cd Blockchain/test-network
    > ./create-artifacts.sh

### Start Local Test Fabric Network
    > cd Blockchain/test-network
    > docker-compose up -d

### Create and join channel
    > docker exec -it cli bash
    > ./createChannel.sh

### Package and install chaincode
    > docker exec -it cli bash
    > cd $GOPATH/src/chaincode && ./createChaincode.sh

### Start Hyperledger Explorer to view blocks
    > cd explorer
    > docker-compose up -d




