// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

/** 
*   Token Name: ZoomArt Token
*   Symbol: ZMAT
*   Decimal: 18
*/ 

contract ZMAT is ERC20, Ownable, ERC20Burnable, ReentrancyGuard {
    address public pegContract;
    address public treasurer;

    // Multipliers for minting and burning
    uint256 public mintMultiplier;
    uint256 public treasurerPercentage;
    uint256 public burnMultiplier;
    uint256 public baseMultiplier;

    // Event declarations
    event PegContractUpdated(address indexed newPegContract);
    event TreasurerUpdated(address indexed newTreasurer);
    event MintMultiplierUpdated(uint256 newMultiplier);
    event TreasurerPercentageUpdated(uint256 newPercentage);
    event BurnMultiplierUpdated(uint256 newMultiplier);
    event TokensMinted(address indexed to, uint256 ownerAmount, uint256 treasurerAmount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor(uint256 initMintMultiplier, uint256 initTreasurerPercentage, uint256 initBurnMultiplier, uint256 initBaseMultiplier) ERC20("ZoomArt Token", "ZMAT") {
        require(initMintMultiplier > 0 , "Mint multiplier must be greater than zero");
        require(initTreasurerPercentage > 0 , "Treasurer percentage must be greater than zero");
        require(initBurnMultiplier > 0 , "Burn multiplier must be greater than zero");
        require(initBaseMultiplier > 0, "Base multiplier must be greater than zero");

        mintMultiplier = initMintMultiplier;
        treasurerPercentage = initTreasurerPercentage;
        burnMultiplier = initBurnMultiplier;
        baseMultiplier = initBaseMultiplier;
    }

    function setPegContract(address _pegContract) external onlyOwner {
        require(_pegContract != address(0), "New address is the zero address");
        pegContract = _pegContract;
        emit PegContractUpdated(_pegContract); 
    }

    function setTreasurer(address newTreasurer) external onlyOwner {
        require(newTreasurer != address(0), "New address is the zero address");
        treasurer = newTreasurer;
        emit TreasurerUpdated(newTreasurer); 
    }

    function setMintMultiplier(uint256 newMultiplier) external onlyOwner {
        require(newMultiplier > 0, "Multiplier must be greater than zero");
        mintMultiplier = newMultiplier;
        emit MintMultiplierUpdated(newMultiplier);
    }

    function setTreasurerPercentage(uint256 newPercentage) external onlyOwner {
        require(newPercentage > 0 , "Percentage must be greater than zero");
        treasurerPercentage = newPercentage;
        emit TreasurerPercentageUpdated(newPercentage);
    }

    function setBurnMultiplier(uint256 newMultiplier) external onlyOwner {
        require(newMultiplier > 0 , "Multiplier must be greater than zero");
        burnMultiplier = newMultiplier;
        emit BurnMultiplierUpdated(newMultiplier);
    }

    function pegContractMint(uint256 amount) external nonReentrant {
        require(msg.sender == pegContract, "Only the peg contract can mint");
        require(treasurer != address(0), "Treasurer address not set");

        uint256 ownerAmount = (amount * mintMultiplier) / baseMultiplier;
        uint256 treasurerAmount = (ownerAmount * treasurerPercentage) / baseMultiplier;

        _mint(owner(), ownerAmount);
        _mint(treasurer, treasurerAmount);

        emit TokensMinted(owner(), ownerAmount, treasurerAmount); 
    }

    function pegContractBurn(uint256 amount) external nonReentrant {
        require(msg.sender == pegContract, "Only the peg contract can burn");
        uint256 burnAmount = (amount * burnMultiplier) / baseMultiplier;

        _burn(owner(), burnAmount);
        emit TokensBurned(owner(), burnAmount); 
    }

    function mint(uint256 amount) public onlyOwner nonReentrant {
        require(treasurer != address(0), "Treasurer address not set");

        uint256 ownerAmount = (amount * mintMultiplier) / baseMultiplier;
        uint256 treasurerAmount = (ownerAmount * treasurerPercentage) / baseMultiplier;

        _mint(owner(), ownerAmount);
        _mint(treasurer, treasurerAmount);

        emit TokensMinted(owner(), ownerAmount, treasurerAmount); 
    }

    function burn(uint256 amount) public override onlyOwner nonReentrant {
        uint256 burnAmount = (amount * burnMultiplier) / baseMultiplier;

        _burn(owner(), burnAmount);
        emit TokensBurned(owner(), burnAmount); 
    }

    function getMintMultiplier() external view returns (uint256) {
        return mintMultiplier;
    }

    function getTreasurerPercentage() external view returns (uint256) {
        return treasurerPercentage;
    }

    function getBurnMultiplier() external view returns (uint256) {
        return burnMultiplier;
    }

    function getBaseMultiplier() external view returns (uint256) {
        return baseMultiplier;
    }
}
