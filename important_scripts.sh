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
npx hardhat verify --contract "contracts/AZNFT.sol:AZNFT" --network rinkeby 0x906D9fbDe4DC364C39B62C6E678c8B5982764b4D

#Mint con hardhat
npx hardhat mint --address 0xb9720BE63Ea8896956A06d2dEd491De125fD705E

#Verificar informacion del token
npx hardhat token-uri --token-id 1