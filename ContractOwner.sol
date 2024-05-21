// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract SCMOwner {
    address payable private SCMowner;
    uint256 private totalSuppliersCounter;
    uint256 private totalManufacturersCounter;
    uint256 private totalDistributorsCounter;
    uint256 private totalRetailersCounter;

    constructor() {
        SCMowner = payable(msg.sender);
    }

    event RegisterSupplier(address indexed _supplier, Supplier supplier);
    event UpdateSupplierDetails(
        address indexed _supplier,
        uint256 indexed _supplierIndex
    );
    event RegisterManufacturer(
        address indexed _manufacturer,
        Manufacturer manufacturer
    );
    event UpdateManufacturerDetails(
        address indexed _manufacturer,
        uint256 indexed _manufacturerIndex
    );

    event VerifyManufacturer(
        address indexed _manufacturer,
        uint256 indexed _manufacturerID,
        VerifiedManufacturer VM
    );
    event RegisterMedicine(address indexed _medicine, Medicine medicine);
    event VerifySupplier(
        address indexed _supplier,
        uint256 indexed _supplierID,
        VerifiedSupplier verifiedSuppliers
    );
    event RegisterDistributor(
        address indexed _distributor,
        Distributor distributor
    );
    event UpdateDistributorDetails(
        address indexed _distributor,
        uint256 indexed _distributorIndex
    );
    event VerifyDistributor(
        address indexed _distributor,
        uint256 _distributorID,
        VerifiedDistributor VD
    );
    event RegisterRetailer(address indexed _retailer, Retailer retailer);
    event UpdateRetailerDetails(
        address indexed _retailer,
        uint256 indexed _retailerIndex
    );
    event VerifyRetailer(
        address indexed _retailer,
        uint256 _retailerID,
        VerifiedRetailer VR
    );

    struct Supplier {
        address supplierAddress;
        string supplierName;
        string contactInformation;
        string location;
        ProductOffered[] productOffered;
    }
    enum ProductOffered {
        RawMaterials,
        Components,
        Equipments,
        Goods,
        Services
    }
    struct VerifiedSupplier {
        address supplierAddress;
        string supplierName;
        string contactInformation;
        string location;
        ProductOffered[] productOffered;
        bool approval;
        string supplierID;
    }
    struct Manufacturer {
        address manufacturerAddress;
        string manufacturerName;
        string location;
    }
    struct VerifiedManufacturer {
        address manufacturerAddress;
        string manufacturerName;
        string location;
        bool approval;
        string manufacturerID;
    }
    struct Distributor {
        address distributorAddress;
        string distributorName;
        string location;
    }
    struct VerifiedDistributor {
        address distributorAddress;
        string distributorName;
        string location;
        string distributorID;
    }
    struct Retailer {
        address retailerAddress;
        string retailerName;
        string location;
    }
    struct VerifiedRetailer {
        address retailerAddress;
        string retailerName;
        string location;
        string retailerID;
    }
    struct Medicine {
        MedicineType med;
        string medicineID;
        string medicineName;
        string medicineInfo;
        Stage currentStage;
        string supplierID;
    }
    enum MedicineType {
        Liquid,
        Tablet,
        Capsules,
        Injections
        // https://www.gosh.nhs.uk/conditions-and-treatments/medicines-information/types-medicines/
    }
    enum Stage {
        Initial,
        RawMaterial, //supplier
        Manufacture,
        Distributor,
        Retailer,
        Sold
    }

    mapping(address => Supplier[]) internal registeredSuppliers;
    mapping(address => Manufacturer[]) internal registeredManufacturers;
    mapping(address => Distributor[]) internal registeredDistributors;
    mapping(address => Retailer[]) internal registeredRetailers;
    mapping(address => VerifiedSupplier[]) internal verifiedSuppliers;
    mapping(address => VerifiedManufacturer[]) internal verifiedManufacturers;
    mapping(address => VerifiedDistributor[]) internal verifiedDistributors;
    mapping(address=> VerifiedRetailer[]) internal verifiedRetailers;

    mapping(address => Medicine[]) internal registeredMedicines;

    modifier onlyOwner() {
        require(
            msg.sender == SCMowner,
            "Only contract owner can perform this action"
        );
        _;
    }

    function setTotalManufacturersCounter() internal {
        totalManufacturersCounter++;
    }

    function setTotalSuppliersCounter() internal {
        totalSuppliersCounter++;
    }

    function setTotalDistributorsCounter() internal {
        totalDistributorsCounter++;
    }

    function getTotalSuppliersCounter() internal view returns (uint256) {
        return totalSuppliersCounter;
    }

    function getTotalManufacturersCounter() internal view returns (uint256) {
        return totalManufacturersCounter;
    }

    function getTotalDistributorsCounter() internal view returns (uint256) {
        return totalDistributorsCounter;
    }

    function setTotalRetailersCounter() internal {
        totalRetailersCounter++;
    }

    function getTotalRetailersCounter() internal view returns (uint256) {
        return totalRetailersCounter;
    }

    function getOwnerAddress() external view returns (address) {
        return SCMowner;
    }

    function generateRandomNumber(uint256 _length, uint256 x)
        internal
        view
        returns (string memory)
    {
        bytes memory randomNum = new bytes(_length);
        bytes memory chars;
        if (x >= 0 && x <= 4) {
            if (x == 0) {
                chars = "9412536874";
            } else if (x == 1) {
                chars = "4261579803";
            } else if (x == 2) {
                chars = "5731864792";
            } else if (x == 3) {
                chars = "4732169582";
            } else if (x == 4) {
                chars = "9421837501";
            }
            for (uint256 i = 0; i < _length; i++) {
                randomNum[i] = chars[random(10, i)];
            }
            return string(randomNum);
        }
        return "";
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

    // Random String Generator (Max length 14)
    function generateRandomString(uint256 length, uint256 x)
        internal
        view
        returns (string memory)
    {
        require(length >= 1 && length <= 14, "Length must be between 1 and 14");
        bytes memory randomWord = new bytes(length);
        bytes memory chars;

        if (x == 0) {
            chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        } else if (x == 1) {
            chars = "9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba";
        } else if (x == 2) {
            chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        } else if (x == 3) {
            chars = "zyxwvutsrqponmlkjihgfedcba9876543210ZYXWVUTSRQPONMLKJIHGFEDCBA";
        } else if (x == 4) {
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        } else {
            return "";
        }

        for (uint256 i = 0; i < length; i++) {
            randomWord[i] = chars[random(chars.length, i)];
        }
        return string(randomWord);
    }

    //Generate Supplier ID
    function generateSupplierID(ProductOffered[] memory _prodOffer)
        internal
        view
        returns (string memory)
    {
        bytes memory productOfferedBytes = bytes(
            getProductOfferedAsString(_prodOffer)
        );
        bytes1 firstLetterPO = productOfferedBytes[0];
        return
            string(
                abi.encodePacked(
                    "SUP",
                    firstLetterPO,
                    generateRandomNumber(3, 0),
                    "-",
                    generateRandomString(7, 0)
                )
            );
    }

    function getProductOfferedAsString(ProductOffered[] memory _prodOffer)
        internal
        pure
        returns (string memory)
    {
        string memory productString;
        for (uint256 i = 0; i < _prodOffer.length; i++) {
            if (i > 0) {
                productString = string(abi.encodePacked(productString, ", "));
            }
            if (_prodOffer[i] == ProductOffered.RawMaterials) {
                productString = string(
                    abi.encodePacked(productString, "Raw Materials")
                );
            } else if (_prodOffer[i] == ProductOffered.Components) {
                productString = string(
                    abi.encodePacked(productString, "Components")
                );
            } else if (_prodOffer[i] == ProductOffered.Equipments) {
                productString = string(
                    abi.encodePacked(productString, "Equipments")
                );
            } else if (_prodOffer[i] == ProductOffered.Goods) {
                productString = string(
                    abi.encodePacked(productString, "Goods")
                );
            } else if (_prodOffer[i] == ProductOffered.Services) {
                productString = string(
                    abi.encodePacked(productString, "Services")
                );
            }
        }
        return productString;
    }

    function generateManufacturerID() internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "MA",
                    generateRandomNumber(3, 1),
                    "-",
                    generateRandomString(7, 1)
                )
            );
    }

    function generateDistributorID() internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "DS",
                    generateRandomNumber(3, 2),
                    "-",
                    generateRandomString(7, 2)
                )
            );
    }

    function generateRetailerID() internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "RT",
                    generateRandomNumber(3, 3),
                    "-",
                    generateRandomString(7, 3)
                )
            );
    }

    function generateMedicineID(MedicineType _med)
        internal
        view
        returns (string memory)
    {
        bytes memory stringBytes = bytes(getMedicineTypeAsString(_med));
        bytes1 firstLetterPO = stringBytes[0];
        return
            string(
                abi.encodePacked(
                    "M",
                    firstLetterPO,
                    generateRandomNumber(3, 4),
                    "-",
                    generateRandomString(7, 4)
                )
            );
    }

    function getMedicineTypeAsString(MedicineType _medicine)
        internal
        pure
        returns (string memory)
    {
        if (_medicine == MedicineType.Liquid) {
            return "Liquid";
        }
        if (_medicine == MedicineType.Tablet) {
            return "Tablet";
        }
        if (_medicine == MedicineType.Capsules) {
            return "Capsule";
        }
        if (_medicine == MedicineType.Injections) {
            return "Injections";
        } else {
            return "Unknown";
        }
    }

    function getMedicineStageAsString(Stage _currentStage)
        internal
        pure
        returns (string memory)
    {
        if (_currentStage == Stage.Initial) {
            return "Initial Stage";
        }
        if (_currentStage == Stage.RawMaterial) {
            return "Raw Material Stage";
        }
        if (_currentStage == Stage.Manufacture) {
            return "Manufacture Stage";
        }
        if (_currentStage == Stage.Distributor) {
            return "Distributor Stage";
        }
        if (_currentStage == Stage.Retailer) {
            return "Retailer";
        }
        if (_currentStage == Stage.Sold) {
            return "SOLD";
        } else {
            return "Unknown";
        }
    }

    function getIDAsString(string memory _ID)
        internal
        pure
        returns (string memory)
    {
        return string(_ID);
    }
}

