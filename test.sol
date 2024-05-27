// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ContractA {
    struct Product {
        string productID;
        string name;
        uint256 price;
        uint256 stock;
    }

    mapping(address => Product[]) private products;

    event ProductAdded(address indexed user, Product product);
    event ProductSold(address indexed seller, address indexed buyer, string productID, uint256 quantity, uint256 newStock);

    function addProduct(
        string memory _id,
        string memory _name,
        uint256 _price,
        uint256 _stock
    ) public {
        Product memory newProduct = Product({
            productID: _id,
            name: _name,
            price: _price,
            stock: _stock
        });

        products[msg.sender].push(newProduct);
        emit ProductAdded(msg.sender, newProduct);
    }

    function getUserProducts(address _user)
        public
        view
        returns (Product[] memory)
    {
        return products[_user];
    }

    function r(string memory w) internal view returns (bytes memory) {
        uint256 l = bytes(w).length - 1;
        if (l < 3) {
            bytes memory wBytes = bytes(w);
            return wBytes;
        } else {
            bytes memory wBytes = bytes(w);
            bytes memory result = new bytes(l + 1);
            result[0] = wBytes[0];
            for (uint256 i = 1; i < l; i++) {
                result[i] = wBytes[i];
            }
            for (uint256 i = 1; i < l - 1; i++) {
                uint256 j = i +
                    (uint256(keccak256(abi.encodePacked(block.prevrandao))) %
                        (l - i));
                (result[i], result[j]) = (result[j], result[i]);
            }
            result[l] = wBytes[l];
            return result;
        }
    }

    function random(uint256 number, uint256 counter)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender,
                        counter
                    )
                )
            ) % number;
    }

    function generateRandomString(uint256 length)
        public
        view
        returns (string memory)
    {
        require(length >= 1 && length <= 14, "Length must be between 1 and 14");
        bytes memory randomWord = new bytes(length);

        bytes memory chars = r(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        );

        for (uint256 i = 0; i < length; i++) {
            randomWord[i] = chars[random(chars.length, i)];
        }
        return string(randomWord);
    }

    function sellProduct(address seller, string memory _productID, uint256 quantity) public {
        Product[] storage userProducts = products[seller];
        for (uint256 i = 0; i < userProducts.length; i++) {
            if (keccak256(bytes(userProducts[i].productID)) == keccak256(bytes(_productID))) {
                require(userProducts[i].stock >= quantity, "Insufficient stock");
                userProducts[i].stock -= quantity;
                emit ProductSold(seller, msg.sender, _productID, quantity, userProducts[i].stock);
                break;
            }
        }
    }
}

contract ContractB {
    ContractA public contractA;
    struct ProductB {
        string productID;
        string name;
        uint256 price;
        uint256 stock;
    }

    mapping(address => ProductB[]) private userProductsB;
    mapping(address => mapping(string => bool)) private productExistsB;

    event ProductSoldB(address indexed seller, string productID, uint256 quantity, uint256 newStock);

    constructor(address _contractAAddress) {
        contractA = ContractA(_contractAAddress);
    }

    function getProductBAdded() public view returns (ProductB[] memory) {
        ProductB[] memory allProducts = new ProductB[](
            userProductsB[msg.sender].length
        );
        for (uint256 i = 0; i < userProductsB[msg.sender].length; i++) {
            allProducts[i] = userProductsB[msg.sender][i];
        }

        return allProducts;
    }

    function requestProduct(string memory _ID, uint256 _stockWant)
        internal
        view
        returns (bool)
    {
        ContractA.Product[] memory userProducts = contractA.getUserProducts(
            msg.sender
        );
        for (uint256 i = 0; i < userProducts.length; i++) {
            if (
                keccak256(bytes(userProducts[i].productID)) ==
                keccak256(bytes(_ID))
            ) {
                if (userProducts[i].stock >= _stockWant) {
                    return true;
                } else {
                    return false; // Insufficient stock
                }
            }
        }
        return false; // Product not found
    }

    function getProductNameByID(string memory _ID)
        internal
        view
        returns (string memory)
    {
        ContractA.Product[] memory userProducts = contractA.getUserProducts(
            msg.sender
        );
        for (uint256 i = 0; i < userProducts.length; i++) {
            if (
                keccak256(bytes(userProducts[i].productID)) ==
                keccak256(bytes(_ID))
            ) {
                return userProducts[i].name;
            }
        }
        return "";
    }

    function addProductB(
        string memory _ID,
        uint256 _price,
        uint256 _stock
    ) public {
        require(
            !productExistsB[msg.sender][_ID],
            "Product already exists in Contract B"
        );

        require(requestProduct(_ID, _stock), "Product Not Found");
        ContractA.Product[] memory productsA = contractA.getUserProducts(msg.sender);
        bool productFound = false;
        for (uint256 i = 0; i < productsA.length; i++) {
            if (keccak256(bytes(productsA[i].productID)) == keccak256(bytes(_ID))) {
                require(productsA[i].stock >= _stock, "Insufficient stock");
                productFound = true;
                contractA.sellProduct(msg.sender, _ID, _stock);
                break;
            }
        }
        require(productFound, string(abi.encodePacked("Product not found: ", _ID)));
        userProductsB[msg.sender].push(
            ProductB(_ID, getProductNameByID(_ID), _price, _stock)
        );
        productExistsB[msg.sender][_ID] = true;
    }

    function removeProductByID(string memory _productID) public {
        ProductB[] storage userProducts = userProductsB[msg.sender];

        for (uint256 i = 0; i < userProducts.length; i++) {
            if (compareStrings(userProducts[i].productID, _productID)) {
                for (uint256 j = i; j < userProducts.length - 1; j++) {
                    userProducts[j] = userProducts[j + 1];
                }
                userProducts.pop();
                productExistsB[msg.sender][_productID] = false;
                break;
            }
        }
    }

    function getProduct(address _owner) public view returns (ContractA.Product[] memory) {
        return contractA.getUserProducts(_owner);
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
