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
npx hardhat verify --contract "contracts/AZNFT.sol:FULLNFT" --network rinkeby 0xD25D54EAfD5AF6D2E87306f03c08F8D3468E69eA "FullTest2" "FULLNFT" "https://safelips.online/assets/meta/contract.json" "https://bafkreib7xbvenpli2cyozlo33jxi4s5pd53ktonp4w3a2obdzugzlrwxiy.ipfs.dweb.link"

#Mint con hardhat
npx hardhat mint --address 0x828b07331B767C4150b87d38b43Fd22ee975727c

#Verificar informacion del token
npx hardhat token-uri --token-id 1

https://safelips.online/assets/meta/contract.json

"https://bafkreib7xbvenpli2cyozlo33jxi4s5pd53ktonp4w3a2obdzugzlrwxiy.ipfs.dweb.link"