contract SupplierOperation is SCMOwner {
    string[] prodOffer = new string[](2);

    constructor() {
        ProductOffered[] memory productOfferedSA = new ProductOffered[](2);
        productOfferedSA[0] = ProductOffered.RawMaterials;
        productOfferedSA[1] = ProductOffered.Services;
        registerSupplier(
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            "Supplier A",
            "Contact A",
            "Location A",
            productOfferedSA
        );
        ProductOffered[] memory productOfferedSB = new ProductOffered[](2);
        productOfferedSB[0] = ProductOffered.Components;
        productOfferedSB[1] = ProductOffered.Goods;
        registerSupplier(
            0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef,
            "Supplier B",
            "Contact B",
            "Location B",
            productOfferedSB
        );
        ProductOffered[] memory productOfferedSC = new ProductOffered[](3);
        productOfferedSC[0] = ProductOffered.Equipments;
        productOfferedSC[1] = ProductOffered.Goods;
        productOfferedSC[2] = ProductOffered.Components;
        registerSupplier(
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            "Supplier C",
            "Contact C",
            "Location C",
            productOfferedSC
        );
    }

    function registerSupplier(
        address _supplierAddress,
        string memory _name,
        string memory _contactInformation,
        string memory _location,
        ProductOffered[] memory _productOffered
    ) public onlyOwner {
        Supplier memory newSupplier = Supplier({
            supplierAddress: _supplierAddress,
            supplierName: _name,
            contactInformation: _contactInformation,
            location: _location,
            productOffered: _productOffered
        });
        registeredSuppliers[msg.sender].push(newSupplier);
        emit RegisterSupplier(msg.sender, newSupplier);
    }

    function getSupplierDetails(uint256 _index)
        internal
        view
        onlyOwner
        returns (
            address,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        require(
            _index < registeredSuppliers[msg.sender].length,
            "Supplier's index out of bounds"
        );

        return (
            registeredSuppliers[msg.sender][_index].supplierAddress,
            registeredSuppliers[msg.sender][_index].supplierName,
            registeredSuppliers[msg.sender][_index].contactInformation,
            registeredSuppliers[msg.sender][_index].location,
            getProductOfferedAsString(
                registeredSuppliers[msg.sender][_index].productOffered
            )
        );
    }

    function updateSupplierDetails(
        uint256 _index,
        string memory _supplierName,
        string memory _contactInfo,
        string memory _location,
        ProductOffered[] memory _productOffered
    ) external onlyOwner {
        require(
            _index < registeredSuppliers[msg.sender].length,
            "Supplier's index out of bounds"
        );
        Supplier storage sup = registeredSuppliers[msg.sender][_index];
        sup.supplierName = _supplierName;
        sup.contactInformation = _contactInfo;
        sup.location = _location;
        sup.productOffered = _productOffered;
        emit UpdateSupplierDetails(msg.sender, _index);
    }
}

