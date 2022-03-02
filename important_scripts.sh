#Compilar el contrato
npx hardhat compile

#Desplegar el contrato, añador --network para desplegar en la red que se quiera
npx hardhat run .\scripts\deploy_v2.js --network rinkeby

#Verificacion del contrato, tambien compila los cambios nuevos
npx hardhat verify --contract "contracts/BPSC.sol:BPSC" --network rinkeby 0x751f8c080390F2FC1b99636C56818A70d858E10d "Test BPSC" "BPSC" "https://safelips.online/assets/meta/contract.json" "https://bafkreiba26n47tgsl4wsy7f3vyj5at7iytp2slssdp2rybjsf4iz7k4kfm.ipfs.dweb.link"

npx hardhat verify --contract "contracts/AZNFT.sol:FULLNFT" --network mumbai 0x2C8599541DFf88E3234f75ffE6417d4D5F31E79A "Test BPSC" "BPSC" "https://safelips.online/assets/meta/contract.json" "https://bafkreib7xbvenpli2cyozlo33jxi4s5pd53ktonp4w3a2obdzugzlrwxiy.ipfs.dweb.link"

# ¡IMPORTANTE! Modificar dirección del contrato en .env
#Obtener archivo .car de imágenes y metadatos
npx ipfs-car --pack metadata --output metadata.car
npx ipfs-car --pack images --output images.car

# Setup para url de metadatos
npx hardhat set-base-token-uri --base-url "https://bafybeihisekztoxvivoj2ip5m6e74zb55d5uvy6q5u3yc6ydughi6rk4gy.ipfs.dweb.link/metadata/"

https://safelips.online/assets/meta/contract.json

"https://bafkreib7xbvenpli2cyozlo33jxi4s5pd53ktonp4w3a2obdzugzlrwxiy.ipfs.dweb.link"