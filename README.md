# Banking_KYC_Solidity_Ethereum_Truffle


Please follow below details to test functionalities of Kyc smart contract:

Kyc Smart Contract Description:

contact Name : Kyc

Data Models: 
	Customer type struct
	Bank type struct
	request type struct
	allCustomers type array
    	allRequests type array
    	allBanks type array
    	requests type mapping 
    	_requestIDs type array

Functions :
	addRequest 			: Function to add a KYC request.
	removeRequest 		: Function to remove request for KYC.
	addCustomer 		: Function to add customer data by bank.
	removeCustomer 		: Function to remove customer data from system.
	modifyCustomer 		: Function to modify customer data from system.
	viewCustomer 		: Function to view customer data from system.
	getBankRequest 		: Function to get bank requests details for a 						  specific to a bank
	getRequest 			: Function Fetch the request details from 						  requestID.
	UpdateRatingCustomer    : Function to update customer rating by 							  bankAddress
	updateRatingBank    	: Function to update bank rating based on KYC 						  performance.
	getCustomerRating		: Function to return the cutomer current rating.
	getBankRating		: Function to fetch and return the bank current 					  rating.
	setPassword			: Function to setPassword for Customer from the 					  temp one assigned at the time of creation.
	getAccessHistory		: Function to return bankaddress from cutomer 						  struct who last updated the customer record.
	viewCustomerData		: Function to return dataHash string.
	getBankName			: Function to return bankName string given 						  bankAddress.
	getBankAddress		: Function to return address bankAddress given 						  bankName string.
	addBank			: Function to add a bank into database by any 						  admin bank or authorized entity.
	removeBank			: Function to remove a bank from database by any 					  admin bank or authorized entity.
	allowKYC			: Function to allow bank to perform KYC on 						  request.
Internal Helper Functions:
	validateBank(msg.sender)
	validateCustomer
	stringEquals
	validateBank
	structToByte



Test scenarios:

(Note: for testing, I used my coinbase address "0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da")

	1. adding a bank to Kyc database								call addBank() functions by passing parameters string memory _bankName, 	address _bankAddress, string memory _regNum
	e.g. 			addBank("AAA","0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da","100");
	expected O/P: 0

	2. adding a customer to kyc database.
	call addCustomer() function by passing parameters string memory 	_customerName, string memory _dataHash
	e.g. addCustomer("alpha","58385735597987475947747547");
	expected O/P: 0

	3. adding a Kyc request to database
	call addRequest() fuinction by passing parameters string memory 	_customerName, address _bankAddress
	e.g. addRequest("alpha","0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da");
	expected O/P: 0 

	4. allowing bank to perform KYC.
	call allowKYC() function by passing	parameters string memory _userName, 	address _bankAddress, bool _isAllowed
	e.g. allowKYC("alpha","0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da",true);
	expected O/P: true

	5. get bank address who last updated the passed customer record.
	call getAccessHistory() function by passing parameters string memory 	_customerName
	e.g. getAccessHistory("alpha");
	expected O/P: "0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da"

	6. get bank address by passing bank name.
	call getBankAddress() function by passing parameters string memory 	_bankName
	e.g. getBankAddress("AAA");
	expected O/P: "0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da"

	7. get bank name by passing bank address.
	call getBankName() function by passing parameters address _bankAddress
	e.g. getBankAddress("0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da");
	expected O/P: "AAA"	

	8. get bank rating by passing bank address.
	call getBankRating() function by passing parameters address _bankAddress
	e.g. getBankRating("0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da");
	expected O/P: "1" (bank rating default is set to 1.)

	9. get customer rating by passing bank address.
	call getCustomerRating() function by passing parameters string memory 	_customerName
	e.g. getCustomerRating("alpha");
	expected O/P: "1" (rating default is set to 1.)	

	10. modify customer data hash.
	call modifyCustomer() function by passing parameters string memory 	_customerName,string memory _dataHash
	e.g. modifyCustomer("alpha","786798938785798475929886592698169");
	expected O/P: 0

	11. setting up a customer password.
	call setPassword() function	by passing parameters string memory 	_customerName, string memory _password
	e.g. setPassword("alpha","password");
	expected O/P: true

	12. upvoting customer rating.
	call updateRatingCustomer() function by passing parameters string memory 	_customerName, bool _isUpvote
	e.g. updateRatingCustomer("alpha",true);
	expected O/P: 0	 

	13. upvoting Bank rating.
	call updateRatingBank() function by passing parameters address 	_bankAddress, bool _isKYCValid
	e.g. updateRatingBank("0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da",true);
	expected O/P: 0	

	14. view customer datahash.
	call viewCustomer() function by passing parameters string memory 	_customerName
	e.g. viewCustomer("alpha");
	expected O/P: sting datahash

	15. view customer datahash.
	call viewCustomerData() function by passing parameters string memory 	_customerName
	e.g. viewCustomerData("alpha");
	expected O/P: sting datahash	

	16. remove the request from database.
	call removeRequest() function by passing parameters string memory 	_customerName,address _bankAddress
	e.g. removeRequest("alpha","0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da");
	expected O/P: 0

	17. remove the customer from database.
	call removeCustomer() function by passing parameters string memory 	_customerName
	e.g. removeCustomer("alpha");
	expected O/P: 0

	18. remove the bank from database.
	call removeBank() function by passing parameters address _bankAddress
	e.g. removeBank("0x3e30dc5850a44b6c75eaf5ef1561e13c5b1be8da");
	expected O/P: 0	

		
