#!/bin/bash

# [assignment] create your own bash script to compile Multiplier3.circom modeling after compile-HelloWorld.sh below

CIRCUIT_NAME=Multiplier3

cd contracts/circuits

mkdir $CIRCUIT_NAME

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling $CIRCUIT_NAME.circom..."

# compile circuit

circom $CIRCUIT_NAME.circom --r1cs --wasm --sym -o $CIRCUIT_NAME
snarkjs r1cs info $CIRCUIT_NAME/$CIRCUIT_NAME.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup $CIRCUIT_NAME/$CIRCUIT_NAME.r1cs powersOfTau28_hez_final_10.ptau $CIRCUIT_NAME/circuit_0000.zkey
snarkjs zkey contribute $CIRCUIT_NAME/circuit_0000.zkey $CIRCUIT_NAME/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey $CIRCUIT_NAME/circuit_final.zkey $CIRCUIT_NAME/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier $CIRCUIT_NAME/circuit_final.zkey ../${CIRCUIT_NAME}Verifier.sol

cd ../..