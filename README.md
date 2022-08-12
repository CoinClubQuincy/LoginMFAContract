# XDC LoginContract 
# Private Network: single hash & store value / Puppeth Private
# Public Network: Double hash & store single hash / Public Mainnet
This contract will show how a NFT token can be used as a login token 

Now A login structure like this has 2 parts, a User Login Contract & a DApp login contract. The user will launch their own contract the User Login Contract and in it they will set their password and set some meta data in the URI (Uniform Resource Identifier) identifying: ContactAddress & total Token amount. They will then Register their LoginContract to a DApp Login Contract of the DApp they are connecting to as part of their sign up process now that they are registered in the DApp Login the DApp Login Contract can pass parameters and check if user logging in is using the correct password and if they hold the correct token in their wallet by checking the status of the User Login Contract. This means all parameters get confirmed in the originally established contract allowing a secure way to login and now access a Dapp without having to surrender your password data to a 3rd party

User Login Contract: Allows users to store password credentials and generates an Access NFT that is required by anyone wanting to confirm a login with the contract.

DApp Login Contract: Allows DApp users to relay credential information to their already registered login contract for varification.





![Login Contract](https://user-images.githubusercontent.com/16103963/152666194-7ca4dfc4-515c-4502-88cf-f02553e91645.png)
![Login Graph (1)](https://user-images.githubusercontent.com/16103963/154188729-9cdf0e78-2a1c-4e36-8202-ab8856a955d6.png)

