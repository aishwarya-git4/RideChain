
# RideChain 🚗

A decentralized ride-sharing smart contract ecosystem built on Ethereum and written in Solidity, enabling secure, transparent, and automated ride payments using ERC20 tokens.


## How It Works 🔎
- Users must first register a commitment before starting any ride.
- Once the taxi arrives, users initiate the ride and the fare is held securely in the contract.
- Upon reaching the destination, the driver finalizes the ride and automatically receives the fare.
- Users can reverse a ride within 12 minutes of it starting, but a 10% penalty is applied. This penalty is sent to the public good fund, and the remaining 90% is refunded to the user.
- Each user can reverse rides a maximum of 3 times within 24 hours.
- In urgent or exceptional cases, users can perform an emergency reversal even after the 12-minute window or if the 3-reversal limit is reached. In this case, the entire fare is sent to the public good fund.


## Getting Started 🖥
    # Fork the repository
    git clone https://github.com/YOUR_USERNAME/RideChain.git
    cd on-my-way-up
    git checkout -b solve-challenges
    # Solve problems
    # Open [RemixIDE](https://remix.ethereum.org/#lang=en)->File Explorer->import files with https->paste raw URL of your RideChain contract
    git add RideChain.sol
    git commit -m "useful-message"
    git push origin solve-challenges
    # Create pull request