contract ManufacturerOperation is SCMOwner {
    constructor() {
        //2ab07c18b2cd08a6d29b80a8c3093ff8d099c3f3db3da8fe84f15ef52929e8aa
        registerManufacturer(
            0xC3b89c7853E22606AB6658E724416B06b39A4556,
            "A FARMASI",
            "KL"
        );
        //fa4ddd99a278997470aca5144d0916f90b3040b47f6436ef983e04e1ded661f1
        registerManufacturer(
            0xCb93F2D6Faace5b91a5D632eB2b5E6C1Cd9C28ca,
            "C FARMASI",
            "KL"
        );
        //
        registerManufacturer(
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            "B FARMASI",
            "KL"
        );
    }

    function registerManufacturer(
        address _manufacturerAddress,
        string memory _manufacturerName,
        string memory _location
    ) public onlyOwner {
        Manufacturer memory newManufacturer = Manufacturer({
            manufacturerAddress: _manufacturerAddress,
            manufacturerName: _manufacturerName,
            location: _location
        });
        registeredManufacturers[msg.sender].push(newManufacturer);
        emit RegisterManufacturer(msg.sender, newManufacturer);
    }

    function getManufacturerDetails(uint256 _index)
        internal
        view
        onlyOwner
        returns (
            address,
            string memory,
            string memory
        )
    {
        require(
            _index < registeredManufacturers[msg.sender].length,
            "Manufacturer's index out of bounds"
        );

        return (
            registeredManufacturers[msg.sender][_index].manufacturerAddress,
            registeredManufacturers[msg.sender][_index].manufacturerName,
            registeredManufacturers[msg.sender][_index].location
        );
    }

    function updateManufacturerDetails(
        uint256 _index,
        string memory _manufacturerName,
        string memory _location
    ) external onlyOwner {
        require(
            _index < registeredManufacturers[msg.sender].length,
            "Manufacturer's index out of bounds"
        );
        Manufacturer storage manu = registeredManufacturers[msg.sender][_index];
        manu.manufacturerName = _manufacturerName;
        manu.location = _location;
        emit UpdateSupplierDetails(msg.sender, _index);
    }
}

contract DistributorOperation is SCMOwner {
    constructor() {}

    function registerDistributor(
        address _distributorAddress,
        string memory _distributorName,
        string memory _location
    ) public onlyOwner {
        Distributor memory newDistributor = Distributor({
            distributorAddress: _distributorAddress,
            distributorName: _distributorName,
            location: _location
        });
        registeredDistributors[msg.sender].push(newDistributor);
        emit RegisterDistributor(msg.sender, newDistributor);
    }

    function updateDistributorDetails(
        uint256 _index,
        string memory _distributorName,
        string memory _location
    ) external onlyOwner {
        require(
            _index < registeredDistributors[msg.sender].length,
            "Distributor's index out of bounds"
        );
        Distributor storage dis = registeredDistributors[msg.sender][_index];
        dis.distributorName = _distributorName;
        dis.location = _location;
        emit UpdateDistributorDetails(msg.sender, _index);
    }
}

contract RetailerOperation is SCMOwner {
    constructor() {}
    function registerRetailer(
        address _retailerAddress,
        string memory _retailerName, 
        string memory _location
    ) public onlyOwner{
        Retailer memory newRetailer = Retailer({
            retailerAddress: _retailerAddress,
            retailerName: _retailerName,
            location: _location
        });
        registeredRetailers[msg.sender].push(newRetailer);
        emit RegisterRetailer(msg.sender, newRetailer);
    }
    function updateRetailerDetails(
        uint256 _index, string memory _retailerName, string memory _location
    ) internal onlyOwner{
        require(_index<registeredRetailers[msg.sender].length, "Retailer's index out of bounds.");
        Retailer storage retailer = registeredRetailers[msg.sender][_index];
        retailer.retailerName = _retailerName;
        retailer.location=_location;
        emit UpdateRetailerDetails(msg.sender, _index);
    }
  
}

