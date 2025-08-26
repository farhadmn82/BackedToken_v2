// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title BackedGold
/// @notice ERC20 token representing a backed asset. Only a designated
/// controller can mint or burn tokens. The controller is expected to
/// coordinate with a bridge contract that holds the real asset.
interface IBridge {
    function handleBridgeMessage(bytes calldata message) external;
}

contract BackedGold is ERC20, Ownable {
    /// @notice Address allowed to mint/burn and interact with the bridge.
    address public controller;

    /// @notice Bridge contract that receives purchase/sell messages.
    address public bridge;

    event ControllerUpdated(address indexed newController);
    event BridgeUpdated(address indexed newBridge);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event StablecoinReceived(address indexed from, uint256 amount);
    event StablecoinSent(address indexed to, uint256 amount);
    event MessageSentToBridge(address indexed bridge, bytes message);

    modifier onlyController() {
        require(msg.sender == controller, "Not controller");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address controller_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        controller = controller_;
    }

    /// @notice Update the controller address. Only owner may call.
    function setController(address controller_) external onlyOwner {
        controller = controller_;
        emit ControllerUpdated(controller_);
    }

    /// @notice Update the bridge contract address. Only owner may call.
    function setBridge(address bridge_) external onlyOwner {
        bridge = bridge_;
        emit BridgeUpdated(bridge_);
    }

    /// @notice Mint new tokens to `to`.
    function mint(address to, uint256 amount) external onlyController {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /// @notice Burn tokens from `from`.
    function burn(address from, uint256 amount) external onlyController {
        _burn(from, amount);
        emit Burn(from, amount);
    }

    /// @notice Mint tokens when stablecoins are deposited into the bridge.
    function receiveStablecoin(address to, uint256 amount) external onlyController {
        _mint(to, amount);
        emit StablecoinReceived(to, amount);
    }

    /// @notice Burn tokens when stablecoins are withdrawn from the bridge.
    function sendStablecoin(address from, uint256 amount) external onlyController {
        _burn(from, amount);
        emit StablecoinSent(from, amount);
    }

    /// @notice Send a message to the backing bridge contract.
    /// @param message Encoded information about buy/sell operations.
    function sendMessageToBridge(bytes calldata message) external onlyController {
        require(bridge != address(0), "Bridge not set");
        IBridge(bridge).handleBridgeMessage(message);
        emit MessageSentToBridge(bridge, message);
    }
}

