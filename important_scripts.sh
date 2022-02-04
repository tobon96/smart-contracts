#Compilar el contrato
npx hardhat compile

#Desplegar el contrato, añador --network para desplegar en la red que se quiera
npx hardhat deploy

# ¡IMPORTANTE! Modificar dirección del contrato en .env
#Obtener archivo .car de imágenes y metadatos
npx ipfs-car --pack metadata --output metadata.car
npx ipfs-car --pack images --output images.car

# Setup para url de metadatos
npx hardhat set-base-token-uri --base-url "https://bafybeihisekztoxvivoj2ip5m6e74zb55d5uvy6q5u3yc6ydughi6rk4gy.ipfs.dweb.link/metadata/"

#Verificacion del contrato, tambien compila los cambios nuevos
npx hardhat verify --contract "contracts/AZNFT.sol:AZNFT" --network rinkeby 0x83f396719F162E8F17cD45BbD089902942303a6b "AlienzNFT" "AZNFT" "100"

#Mint con hardhat
npx hardhat mint --address 0x828b07331B767C4150b87d38b43Fd22ee975727c

#Verificar informacion del token
npx hardhat token-uri --token-id 1

https://safelips.online/assets/meta/contract.json