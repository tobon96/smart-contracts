#Compilar el contrato
npx hardhat compile

#Desplegar el contrato, añador --network para desplegar en la red que se quiera
npx hardhat deploy

# ¡IMPORTANTE! Modificar dirección del contrato en .env
#Obtener archivo .car de imágenes y metadatos
npx ipfs-car --pack metadata --output metadata.car
npx ipfs-car --pack images --output images.car

# Setup para url de metadatos
npx hardhat set-base-token-uri --base-url "https://bafybeihwviryiwq54cl6674adqt2zffw43jcdxnzap5637vfbx6y3ibe5i.ipfs.dweb.link/metadata/"

#Verificacion del contrato, tambien compila los cambios nuevos
npx hardhat verify --contract "contracts/AZNFT.sol:AZNFT" --network rinkeby 0x579D53F3817bE89c3946310c9042b959b5aF7602 "AlienzNFT" "AZNFT" "3"

#Mint con hardhat
npx hardhat mint --address 0x828b07331B767C4150b87d38b43Fd22ee975727c

#Verificar informacion del token
npx hardhat token-uri --token-id 1