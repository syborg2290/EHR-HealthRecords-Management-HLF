export DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer
export CORE_PEER_TLS_ENABLED=false
export ORDERER_CA=${DIR}/crypto-config/ordererOrganizations/orderer.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.orderer.example.com-cert.pem
export PEER0_ORG1_CA=${DIR}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${DIR}/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
    export CORE_PEER_MSPCONFIGPATH=${DIR}/crypto-config/ordererOrganizations/orderer.example.com/users/Admin@orderer.example.com/msp
}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${DIR}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${DIR}/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
}

presetup(){
    echo Vendoring Go dependencies ...
    go mod vendor
    echo Finished vendoring Go dependencies
}

CHANNEL_NAME="mychannel"
VERSION="1"
CC_NAME="health"
CC_SRC_PATH="../chaincode"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

approveForOrgs() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} --sequence ${VERSION}
    echo "===================== chaincode approved from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} --sequence ${VERSION}
    echo "===================== chaincode approved from org 2 ===================== "
}

commitForOrgs(){
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o orderer.example.com:7050  \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051  \
        --peerAddresses peer0.org2.example.com:7051 \
        --version ${VERSION} --sequence ${VERSION} 
}

presetup
packageChaincode
installChaincode
queryInstalled
approveForOrgs
commitForOrgs