contract verifyOperation is
    SCMOwner,
    SupplierOperation,
    ManufacturerOperation,
    DistributorOperation,
    RetailerOperation
{ 
   
    constructor() {
       
        approveManufacturer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        approveSupplier(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    }

    function approveSupplier(address _supplierAddress)
        public
        onlyOwner
    {
        for(uint256 i=0;i<registeredSuppliers[msg.sender].length;i++){
            if(registeredSuppliers[msg.sender][i].supplierAddress==_supplierAddress){
                Supplier storage supplier = registeredSuppliers[msg.sender][i];
                 VerifiedSupplier memory newVerifiedSupplier = VerifiedSupplier({
            supplierAddress: _supplierAddress,
            supplierName: supplier.supplierName,
            contactInformation: supplier.contactInformation,
            location: supplier.location,
            productOffered: supplier.productOffered,
            approval: true,
            supplierID: generateSupplierID(supplier.productOffered)
        });
        verifiedSuppliers[msg.sender].push(newVerifiedSupplier);
        setTotalSuppliersCounter();
        emit VerifySupplier(
            msg.sender,
            getTotalSuppliersCounter(),
            newVerifiedSupplier
        );
            }
        }
      
       

       
    }
    function approveManufacturer(address _manufacturerAddress)
        public
        onlyOwner
    {
        for(uint256 i=0;i<registeredManufacturers[msg.sender].length;i++){
             if(registeredManufacturers[msg.sender][i].manufacturerAddress==_manufacturerAddress){
        Manufacturer storage manufacturer = registeredManufacturers[msg.sender][i];
        VerifiedManufacturer
            memory newVerifiedManufacturer = VerifiedManufacturer({
                manufacturerAddress: _manufacturerAddress,
                manufacturerName: manufacturer.manufacturerName,
                location: manufacturer.location,
                approval: true,
                manufacturerID: generateManufacturerID()
            });
        verifiedManufacturers[msg.sender].push(newVerifiedManufacturer);
        setTotalManufacturersCounter();
        emit VerifyManufacturer(
            msg.sender,
            getTotalManufacturersCounter(),
            newVerifiedManufacturer
        );
             }
        }
    }
    function approveDistributor(address _distributorAddress) public onlyOwner {
        for (
            uint256 i = 0;
            i < registeredDistributors[msg.sender].length;
            i++
        ) {
            if (
                registeredDistributors[msg.sender][i].distributorAddress ==
                _distributorAddress
            ) {
                //return true;
                Distributor storage distributor = registeredDistributors[
                    msg.sender
                ][i];
                VerifiedDistributor memory newVD = VerifiedDistributor({
                    distributorAddress: _distributorAddress,
                    distributorName: distributor.distributorName,
                    location: distributor.location,
                    distributorID: generateDistributorID()
                });
                verifiedDistributors[msg.sender].push(newVD);
                setTotalDistributorsCounter();
                emit VerifyDistributor(
                    msg.sender,
                    getTotalDistributorsCounter(),
                    newVD
                );
            }
        }
    }
    function approveRetailer(address _retailerAddress) public onlyOwner{
        for(uint256 i=0;i<registeredRetailers[msg.sender].length;i++){
            if(registeredRetailers[msg.sender][i].retailerAddress==_retailerAddress){
                Retailer storage retailer = registeredRetailers[msg.sender][i];
                VerifiedRetailer memory newVR = VerifiedRetailer({
                    retailerAddress: _retailerAddress,
                    retailerName: retailer.retailerName,
                    location: retailer.location,
                    retailerID: generateRetailerID()
                });
                verifiedRetailers[msg.sender].push(newVR);
                setTotalRetailersCounter();
                emit VerifyRetailer(msg.sender, getTotalRetailersCounter(), newVR);
            }
        }
    }
   
    function registerMedicine(
        MedicineType _medicineType,
        string memory _medicineName,
        string memory _medicineInfo,
        Stage _currentStage,
        string memory _supplierID
    ) public onlyOwner {
        require(checkSupplierID(_supplierID), "Supplier Not Exist.");
        Medicine memory newMed = Medicine({
            med: _medicineType,
            medicineID: generateMedicineID(_medicineType),
            medicineName: _medicineName,
            medicineInfo: _medicineInfo,
            currentStage: _currentStage,
            supplierID: _supplierID
        });
        registeredMedicines[msg.sender].push(newMed);
        emit RegisterMedicine(msg.sender, newMed);
    }

    function checkSupplierID(string memory _supplierID)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < verifiedSuppliers[msg.sender].length; i++) {
            if (
                keccak256(bytes(verifiedSuppliers[msg.sender][i].supplierID)) ==
                keccak256(bytes(_supplierID))
            ) {
                return true;
            }
        }
        return false;
    }

    function isManufacturerVerified(
        address _owner,
        address _manufacturerAddress) public view returns (bool) {
        for (uint256 i = 0; i < verifiedManufacturers[_owner].length; i++) {
            if (
                verifiedManufacturers[_owner][i].manufacturerAddress ==
                _manufacturerAddress
            ) {
                return true;
            }
        }
        return false;
    }
    function isDistributorVerified(address _owner, address _distributorAddress) public view returns (bool){
        for(uint256 i=0; i< verifiedDistributors[_owner].length; i++){
            if(verifiedDistributors[_owner][i].distributorAddress == _distributorAddress){
                return true;
            }
        }
        return false;
    }
    function isRetailerVerified(address _owner, address _retailerAddress) public view returns (bool){
        for(uint256 i=0; i< verifiedRetailers[_owner].length;i++){
            if(verifiedRetailers[_owner][i].retailerAddress == _retailerAddress){
                return true;
            }
        }
        return false;
    }

    function getAllVSupplier()
        public
        view
        returns (VerifiedSupplier[] memory)
    {
        VerifiedSupplier[] memory allSuppliers = new VerifiedSupplier[](
            verifiedSuppliers[msg.sender].length
        );

        for (uint256 i = 0; i < verifiedSuppliers[msg.sender].length; i++) {
            allSuppliers[i] = verifiedSuppliers[msg.sender][i];
        }
        return allSuppliers;
    }
    function getAllVManufacturer()
        public
        view
        returns (VerifiedManufacturer[] memory)
    {
        VerifiedManufacturer[]
            memory allManufacturers = new VerifiedManufacturer[](
                verifiedManufacturers[msg.sender].length
            );

        for (uint256 i = 0; i < verifiedManufacturers[msg.sender].length; i++) {
            allManufacturers[i] = verifiedManufacturers[msg.sender][i];
        }
        return allManufacturers;
    }

    function getAllVDistributor()
        public
        view
        returns (VerifiedDistributor[] memory)
    {
        VerifiedDistributor[]
            memory allDistributors = new VerifiedDistributor[](
                verifiedDistributors[msg.sender].length
            );

        for (uint256 i = 0; i < verifiedDistributors[msg.sender].length; i++) {
            allDistributors[i] = verifiedDistributors[msg.sender][i];
        }
        return allDistributors;
    }
    function getAllVRetailer() public view returns(VerifiedRetailer[] memory){
        VerifiedRetailer[] memory allRetailers = new VerifiedRetailer[](verifiedRetailers[msg.sender].length);
        for(uint256 i=0; i < verifiedRetailers[msg.sender].length;i++){
            allRetailers[i] = verifiedRetailers[msg.sender][i];
        }
        return allRetailers;
    }

    function getAllMedicines()
        external
        view
        returns (Medicine[] memory)
    {
        Medicine[] memory allMedicines = new Medicine[](
            registeredMedicines[msg.sender].length
        );

        for (uint256 i = 0; i < registeredMedicines[msg.sender].length; i++) {
            allMedicines[i] = registeredMedicines[msg.sender][i];
        }
        return allMedicines;
    }

}

