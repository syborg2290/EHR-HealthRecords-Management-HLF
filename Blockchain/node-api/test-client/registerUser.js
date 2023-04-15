const fabricCAService =require('fabric-ca-client')
const {Wallets} = require('fabric-network')
const yaml = require('js-yaml')
const fs = require('fs')

const registerUser = async (walletPath, clientName, affiliation, MSP, url) => {
    try {
        const wallet = await Wallets.newFileSystemWallet(walletPath)
        const admin = await wallet.get('admin')
        if (!admin){
            console.log("Admin is not enrolled")
            return
        }
        client = await wallet.get(clientName)
        if (client){
            console.log(`${clientName} already exists`)
            return
        }
        const ca = new fabricCAService(url)
        const provider =  wallet.getProviderRegistry().getProvider(admin.type)
        const adminUser = await provider.getUserContext(admin,'admin')
        await ca.register({affiliation: 'org1.department1',enrollmentID:clientName,role:'client',enrollmentSecret:'pw'},adminUser)
        console.log(`${clientName} has been registered`)
        
        const enrollment = await ca.enroll({enrollmentID:clientName,enrollmentSecret:'pw'},)
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: MSP,
            type: 'X.509',
        }
        await wallet.put(clientName,x509Identity)
        console.log(`Successfully enrolled user ${clientName} and imported it into the wallet`)
    } catch (error) {
        console.log(error)
    } finally{
        process.exit(1)
    }
}
const main = async () =>{
    await registerUser("./wallet/Org1", "elvis", "org1.department1", "Org1MSP", "http://localhost:7054")
    await registerUser("./wallet/Org2", "elvis", "org2.department1", "Org2MSP", "http://localhost:8054")
}
main()