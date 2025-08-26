// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBridge {
    function handleMessage(bytes calldata message) external;
}

contract RepresentativeToken is ERC20, Ownable {
    address public controller;
    IBridge public bridge;

    event ControllerChanged(address indexed newController);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event StablecoinReceived(address indexed from, uint256 amount);
    event StablecoinSent(address indexed to, uint256 amount);
    event MessageSentToBridge(bytes message);

    modifier onlyController() {
        require(msg.sender == controller, "Not controller");
        _;
    }

    constructor(address initialController, address bridgeAddress)
        ERC20("Representative Token", "RTK")
    {
        controller = initialController;
        bridge = IBridge(bridgeAddress);
    }

    function setController(address newController) external onlyOwner {
        controller = newController;
        emit ControllerChanged(newController);
    }

    function setBridge(address bridgeAddress) external onlyOwner {
        bridge = IBridge(bridgeAddress);
    }

    function mint(address to, uint256 amount) external onlyController {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyController {
        _burn(from, amount);
        emit Burn(from, amount);
    }

    function receiveStablecoin(address from, uint256 amount) external onlyController {
        emit StablecoinReceived(from, amount);
    }

    function sendStablecoin(address to, uint256 amount) external onlyController {
        emit StablecoinSent(to, amount);
    }

    function sendMessageToBridge(bytes calldata message) external onlyController {
        bridge.handleMessage(message);
        emit MessageSentToBridge(message);
    }
}