contract ForManufacturer {
    verifyOperation internal verifyOp;
    SCMOwner internal ownerContract;
    address payable private ownerMANU;

    struct Product {
        string productName;
        string productInfo;
        uint256 productStock;
        uint256 price;
        string productID;
        string medicineID;
        string MANid;
    }
    //
    struct VerifiedManufacturer {
        address manufacturerAddress;
        string manufacturerName;
        string location;
        bool approval;
        string manufacturerID;
    }
    struct VerifiedSupplier {
        address supplierAddress;
        string supplierName;
        string contactInformation;
        string location;
        ProductOffered[] productOffered;
        bool approval;
        string supplierID;
    }
    //
    enum ProductOffered {
        RawMaterials,
        Components,
        Equipments,
        Goods,
        Services
    }
    struct Medicine {
        MedicineType med;
        string medicineID;
        string medicineName;
        string medicineInfo;
        Stage currentStage;
    }
    enum MedicineType {
        Liquid,
        Tablet,
        Capsules,
        Injections
        // https://www.gosh.nhs.uk/conditions-and-treatments/medicines-information/types-medicines/
    }
    enum Stage {
        Initial,
        RawMaterial, //supplier
        Manufacture,
        Distributor,
        Retailer,
        Sold
    }

    address payable private manufacturerAddress;
    mapping(address => Product[]) internal registeredProducts;
    mapping(address => VerifiedManufacturer[]) internal verifiedManufacturers;
    mapping(address => VerifiedSupplier[]) internal verifiedSuppliers;
    mapping(address => Medicine[]) internal registeredMedicines;
    mapping(address=> mapping(string => bool)) private productExist;
    event RegisterProduct(address indexed _product, Product product);

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    constructor(
        address _ownerContractAddress,
        address _verifyOp,
        address _owner
    ) {
        verifyOp = verifyOperation(_verifyOp);
        ownerContract = SCMOwner(_ownerContractAddress);

        require(
            verifyOp.isManufacturerVerified(getOwnerAddress(), _owner),
            "Manufacture Not Found."
        );
        setOwnerMANU(payable(address(_owner)));
        listenToEvents();
    }

    modifier onlyManufacturer() {
        require(msg.sender == getOwnerMANU(), "Only Manufacturer can perform.");
        _;
    }

    function getOwnerMANU() internal view returns (address) {
        return payable(address(ownerMANU));
    }

    function setOwnerMANU(address _owner) internal {
        ownerMANU = payable(_owner);
    }

    function getIDsAsString(string memory _ID)
        internal
        pure
        returns (string memory)
    {
        return string(_ID);
    }

    function getOwnerAddress() internal view returns (address) {
        return ownerContract.getOwnerAddress();
    }

    function convertMedicineType(SCMOwner.MedicineType _medType)
        internal
        pure
        returns (MedicineType)
    {
        if (_medType == SCMOwner.MedicineType.Liquid) {
            return MedicineType.Liquid;
        } else if (_medType == SCMOwner.MedicineType.Tablet) {
            return MedicineType.Tablet;
        } else if (_medType == SCMOwner.MedicineType.Capsules) {
            return MedicineType.Capsules;
        } else if (_medType == SCMOwner.MedicineType.Injections) {
            return MedicineType.Injections;
        } else {
            revert("Unknown MedicineType");
        }
    }

    function convertStage(SCMOwner.Stage _stage) internal pure returns (Stage) {
        if (_stage == SCMOwner.Stage.Initial) {
            return Stage.Initial;
        } else if (_stage == SCMOwner.Stage.RawMaterial) {
            return Stage.RawMaterial;
        } else if (_stage == SCMOwner.Stage.Manufacture) {
            return Stage.Manufacture;
        } else if (_stage == SCMOwner.Stage.Distributor) {
            return Stage.Distributor;
        } else if (_stage == SCMOwner.Stage.Retailer) {
            return Stage.Retailer;
        } else if (_stage == SCMOwner.Stage.Sold) {
            return Stage.Sold;
        } else {
            revert("Unknown Stage");
        }
    }

    function convertProductOffered(SCMOwner.ProductOffered value)
        internal
        pure
        returns (ForManufacturer.ProductOffered)
    {
        if (value == SCMOwner.ProductOffered.RawMaterials) {
            return ForManufacturer.ProductOffered.RawMaterials;
        } else if (value == SCMOwner.ProductOffered.Components) {
            return ForManufacturer.ProductOffered.Components;
        } else if (value == SCMOwner.ProductOffered.Equipments) {
            return ForManufacturer.ProductOffered.Equipments;
        } else if (value == SCMOwner.ProductOffered.Goods) {
            return ForManufacturer.ProductOffered.Goods;
        } else if (value == SCMOwner.ProductOffered.Services) {
            return ForManufacturer.ProductOffered.Services;
        } else {
            revert("Unknown ProductOffered type");
        }
    }

    //set the manu address as msg.sender
    function listenToEvents() internal {
        verifyOperation.VerifiedManufacturer[] memory vm = verifyOp
            .getAllVManufacturer(
                //getOwnerAddress()
                );
        for (uint256 i = 0; i < vm.length; i++) {
            VerifiedManufacturer memory tempVM = VerifiedManufacturer(
                vm[i].manufacturerAddress,
                vm[i].manufacturerName,
                vm[i].location,
                vm[i].approval,
                vm[i].manufacturerID
            );
            verifiedManufacturers[getOwnerMANU()].push(tempVM);
        }
        verifyOperation.VerifiedSupplier[] memory vs = verifyOp.getAllVSupplier(
           // getOwnerAddress()
        );
        for (uint256 i = 0; i < vs.length; i++) {
            ProductOffered[] memory productOffered = new ProductOffered[](
                vs[i].productOffered.length
            );
            for (uint256 j = 0; j < vs[i].productOffered.length; j++) {
                productOffered[j] = convertProductOffered(
                    vs[i].productOffered[j]
                );
            }
            VerifiedSupplier memory tempVS = VerifiedSupplier(
                vs[i].supplierAddress,
                vs[i].supplierName,
                vs[i].contactInformation,
                vs[i].location,
                productOffered,
                vs[i].approval,
                vs[i].supplierID
            );
            verifiedSuppliers[getOwnerMANU()].push(tempVS);
        }
        verifyOperation.Medicine[] memory med = verifyOp.getAllMedicines(
            //getOwnerAddress()
        );
        for (uint256 i = 0; i < med.length; i++) {
            Medicine memory tempMed = Medicine(
                convertMedicineType(med[i].med),
                med[i].medicineID,
                med[i].medicineID,
                med[i].medicineInfo,
                convertStage(med[i].currentStage)
            );
            registeredMedicines[getOwnerMANU()].push(tempMed);
        }
    }

    function getVM()
        external
        onlyManufacturer
        returns (VerifiedManufacturer[] memory)
    {
        listenToEvents();
        VerifiedManufacturer[] memory allVMs = new VerifiedManufacturer[](
            verifiedManufacturers[getOwnerMANU()].length
        );
        for (
            uint256 i = 0;
            i < verifiedManufacturers[getOwnerMANU()].length;
            i++
        ) {
            allVMs[i] = verifiedManufacturers[getOwnerMANU()][i];
        }
        return allVMs;
    }

    function getM() external onlyManufacturer returns (Medicine[] memory) {
        listenToEvents();
        Medicine[] memory allMs = new Medicine[](
            registeredMedicines[getOwnerMANU()].length
        );
        for (
            uint256 i = 0;
            i < registeredMedicines[getOwnerMANU()].length;
            i++
        ) {
            allMs[i] = registeredMedicines[getOwnerMANU()][i];
        }
        return allMs;
    }

    

    function addProduct(
        string memory _productName,
        string memory _productInfo,
        uint256 _stock,
        uint256 _price,
        string memory _medicineID
    ) external onlyManufacturer {
        listenToEvents();
        string memory _productID = generateProductID();
        require(
            checkMedicineID(_medicineID),
            "Medicine OR Supplier Not Existed."
        );
        require(!productExist[getOwnerMANU()][_productID], "Product exist in Manufacturer's stock.");
       
        Product memory newProduct = Product({
            productName: _productName,
            productInfo: _productInfo,
            productStock: _stock,
            price: _price,
            medicineID: _medicineID,
            productID: _productID,
            MANid: getManufacturerID(getOwnerMANU())
        });
        registeredProducts[getOwnerMANU()].push(newProduct);
        emit RegisterProduct(getOwnerMANU(), newProduct);
        productExist[getOwnerMANU()][_productID] = true;
    }

    function getAllProduct() public view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](
            registeredProducts[getOwnerMANU()].length
        );
        for (
            uint256 i = 0;
            i < registeredProducts[getOwnerMANU()].length;
            i++
        ) {
            allProducts[i] = registeredProducts[getOwnerMANU()][i];
        }
        return allProducts;
    }

    function getManufacturerID(address _manufacturerAddress)
        internal
        view
        returns (string memory)
    {
        string memory manufacturerID;
        for (
            uint256 i = 0;
            i < verifiedManufacturers[_manufacturerAddress].length;
            i++
        ) {
            if (
                verifiedManufacturers[_manufacturerAddress][i]
                    .manufacturerAddress == _manufacturerAddress
            ) {
                manufacturerID = verifiedManufacturers[_manufacturerAddress][i]
                    .manufacturerID;
                break;
            }
        }
        return (manufacturerID);
    }

    function checkMedicineID(string memory _medicineID)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < registeredMedicines[msg.sender].length; i++) {
            if (
                keccak256(
                    bytes(registeredMedicines[msg.sender][i].medicineID)
                ) == keccak256(bytes(_medicineID))
            ) {
                return true;
            }
        }
        return false;
    }

    function getManufacturerDetails()
        external
        view
        returns (
            string memory manufacturerID,
            string memory manufacturerName,
            string memory location,
            bool approval
        )
    {
        address owner = getOwnerMANU();
        uint256 length = verifiedManufacturers[owner].length;
        for (uint256 i = 0; i < length; i++) {
            VerifiedManufacturer memory manufacturer = verifiedManufacturers[
                owner
            ][i];
            if (manufacturer.manufacturerAddress == owner) {
                return (
                    manufacturer.manufacturerID,
                    manufacturer.manufacturerName,
                    manufacturer.location,
                    manufacturer.approval
                );
            }
        }
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

    function generateProductID() internal view returns (string memory) {
        return string(abi.encodePacked("PROD", "-", generateRandomString(6)));
    }

    //remove(): remove products
    function removeProduct(uint256 _index) external onlyManufacturer {
        require(
            _index < registeredProducts[msg.sender].length,
            "Product Index out of bounds"
        );
        require(
            registeredProducts[msg.sender].length > 1,
            "Cannot remove the last product"
        );
        delete registeredProducts[msg.sender][_index];
    }
   
}

