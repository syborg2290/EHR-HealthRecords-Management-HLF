const {Wallets} = require('fabric-network')
const fabricCAService =require('fabric-ca-client')
const fs = require('fs')
const { MSPID_SCOPE_ALLFORTX } = require('fabric-network/lib/impl/event/defaulteventhandlerstrategies')
const Org1WalletPath = './wallet/Org1'
const Org2WalletPAth = './wallet/Org2'

const enrollAdmin = async (walletPath, MSP, url) => {
    try {
        const wallet = await Wallets.newFileSystemWallet(walletPath)
        const admin = await wallet.get('admin')
        if (admin){
            console.log("Admin is already enrolled")
            return
        }

        const ca = new fabricCAService(url)
        
        const enrollment = await ca.enroll({enrollmentID:"admin",enrollmentSecret:'adminpw'},)
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: MSP,
            type: 'X.509',
        }
        await wallet.put("admin",x509Identity)
        console.log(`Successfully enrolled admin and imported it into the wallet`)
    } catch (error) {
        console.log(error)
    }
}
const main = async ()=>{
    await enrollAdmin(Org1WalletPath, "Org1MSP", "http://localhost:7054")
    await enrollAdmin(Org2WalletPath, "Org2MSP", "http://localhost:8054")
}
main()