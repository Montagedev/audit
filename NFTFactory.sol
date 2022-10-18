// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./NFTcontract.sol";

contract Factory {
    event ContractDeployed(address owner, address clone);

    function genesis(
        address _owner,
        string memory _baseURI,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _maxPublicMint,
        uint256 _publicSalePrice,
        address _collectAddress
    ) external returns (address) {
        NFTcontract newNFT = new NFTcontract(
            _owner,
            _baseURI,
            _tokenName,
            _tokenSymbol,
            _maxPublicMint,
            _publicSalePrice,
            _collectAddress
        );

        emit ContractDeployed(msg.sender, address(newNFT));
        return address(newNFT);
    }
}