contract ForDistributor {
    ForManufacturer internal forManufacturer;
    verifyOperation internal verifyOp;
    SCMOwner internal ownerContract;
    address payable private ownerDIS;
    struct Product {
        string productName;
        string productInfo;
        uint256 productStock;
        uint256 price;
        string productID;
        string medicineID;
        string MANid;
    }

    struct DProduct {
        string productName;
        //string productInfo;
        uint256 productStock;
        uint256 productPrice;
        string productID;
        string medicineID;
        string MANid;
        string DISid;
    }
     struct VerifiedDistributor {
        address distributorAddress;
        string distributorName;
        string location;
        string distributorID;
    }
    mapping(address => VerifiedDistributor[]) internal verifiedDistributors;
    mapping(address => DProduct[]) internal forDistributedProduct;
    mapping(address => Product[]) internal registeredProducts;
    mapping(address => mapping(string => bool)) private DProductExists;
    event AddDProduct(address indexed _product, DProduct dproduct);

    constructor(
        address _ownerContractAddress,
        address _verifyOp,
        address _forManufacturer
    ) {
        verifyOp = verifyOperation(_verifyOp);
        ownerContract = SCMOwner(_ownerContractAddress);
       
        require(verifyOp.isDistributorVerified(getOwnerAddress(), _forManufacturer), "Distributor Not Found.");
        setOwnerDIS(payable(address(_forManufacturer)));
        listenToEvents();
    }

    modifier onlyDistributor() {
        require(msg.sender == getOwnerDIS(), "Only Distributor can perform.");
        _;
    }

    function getOwnerDIS() internal view returns (address) {
        return payable(address(ownerDIS));
    }

    function setOwnerDIS(address _owner) internal {
        ownerDIS = payable(_owner);
    }

    function getOwnerAddress() internal view returns (address) {
        return ownerContract.getOwnerAddress();
    }

    function listenToEvents() internal {
        verifyOperation.VerifiedDistributor[] memory vd = verifyOp.getAllVDistributor(
           // getOwnerAddress()
            );
        for(uint256 i=0;i<vd.length;i++){
            VerifiedDistributor memory tempVD = VerifiedDistributor(
                vd[i].distributorAddress,
                vd[i].distributorName,
                vd[i].location,
                vd[i].distributorID
            );
            verifiedDistributors[getOwnerDIS()].push(tempVD);
        }
        ForManufacturer.Product[] memory prod = forManufacturer.getAllProduct();
        for (uint256 i = 0; i < prod.length; i++) {
            Product memory tempProd = Product(
                prod[i].productName,
                prod[i].productInfo,
                prod[i].productStock,
                prod[i].price,
                prod[i].productID,
                prod[i].medicineID,
                prod[i].MANid
            );
            registeredProducts[getOwnerDIS()].push(tempProd);
        }
    }

    function getProductsFromManufacturer(uint256 _index)
        public
        view
        onlyDistributor
        returns (
            string memory,
            uint256,
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
        require(
            _index < registeredProducts[msg.sender].length,
            "Products From Manufacturer Not exits."
        );
        return (
            registeredProducts[getOwnerDIS()][_index].productName,
            registeredProducts[getOwnerDIS()][_index].productStock,
            registeredProducts[getOwnerDIS()][_index].price,
            registeredProducts[getOwnerDIS()][_index].productID,
            registeredProducts[getOwnerDIS()][_index].medicineID,
            registeredProducts[getOwnerDIS()][_index].MANid
        );
    }

    function getDProductAdded() public view returns (DProduct[] memory) {
        DProduct[] memory allProducts = new DProduct[](
            forDistributedProduct[getOwnerDIS()].length
        );
        for (
            uint256 i = 0;
            i < forDistributedProduct[getOwnerDIS()].length;
            i++
        ) {
            allProducts[i] = forDistributedProduct[getOwnerDIS()][i];
        }
        return allProducts;
    }

    //requestProduct(): contain the products that requsting for the no. of products & the amounts
    function requestProducts(string memory _ID, uint256 _stockWant)
        internal
        view
        returns (bool)
    {
        ForManufacturer.Product[] memory prod = forManufacturer.getAllProduct();
        for (uint256 i = 0; i < prod.length; i++) {
            if (keccak256(bytes(prod[i].productID)) == keccak256(bytes(_ID))) {
                if (prod[i].productStock >= _stockWant) {
                    return true;
                } else {
                    return false;
                }
            }
        }
        return false;
    }

    function getProductDetailsByID(uint256 _x, string memory _ID)
        internal
        view
        returns (string memory)
    {
        ForManufacturer.Product[] memory prod = forManufacturer.getAllProduct();
        for (uint256 i = 0; i < prod.length; i++) {
            if (keccak256(bytes(prod[i].productID)) == keccak256(bytes(_ID))) {
                if (_x == 0) {
                    return prod[i].productName;
                } else if (_x == 1) {
                    return prod[i].productInfo;
                } else if (_x == 2) {
                    return prod[i].medicineID;
                } else if (_x == 3) {
                    return prod[i].MANid;
                }
            }
        }
        return "";
    }
    function addDProduct(
        string memory _ID,
        uint256 _price,
        uint256 _stock
    ) public onlyDistributor {
        require(!DProductExists[getOwnerDIS()][_ID], "Product already Exists.");
        require(
            requestProducts(_ID, _stock),
            "Product Not Found from Manufacturer."
        );
        DProduct memory dproduct = DProduct({
            productName: getProductDetailsByID(0, _ID),
            productStock: _stock,
            productPrice: _price,
            productID: _ID,
            medicineID: getProductDetailsByID(2, _ID),
            MANid: getProductDetailsByID(3, _ID),
            DISid: getDistributorID(getOwnerDIS())
        });
        forDistributedProduct[getOwnerDIS()].push(dproduct);
        emit AddDProduct(getOwnerDIS(), dproduct);
    }

    function getAllProduct() public view returns(DProduct[] memory){
        DProduct[] memory allDProducts = new DProduct[](forDistributedProduct[getOwnerDIS()].length);
        for(uint256 i=0; i< forDistributedProduct[getOwnerDIS()].length;i++){
            allDProducts[i] = forDistributedProduct[getOwnerDIS()][i];
        }
        return allDProducts;
    }

    function removeDProduct(string memory _ID) public {
        DProduct[] storage dp = forDistributedProduct[getOwnerDIS()];
        for (uint256 i = 0; i < dp.length; i++) {
            if (compareStrings(dp[i].productID, _ID)) {
                for (uint256 j = i; j < dp.length; j++) {
                    dp[j] = dp[j + 1];
                }
                dp.pop();
                DProductExists[getOwnerDIS()][_ID] = false;
                break;
            }
        }
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    //revenue(): compare the price of DProduct from MProduct which products earned
    function revenue() public view returns (uint256) {
        uint256 totalRevenue = 0;

        DProduct[] memory dproduct = forDistributedProduct[getOwnerDIS()];
        for (uint256 i = 0; i < dproduct.length; i++) {
            string memory dproductID = dproduct[i].productID;
            ForManufacturer.Product[] memory mproduct = forManufacturer
                .getAllProduct();
            uint256 priceFromM;
            uint256 stockFromM;
            for (uint256 j = 0; j < mproduct.length; j++) {
                if (compareStrings(mproduct[j].productID, dproductID)) {
                    priceFromM = mproduct[j].price;
                    stockFromM = mproduct[j].productStock;
                }
            }
            uint256 priceDifference = dproduct[i].productPrice - priceFromM;
            totalRevenue += priceDifference * stockFromM;
        }
        return totalRevenue;
    }
    function getDistributorID(address _distributorAddress) internal view returns(string memory){
        string memory distributorID;
        for(uint256 i=0; i< verifiedDistributors[_distributorAddress].length; i++){
            if(verifiedDistributors[_distributorAddress][i].distributorAddress == _distributorAddress){
                distributorID = verifiedDistributors[_distributorAddress][i].distributorID;
                break;
            }
        }
        return (distributorID);
    }
}



contract ForRetailer {
    ForDistributor internal forDistributor;
    verifyOperation internal verifyOp;
    SCMOwner internal ownerContract;
    address payable private ownerRTL;

    struct DProduct {
        string productName;
        uint256 productStock;
        uint256 productPrice;
        string productID;
        string medicineID;
        string MANid;
        string DISid;
    }
    struct RProduct{
    string productName;
    uint256 productStock;
    uint256 productPrice;
    string productID;
    string medicineID;
    string MANid;
    string DISid;
    string RTLid;
    }
    mapping(address=>DProduct[]) internal forDistributedProduct;
    mapping (address=>RProduct[]) internal forRetailedProduct;
    mapping(address => mapping(string => bool)) private RProductExists;
    event AddProduct(address indexed _product, RProduct rproduct);

    constructor( address _ownerContractAddress,
        address _verifyOp,
        address _forDistributor){
        verifyOp =verifyOperation(_verifyOp);
        ownerContract = SCMOwner(_ownerContractAddress);
        forDistributor=ForDistributor(_forDistributor);
    }
    modifier onlyRetailer(){
        require(msg.sender==getOwnerRTL(), "Only Retailer can perform");
        _;
    }
    function getOwnerRTL() internal view returns(address){
        return payable(address(ownerRTL));
    }
    function setOwnerRTL(address _owner) internal{
        ownerRTL = payable(_owner);
    } 
    function getOwnerAddress() internal view returns(address){
        return ownerContract.getOwnerAddress();
    }
    function listenToEvents() internal{
        ForDistributor.DProduct[] memory prod = forDistributor.getAllProduct();
        for(uint256 i=0;i<prod.length;i++){
            DProduct memory tempProd = DProduct(
                prod[i].productName,
                prod[i].productStock,
                prod[i].productPrice,
                prod[i].productID,
                prod[i].medicineID,
                prod[i].MANid,
                prod[i].DISid
            );
            forDistributedProduct[getOwnerRTL()].push(tempProd);
        }
    }
    function getRProductAdded() public view returns (RProduct[] memory){
        RProduct[] memory allProducts = new RProduct[](forRetailedProduct[getOwnerRTL()].length);
        for(uint256 i=0; i< forRetailedProduct[getOwnerRTL()].length;i++){
            allProducts[i]=forRetailedProduct[getOwnerRTL()][i];
        }
        return allProducts;
    }

    function requestProduct(string memory _ID, uint256 _stockWant) internal view returns(bool){
        ForDistributor.DProduct[] memory prod = forDistributor.getDProductAdded();
        for(uint256 i=0; i<prod.length;i++){
            if(keccak256(bytes(prod[i].productID))==keccak256(bytes(_ID))){
                if(prod[i].productStock>=_stockWant){
                    return true;
                }else{
                    return false;
                }
            }
        }
        return false;
    }
    function getProductDetailsByID(uint256 _x, string memory _ID) internal view returns (string memory){
        ForDistributor.DProduct[] memory prod = forDistributor.getDProductAdded();
        for (uint256 i = 0; i < prod.length; i++) {
            if (keccak256(bytes(prod[i].productID)) == keccak256(bytes(_ID))) {
                if (_x == 0) {
                    return prod[i].productName;
                } 
                //else if (_x == 1) {
                //    return prod[i].productInfo;
                //} 
                else if (_x == 2) {
                    return prod[i].medicineID;
                }else if (_x == 3) {
                    return prod[i].MANid;
                }else if(_x==4){
                    return prod[i].DISid;
                }
            }
        }
        return "";
    }

}
