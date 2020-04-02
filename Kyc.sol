pragma solidity ^0.5.0;

contract Kyc{
    
    /*
    struct to represent Customer client.
    customerName : unique Customer name. 
    dataHash     : customer data in hashed string. 
    rating       : customer rating dpeneds on Customer regulartiy.
    upvotes      : upvotes received from other banks over customer data.
    bank         : bank address that validate the customer account.
    password     : Customer password for authentication.
     */
    struct Customer {
        string customerName;
        string dataHash;
        uint rating;
        uint upvotes;
        address bank;
        string password;
    }
    /*
    struct to represent Bank client.
    bankName     : name of the bank. 
    ethAddress   : ethereum address of bank/unique address type.
    rating       : bank rating dpeneds on valid/invalid account varification.
    KYC_count    : number of KYC varified by the bank.
    regNumbe     : Registration number of the bank.
     */
    struct Bank{
        string bankName;
        address ethAddress;
        uint rating;
        uint KYC_count;
        string regNumber;
        
    }
    /*
    struct to represent kyc requests.
    userName     : Name of the customer upon which KYC is requested. 
    bankAddress  : Bank Address whom created the request for KYC 
    isAllowed    : flag to varify if bank is allowed to perform KYC.
    KYC_count    : number of KYC varified by the bank.
    regNumbe     : Registration number of the bank.
     */
    struct Request{
        string userName;
        address bankAddress;
        bool isAllowed;
        bytes32 requestID;
    }
    
    //List of all Customers.
    Customer[] public allCustomers;
    //List of all requests
    Request[] public allRequests;
    //List of all banks
    Bank[] public allBanks;
    //Mapping of requestID to Request struct
    mapping(bytes32 => Request) requests;
    // Store the byte32 type requestID.
    bytes32[] private _requestIDs ;
    
    // Bank Interface Starts
    /*
    function to add a KYC request.
    @param : customerName  for the customer and Bank address of the bank who requested the KYC
    @return : -
    this function made payable beacause bank provide some initial value to start KYC process.
    */
    function addRequest(string memory _customerName, address _bankAddress) public payable {
        //validate bankAddress from DB
        require(validateBank(_bankAddress));
        //validate customerName from DB
        require(validateCustomer(_customerName));
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringEquals(allRequests[i].userName, _customerName) && allRequests[i].bankAddress == _bankAddress) {
                return;
            }
        }
        //Increasing the allRequests array length by 1.
        allRequests.length ++;
        // Inserting new Request struct into allRequests array end.
        allRequests[allRequests.length - 1] = Request(_customerName, _bankAddress, false, structToByte(_customerName,_bankAddress));
        
    }
    
    /*function to remove request for KYC
    @Params - customername for the customer
    @return - This function returns 0 whenremoval is successful else this return 1 if the Username
    for the customer is not found
    */
    function removeRequest(string memory _customerName) public payable returns(uint) {
        for(uint i = 0; i < allRequests.length; i++) {
            if(stringEquals(allRequests[i].userName, _customerName)) {
                for(uint j = i+1;j < allRequests.length; j++) {
                    allRequests[j-1] = allRequests[j];
                }
                allRequests.length --;
                return 0;
            }
        }
    // throw error if uname not found
    return 1;
    }
    
    /*
    Function to add customer data by bank has to pay some value in order to customer.
    @params : customerName and dataHash as strings
    @return : uint  returns 2 if duplicate found, 1 if customer data added unsuccessfull, 0 for successfully adding customer.
    */
    function addCustomer(string memory _customerName, string memory _dataHash) public payable returns (uint){
       //check valid bank adding the customer 
        require(validateBank());
        for(uint i =0;i<allCustomers.length;i++){
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                return 2;
            }
        }
        //increasing the allCustomers array length by 1.
        allCustomers.length++;
        //validate array length is atleast 1.
        if(allCustomers.length < 1){
            return 1;
        }
        // Inserting new Customer struct into allCustomers array.default 1 rating and 0 upvotes.
        allCustomers[allCustomers.length-1] = Customer(_customerName,_dataHash,1,0,msg.sender,"temp");
        //updating the rating of bank after adding the customer KYC profile.
        updateRatingBank(msg.sender,true);
        return 0;
    }
    
    /*
    Function to remove customer data from system.
    @params : customerName as strings
    @return : uint  returns 1 if customer not removed successfully, 0 if customer removed successfully.
    */
    function removeCustomer(string memory _customerName) public payable returns (uint){
        //check valid bank adding the customer
        require(validateBank());
        address bank;
        for(uint i =0;i<allCustomers.length;i++){
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                bank = allCustomers[i].bank;
                //loop through all remaining element of allCustomers array after index i and shift all of them one position left.
                for(uint j = i+1;j<allCustomers.length;j++){
                    allCustomers[j-1] = allCustomers[j];
                }
                //decrease allCustomers array the size.
                allCustomers.length--;
                updateRatingBank(bank,false);
                return 0;
            }
        }
        //return error if customer not found
        return 1;
    }
    
    /*
    Function to modify customer data from system.
    @params : customerName as strings, dataHash as string.
    @return : uint  returns 1 if customer not removed successfully, 0 if customer removed successfully.
    */
    function modifyCustomer(string memory _customerName,string memory _dataHash) public payable returns (uint){
        //check valid bank adding the customer
        require(validateBank());
        for(uint i =0;i<allCustomers.length;i++){
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                //updating the customer data.
                allCustomers[i].dataHash = _dataHash;
                //updating the customer bank.
                allCustomers[i].bank = msg.sender;
                return 0;
            }
        }
        //return error if customerName not found
        return 1;
    }
    
    /*
    Function to view customer data from system.
    @params : customerName as strings
    @return : return the dataHash of customer as a string./error messsage if customer not found.
    */
    function viewCustomer(string memory _customerName) public payable returns (string memory){
        //check valid bank adding the customer
        require(validateBank());
        for(uint i=0;i<allCustomers.length;i++){
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                return allCustomers[i].dataHash;
            }
        }
        //returning error if customerName not found.
        return "Invalid Customer Name Entered.";
        
    }
    
     /*
    Function to get bank requests details for a specific to a bank
    @params : bankAddress
    @return : list of requestID associated with the bank.
    */
    function getBankRequest(address _bankAddress) public payable returns(bytes32[] memory){
        require(validateBank(_bankAddress));
        
        for(uint i=0;i<allRequests.length;i++){
            if(allRequests[i].bankAddress == _bankAddress){
                //adding the requestID to Request struct mapping.
                requests[allRequests[i].requestID] = allRequests[i];
                //pushing the requestID to array bytes32
                _requestIDs.push(allRequests[i].requestID);
            }
        }
        //return bytes32 array of all associated requestID of the bank.
        return _requestIDs;
        //setting the array to empty.
        _requestIDs.length =0;
    }
    
    /*
    Function Fetch the request details from requestID.
    @params : requestID of bytes32 type
    @return : string userName, address bankAddress, bool isAllowed.
    */
    function getRequest(bytes32 _requestID) public view returns(string memory, address, bool){
        //returing the data in individual element as returning struct is not allowed in solidity.
        return (requests[_requestID].userName,requests[_requestID].bankAddress,requests[_requestID].isAllowed);
    }
    
    /*         
    function to update customer rating by bankAddress
    @params : _customerName, _isUpvote(bool) 
    @return : this function will update the customer rating based on upvoted by the bank or not.
              returns 0 if rating updated succesfull else 1.  
    
    */
    function updateRatingCustomer(string memory _customerName, bool _isUpvote) public payable returns(uint) {
        validateCustomer(_customerName);
        for(uint i = 0; i < allCustomers.length; i++) {
            if(stringEquals(allCustomers[i].customerName, _customerName)) {
                //Bank upvoted the customer 
                if(_isUpvote) {
                    allCustomers[i].upvotes = allCustomers[i].upvotes + 1;
                    //increasing the rating by 1th of total upvotes.
                    allCustomers[i].rating = allCustomers[i].rating + 1/(allCustomers[i].upvotes);
                    //setting up the max limit
                    if(allCustomers[i].rating > 10) {
                        allCustomers[i].rating = 10;
                    }
                }
                else {
                    //Bank down voted the customer
                    //decreasing the rating by 1th of total upvotes.
                    allCustomers[i].rating = allCustomers[i].rating - 1/(allCustomers[i].upvotes);
                    //setting up the floor limit
                    if(allCustomers[i].rating < 1) {
                        allCustomers[i].rating = 1;
                    }
                }
                //return success.
                return 0;
            }
        }
        //return an error when customer not found.
        return 1;
    }    
    
    /*function to update bank rating based on KYC performance.
    @params : bankAddress and kyc status of bank.(true means KYC success, false means KYC failure).
    @return : this function will update the bank rating based on kyc_valid/Invalid
              returns 0 if rating updated succesfull else 1.
    */  
    function updateRatingBank(address _bankAddress,bool _isKYCValid) public payable returns(uint) {
        validateBank(_bankAddress);
        for(uint i = 0; i < allBanks.length; i++) {
            if(allBanks[i].ethAddress == _bankAddress) {
                //When KYC count increases, update bank rating by 1th of total KYC_count
                if(_isKYCValid) {
                    allBanks[i].KYC_count ++;
                    allBanks[i].rating = allBanks[i].rating + 1/(allBanks[i].KYC_count);
                    if(allBanks[i].rating > 10) {
                        //setting up the max limit
                        allBanks[i].rating = 10;
                    }
                }
                else {
                    //When KYC not valid, down grade bank rating by 1th of total KYC_count, we need to add 1 to KYC_count in denominater to mimic the failure.
                     allBanks[i].rating = allBanks[i].rating - 1/(allBanks[i].KYC_count + 1);
                    //setting up the floor limit
                    if(allBanks[i].rating < 1) {
                        allBanks[i].rating = 1;
                    }
                }
                //return success.
                return 0;
            }
        }
        //return an error when bank not found.
        return 1;
    }      
    

    /*function to return the cutomer current rating.
    @params : customerName
    @return : rating in uint
    */ 
    function getCustomerRating(string memory _customerName) public payable returns(uint){
        //validating customerName
        require(validateCustomer(_customerName));
        for(uint i = 0; i < allCustomers.length;i++) {
            //fetching and returning the customer rating.
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                return allCustomers[i].rating;
            }
        }
    }
    
    /*function to fetch and return the bank current rating.
    @params : bankaddress
    @return : rating in uint
    */ 
    function getBankRating(address _bankAddress) public payable returns(uint){
        //validating the bankaddress
        require(validateBank(_bankAddress));
        for(uint i = 0; i < allBanks.length;i++) {
            //fetching and returning the bank rating
            if(allBanks[i].ethAddress == _bankAddress){
                return allBanks[i].rating;
            }
        }
    }
    
    
    //Bank Interface Ends>>>> Customer Interface Starts >>>
    /*function to setPassword for Customer from the temp one assigned at the time of creation
    @params : customerName and password (password is in string format no security taken care off)
    @return : return ture if password changed successful else false.
    */ 
     function setPassword(string memory _customerName, string memory _password) public payable returns(bool) {
        for(uint i=0;i < allCustomers.length; i++) {
            //searching the allCustomers array
            if(stringEquals(allCustomers[i].customerName, _customerName) && !(stringEquals(allCustomers[i].password, "temp"))) {
               //password already set by customer, should call change password function.
               return false;
            } else if(stringEquals(allCustomers[i].customerName, _customerName) && stringEquals(allCustomers[i].password, "temp")){
                //if match found update the passowrd
                allCustomers[i].password = _password;
                return true;
            }
        }
        return false;
    }
    
    /*function to return bankaddress from cutomer struct who last updated the customer record.
    @params : customerName 
    @return : bankaddress of bank who last updated the record.
    */ 
    function getAccessHistory(string memory _customerName) public payable returns(address){
        //validating customerName
        require(validateCustomer(_customerName));
        for(uint i = 0; i < allCustomers.length;i++) {
            //searching customerName in allCustomers array
            if(stringEquals(allCustomers[i].customerName,_customerName)){
                //return associated bank with customerName
                return allCustomers[i].bank;
            }
        }
    }
    
    /*function to return dataHash string.
    @params : customerName 
    @return : string dataHash with stringyfied data.
    */ 
    function viewCustomerData(string memory _customerName) public payable returns(string memory) {
        //validating customerName
        require(validateCustomer(_customerName));
        for(uint i = 0; i < allCustomers.length; ++ i) {
             //searching customerName in allCustomers array
            if(stringEquals(allCustomers[i].customerName, _customerName)) {
                //return dataHash of customer
                return allCustomers[i].dataHash;
            }
        }
    }
    
    /*function to return bankName string given bankAddress.
    @params : bankAddress 
    @return : string bankName
    */ 
    function getBankName(address _bankAddress) public payable returns(string memory){
        //validating bankAddress is correct or not.
        require(validateBank(_bankAddress));
        for(uint i=0;i<allBanks.length;i++){
            if(allBanks[i].ethAddress == _bankAddress){
                //return bank name.
                return allBanks[i].bankName;
            }
        }
    }
    
    /*function to return address bankAddress given bankName string.
    @params : bankName string 
    @return : address bankAddress
    */ 
    function getBankAddress(string memory _bankName) public payable returns(address){
        //validating the bankNamek
        require(validateBank(_bankName));
        for(uint i=0;i<allBanks.length;i++){
            //searching the bankName in allBanks array
            if(stringEquals(allBanks[i].bankName,_bankName)){
                //return associated bank ethAddress
                return allBanks[i].ethAddress;
            }
        }
    }
    
    //Customer Interface Ends>>>> Admin Interface Starts >>>
    /*function to add a bank into database by any admin bank or authorized entity.
    @params : bankName, bankAddress, Registration number
    @return : return 0 if bank added successful else return 1.
    */ 
    function addBank(string memory _bankName, address _bankAddress, string memory _regNum) public payable returns(uint) {
        //validating the msg.sender authorized
        // require(validateBank());
        //validating if bank already exist in database.
        require(!validateBank(_bankAddress));
        allBanks.length = allBanks.length + 1;
        //adding the bank data, by default rating is 1 and KYC_count 0.
        allBanks[allBanks.length - 1] = Bank(_bankName, _bankAddress, 1, 0, _regNum);
        return 0;
        if(allBanks.length<1) {
            //bank adding unsuccessfull!
            return 1;
        }
    }
    
    /*function to remove a bank from database by any admin bank or authorized entity.
    @params :  bankAddress
    @return : return 0 if bank added successful else return 1.
    */ 
    function removeBank(address _bankAddress) public payable returns(uint) {
        //validating the msg.sender authorized
        require(validateBank());
        //validating if bank exist in database or not?
        require(validateBank(_bankAddress));
        for(uint i=0;i<allBanks.length;i++){
            if(allBanks[i].ethAddress == _bankAddress){
                for(uint j = i+1;j<allBanks.length;j++){
                    //shifting all element one place to left, to complete remove opertion.
                    allBanks[j-1] = allBanks[j];
                }
                //reduce the array length by 1 element.
                allBanks.length = allBanks.length - 1;
                return 0;
            }
        }
        //bank removal unsuccessfull!
        return 1;
    }
    
    
    /*function to allow bank to perform KYC on request.
    @params : userName, bankAddress, isAllowed flag
    @return : return KYC status flag if bank added allowed then true, else false and remove the request.
    */ 
    function allowKYC(string memory _userName, address _bankAddress, bool _isAllowed) public payable returns (bool){
        //validateBank exist
        require(validateBank());
        //validate Customer exist
        require(validateCustomer(_userName));
        for(uint i=0;i<allRequests.length;i++){
            if(allRequests[i].bankAddress == _bankAddress && stringEquals(allRequests[i].userName,_userName)){
                if(_isAllowed){
                    //allowing kyc
                    allRequests[i].isAllowed = true;
                    return true;
                }else{
                    //remove the request since kyc not allowed. and return false
                    for(uint j = i+1;j<allRequests.length;j++){
                        allRequests[j-1] = allRequests[j];
                    }
                    allRequests.length--;
                    return false;
                }
            }
        
        }
        // KYC update unsuccessfull.
        return false;
    }    
    
    // Helper Functions Starts
     /*
    To validete the request bankname is a valid vaild or not
    @params : _bankName
    @return : true if bank is valid else false.
    */
    function validateBank(string memory _bankName) internal view returns(bool){
        for(uint i = 0; i < allBanks.length;i++) {
            if(stringEquals(allBanks[i].bankName,_bankName)){
                return true;
            }
        }
        return false;
    }
    
     /*
    To validete the request _bankAddress is a valid vaild or not
    @params : _bankAddress
    @return : true if bank is valid else false.
    */
    function validateBank(address _bankAddress) internal view returns(bool){
        for(uint i = 0; i < allBanks.length;i++) {
            if(allBanks[i].ethAddress == _bankAddress){
                return true;
            }
        }
        return false;
    }
    /*
    To validete the customerName is a valid vaild or not
    @params : _customerName
    @return : true if bank is valid else false.
    */
    function validateCustomer(string memory _customerName) internal view returns(bool){
        for(uint i = 0; i < allCustomers.length;i++) {
            if(stringEquals(allCustomers[i].customerName,_customerName))
                return true;
        }
        return false;
    }
    
    /*
    To validete the request sender is a valid vaild or not
    @params : -
    @return : true if bank is valid else false.
    */
    function validateBank() internal view returns(bool){
        for(uint i = 0; i < allBanks.length;i++) {
            if(allBanks[i].ethAddress == msg.sender)
                return true;
        }
        return false;
    }
    
    /*
    Function to compare two strings
    @params : strings firstString and secondString 
    @return : (bool)return true if string matches, and false if sting not matches.
    */
    function stringEquals(string memory firstString, string memory secondString ) internal  pure returns(bool){
        return (keccak256(abi.encodePacked(firstString)) == keccak256(abi.encodePacked(secondString)));
    }
    
    /*
    Function to calculate and return byte32 type requestID, data based on unique(userName + bankAddress) provided. 
    @params : userName, bankAddress
    @return : bytes32 requestID
    */
    function structToByte(string memory _userName, address _bankAddress) internal pure returns (bytes32){
        return keccak256(abi.encode(_userName,_bankAddress));
    }
    
    
}    
