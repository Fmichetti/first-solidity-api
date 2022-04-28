require('dotenv').config()
const fs = require('fs-extra');

const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET_API_KEY);

async function uploadFileToPinata(file_path) {

    const readableStreamForFile = fs.createReadStream(file_path);

    const res = await pinata.pinFileToIPFS(readableStreamForFile);

    console.log(res)

    return res.IpfsHash;

}

//exemplo de teste
// uploadFileToPinata('./testeQualquer.json')