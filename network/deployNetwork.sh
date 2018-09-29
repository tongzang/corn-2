#!/bin/bash
# this script based on basic network on fabric repository

CC_SRC_PATH=github.com/demo
LANGUAGE="golang" # node if chaincode written by nodejs

# clear old chaincode images
echo "clear old chaincode images .."
docker rmi $(docker images | grep dev-peer | awk '{print $3}')

# copy chaincode path to chaincode in fabric
echo "copy chaincode to docker mounted path - fabric .."
rm -Rf ../fabric/chaincode/demo
cp -Rf demo ../fabric/chaincode
ls ../fabric/chaincode | grep demo

# start fabric network with cli
echo "start hyperledger fabric network .."
cd ../fabric/basic-network
./start.sh
docker-compose up -d cli
cd -

# install chaincode
echo "install chaincode .."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n demo -v 1.0 -p "$CC_SRC_PATH" -l "$LANGUAGE"

# instantiate chaincode
# -P is endorsement policy
echo "instantiate chaincode .."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n demo -l "$LANGUAGE" -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
sleep 3

echo "chaincode deployment completed !!!"
