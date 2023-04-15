export CORE_PEER_TLS_ENABLED=false
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/orderer.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.orderer.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051  
}

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:7051 
}

createChannel(){
    echo "###########Create channel###############"
    setGlobalsForPeer0Org1
    
    # peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME \
    # --ordererTLSHostnameOverride orderer.example.com \
    # -f ./artifacts/${CHANNEL_NAME}.tx --outputBlock ./artifacts/${CHANNEL_NAME}.block \
    # --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME \
    -f ./artifacts/${CHANNEL_NAME}.tx --outputBlock ./artifacts/${CHANNEL_NAME}.block \
    --cafile $ORDERER_CA
}

joinChannel(){
    echo "###########Join channel Peer0 Org1###############"
    setGlobalsForPeer0Org1
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
    echo "###########Join channel Peer0 Org2###############"
    setGlobalsForPeer0Org2
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
}

updateAnchorPeers(){
    setGlobalsForPeer0Org1
    # peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --cafile $ORDERER_CA

    setGlobalsForPeer0Org2
    # peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --cafile $ORDERER_CA

}

createChannel
joinChannel
# updateAnchorPeers