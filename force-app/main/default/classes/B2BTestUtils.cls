@isTest
public inherited sharing class B2BTestUtils{

    public B2BTestUtils() {
        Extended_Store_Settings__c settings = Extended_Store_Settings__c.getInstance();
        settings.Enable_Auto_Rebuild_Index__c = false;
        insert settings;
    }

    public static Id getNetworkId() {
        Map<String, Network> networkByName = new Map<String, Network>();
        for (Network n : [SELECT Name FROM Network WHERE Name IN ('Dealers', 'StarMilling')]) {
            networkByName.put(n.Name, n);
        }
        if (networkByName.containsKey('Dealers')) {
            return networkByName.get('Dealers').Id;
        }
        return networkByName.get('StarMilling').Id;
    }

    //product, catalogs and pricing objects
    private final List<Pricebook2> pricebooks = new List<Pricebook2>();
    private final List<Product2> products = new List<Product2>();
    private final List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    private final List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
    private final List<ProductCategoryProduct> productCategoryProducts = new List<ProductCategoryProduct>();
    private final List<ProductCategory> productCategories = new List<ProductCategory>();
    private final List<ProductCatalog> productCatalogs = new List<ProductCatalog>();


    //accounts, buyers and policies
    private final List<Account> accounts = new List<Account>();
    private final List<Contact> contacts = new List<Contact>();
    private final List<User> users = new List<User>();
    private final List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
    private final List<BuyerAccount> buyerAccounts = new List<BuyerAccount>();
    private final List<BuyerGroup> buyerGroups = new List<BuyerGroup>();
    private final List<BuyerGroupMember> buyerGroupMembers = new List<BuyerGroupMember>();
    private final List<BuyerGroupPricebook> buyerGroupPriceBooks = new List<BuyerGroupPricebook>();
    private final List<CommerceEntitlementPolicy> entitlementPolicies = new List<CommerceEntitlementPolicy>();
    private final List<CommerceEntitlementBuyerGroup> policyGroups = new List<CommerceEntitlementBuyerGroup>();
    private final List<CommerceEntitlementProduct> entitlementPolicyProducts = new List<CommerceEntitlementProduct>();

    //store related objects
    private final List<WebStore> stores = new List<WebStore>();
    private final List<WebStoreCatalog> storeCatalogs = new List<WebStoreCatalog>();
    private final List<WebStorePricebook> storePricebooks = new List<WebStorePricebook>();
    private final List<WebStoreBuyerGroup> storeBuyerGroups = new List<WebStoreBuyerGroup>();

    private String externalId {
        set;
        get {
            externalId = String.valueOf(externalId == null ? 0 : (Integer.valueOf(externalId) + 1));
            return externalId;
        }
    }

    public void upsertTestData(){
        Database.upsert(pricebooks, Pricebook2.ExternalId__c);
        Database.upsert(products, Product2.ExternalId__c);
        Database.upsert(standardPricebookEntries, PricebookEntry.ExternalId__c);
        Database.upsert(pricebookEntries, PricebookEntry.ExternalId__c);
        Database.upsert(productCatalogs, ProductCatalog.ExternalId__c);
        Database.upsert(productCategories, ProductCategory.ExternalId__c);
        Database.upsert(productCategoryProducts, ProductCategoryProduct.ExternalId__c);
        

        Database.upsert(accounts, Account.ExternalId__c);
        Database.upsert(contacts, Contact.ExternalId__c);
        Database.upsert(users, User.ExternalId__c);
                
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
            Database.upsert(permissionSetAssignments);
        }

        Database.upsert(buyerAccounts, BuyerAccount.ExternalId__c);
        Database.upsert(buyerGroups, BuyerGroup.ExternalId__c);
        Database.upsert(buyerGroupMembers);
        Database.upsert(buyerGroupPriceBooks, BuyerGroupPricebook.ExternalId__c);
        Database.upsert(entitlementPolicies, CommerceEntitlementPolicy.ExternalId__c);
        Database.upsert(policyGroups, CommerceEntitlementBuyerGroup.ExternalId__c);
        Database.upsert(entitlementPolicyProducts, CommerceEntitlementProduct.ExternalId__c);

        Database.upsert(stores, WebStore.ExternalId__c);

        Database.upsert(storeCatalogs, WebStoreCatalog.ExternalId__c);
        Database.upsert(storePricebooks, WebStorePricebook.ExternalId__c);
        Database.upsert(storeBuyerGroups, WebStoreBuyerGroup.ExternalId__c);
    }


    public void setupStore(){
        WebStore store = getStore('Test Store');
        setupStore(store, false);
    }


    public void setupStore(Webstore store, Boolean isSeeAllData){
        if (isSeeAllData) {
            store.ExternalId__c = externalId;
            update store;
        }
        //Pricing
        Pricebook2 pb = getPricebook('Test Store Pricebook');
        List<Product2> productList = getProducts(3);
        List<PricebookEntry> standardPricebookEntryList = getStandardPricebookEntries(productList);
        List<PricebookEntry> pricebookEntryList = getPricebookEntries(productList, pb);
        ProductCatalog prodCatalog = getProductCatalog('Test Store Catalog');
        ProductCategory prodCategory = getProductCategory('Test Category', prodCatalog);
        List<ProductCategoryProduct> prodCatProducts = getProductCategoryProducts(prodCategory, productList);

        //Accounts, Buyers, Buyer Groups and Policies
        Account acct = getAccount('Store Account');
        Contact buyerContact = getContact(acct, 'Test', 'Buyer', 'storebuyercontact@b2btestutils.test');
        Contact managerContact = getContact(acct, 'Test', 'Manager', 'storemanagercontact@b2btestutils.test');
        User buyerUser = getUser(buyerContact);
        User managerUser = getUser(managerContact);

        PermissionSetAssignment buyerPerm = getBuyerPermSetAssignment(buyerUser);
        PermissionSetAssignment managerPerm = getManagerPermSetAssignment(managerUser);
        
        BuyerAccount buyerAccount = getBuyerAccount('Test Buyer Account', acct);
        BuyerGroup buyerGroup = getBuyerGroup('Test Buyer Group');
        BuyerGroupMember buyerGroupMember = getBuyerGroupMember(acct, buyerGroup);
        BuyerGroupPricebook buyerGroupPricebook = getBuyerGroupPricebook(buyerGroup, pb);
        CommerceEntitlementPolicy entitlementPolicy = getEntitlementPolicy('Test Policy');
        CommerceEntitlementBuyerGroup policyGroup = getPolicyGroup(buyerGroup, entitlementPolicy);
        List<CommerceEntitlementProduct> policyProducts = getEntitlementPolicyProducts(productList, entitlementPolicy);

        //Stores
        //WebstoreNetwork = new WebstoreNetwork(Webstore = new Webstore(ExternalId__c = store.ExternalId__c), NetworkId = Network.getNetworkId());
        if (!isSeeAllData) {
        	WebStoreCatalog storeCatalog = getStoreCatalog(prodCatalog, store);
        }
        WebStoreBuyerGroup storeBuyerGroup = getStoreBuyerGroup(buyerGroup, store);

        upsertTestData();
        
    }

    //Pricebook related objects creation
    public Pricebook2 getPricebook(String name){
        Pricebook2 pb = new Pricebook2();
        pb.Name = name;
        pb.isActive = true;
        pb.ExternalId__c = externalId;

        pricebooks.add(pb);
        return pb;
    }

    public List<Product2> getProducts(Integer numOfProducts){
        List<Product2> productList = new List<Product2>();
        for(Integer i = 1; i <= numOfProducts; i++){
            Product2 p = new Product2();

            p.Name = 'Test Product ' + i;
            p.ExternalId__c = externalId;

            products.add(p);
            productList.add(p);
        }

        return productList;
    }

    public List<PricebookEntry> getStandardPricebookEntries(List<Product2> products) {
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for (Product2 p : products) {
            PricebookEntry entry = new PricebookEntry();
            
            entry.ExternalId__c = externalId;
            entry.isActive = true;
            entry.UnitPrice = 10;
            entry.Product2 = new Product2(ExternalId__c = p.ExternalId__c);
            entry.Pricebook2Id = Test.getStandardPriceBookId();
            entry.UseStandardPrice = false;

            standardPricebookEntries.add(entry);
            pricebookEntryList.add(entry);
        }

        return pricebookEntryList;
    }

    public List<PricebookEntry> getPricebookEntries(List<Product2> products, Pricebook2 pricebook) {
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for (Product2 p : products) {
            PricebookEntry entry = new PricebookEntry();
            
            entry.ExternalId__c = externalId;
            entry.isActive = true;
            entry.UnitPrice = 10;
            entry.Product2 = new Product2(ExternalId__c = p.ExternalId__c);
            entry.Pricebook2 = new Pricebook2(ExternalId__c = pricebook.ExternalId__c);
            entry.UseStandardPrice = false;

            pricebookEntries.add(entry);
            pricebookEntryList.add(entry);
        }

        return pricebookEntryList;
    }

    public ProductCatalog getProductCatalog(String Name){
        ProductCatalog catalog = new ProductCatalog();
        catalog.Name = Name;
        catalog.ExternalId__c = externalId;

        productCatalogs.add(catalog);
        return catalog;
    }

    public ProductCategory getProductCategory(String Name, ProductCatalog catalog){
        ProductCategory category = new ProductCategory();
        category.Name = Name;
        category.Catalog = new ProductCatalog(ExternalId__c = catalog.ExternalId__c);
        category.ExternalId__c = externalId;

        productCategories.add(category);
        return category;
    }

    public List<ProductCategoryProduct> getProductCategoryProducts(ProductCategory category, List<Product2> productList){
        List<ProductCategoryProduct> productCategoryProductList = new List<ProductCategoryProduct>();
        for(Product2 p : productList){
            ProductCategoryProduct prodCatProd = new ProductCategoryProduct();
            prodCatProd.Product = new Product2(ExternalId__c = p.ExternalId__c);
            prodCatProd.ProductCategory = new ProductCategory(ExternalId__c = category.ExternalId__c);
            prodCatProd.ExternalId__c = externalId;

            productCategoryProductList.add(prodCatProd);
            productCategoryProducts.add(prodCatProd);
        }
        return productCategoryProductList;
    }

    //Buyer Account, Buyer Group related objects creation
    public Account getAccount(String Name){
        Account a = new Account();
        a.Name = Name;
        a.ExternalId__c = externalId;

        accounts.add(a);
        return a;
    }

    public Contact getContact(Account acct, String firstName, String lastName, String email){
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Email = email;
        c.ExternalId__c = externalId;
        c.Account = new Account(ExternalId__c = acct.ExternalId__c);

        contacts.add(c);
        return c;
    }

    public User getUser(Contact contact) {
        User u = new User();
        u.contact = new Contact(ExternalId__c = contact.ExternalId__c);
        u.ExternalId__c = externalId;
        u.Alias = contact.ExternalId__c;
        u.Username = contact.email;
        u.Email = contact.email;
        u.FirstName = contact.firstName;
        u.LastName = contact.LastName;
        u.LocaleSIDKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSIDKey = 'America/New_York';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];
        u.ProfileId = p.id;

        users.add(u);
        return u;
    }

    public PermissionSetAssignment getBuyerPermSetAssignment(User user) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Commerce_User' LIMIT 1];
        psa.assignee = new User(ExternalId__c = user.ExternalId__c);
        psa.PermissionSetId = pset.Id;

        permissionSetAssignments.add(psa);
        return psa;
    }

    public PermissionSetAssignment getManagerPermSetAssignment(User user) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Commerce_Super_User' LIMIT 1];
        psa.assignee = new User(ExternalId__c = user.ExternalId__c);
        psa.PermissionSetId = pset.Id;

        permissionSetAssignments.add(psa);
        return psa;
    }

    public BuyerAccount getBuyerAccount(String Name, Account account){
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.Name = Name;
        buyerAccount.IsActive = true;
        buyerAccount.Buyer = new Account(ExternalId__c = account.ExternalId__c);
        buyerAccount.ExternalId__c = externalId;

        buyerAccounts.add(buyerAccount);
        return buyerAccount;
    }

    public BuyerGroup getBuyerGroup(String Name){
        BuyerGroup buyerGroup = new BuyerGroup();
        buyerGroup.Name = Name;
        buyerGroup.ExternalId__c = externalId;

        buyerGroups.add(buyerGroup);
        return buyerGroup;
    }

    public BuyerGroupMember getBuyerGroupMember(Account account, BuyerGroup buyerGroup) {
        B2BTestUtilsBuyerHelper helper = new B2BTestUtilsBuyerHelper();
        BuyerGroupMember member = helper.getBuyerGroupMember(account, buyerGroup);

        buyerGroupMembers.add(member);
        return member;
    }

    public BuyerGroupPricebook getBuyerGroupPricebook(BuyerGroup buyerGroup, Pricebook2 pricebook){
        BuyerGroupPricebook buyerGroupPricebook = new BuyerGroupPricebook();
        buyerGroupPricebook.BuyerGroup = new BuyerGroup(ExternalId__c = buyerGroup.ExternalId__c);
        buyerGroupPricebook.Pricebook2 = new Pricebook2(ExternalId__c = pricebook.ExternalId__c);
        buyerGroupPricebook.ExternalId__c = externalId;

        buyerGroupPriceBooks.add(buyerGroupPricebook);
        return buyerGroupPricebook;
    }

    public CommerceEntitlementPolicy getEntitlementPolicy(String Name){
        CommerceEntitlementPolicy policy = new CommerceEntitlementPolicy();
        policy.Name = Name;
        policy.isActive = true;
        policy.canViewPrice = true;
        policy.canViewProduct = true;
        policy.ExternalId__c = externalId;

        entitlementPolicies.add(policy);
        return policy;
    }

    public List<CommerceEntitlementProduct> getEntitlementPolicyProducts(List<Product2> products, CommerceEntitlementPolicy policy){
        List<CommerceEntitlementProduct> policyProducts = new List<CommerceEntitlementProduct>();
        for (Product2 product : products) {
            CommerceEntitlementProduct cep = new CommerceEntitlementProduct();
            cep.Product = new Product2(ExternalId__c = product.ExternalId__c);
            cep.Policy = new CommerceEntitlementPolicy(ExternalId__c = policy.ExternalId__c);
            cep.ExternalId__c = externalId;
            
            entitlementPolicyProducts.add(cep);
            policyProducts.add(cep);
        }
        return policyProducts;
    }

    public CommerceEntitlementBuyerGroup getPolicyGroup(BuyerGroup buyerGroup, CommerceEntitlementPolicy policy){
        CommerceEntitlementBuyerGroup policyGroup = new CommerceEntitlementBuyerGroup();
        policyGroup.BuyerGroup = new BuyerGroup(ExternalId__c = buyerGroup.ExternalId__c);
        policyGroup.Policy = new CommerceEntitlementPolicy(ExternalId__c = policy.ExternalId__c);
        policyGroup.ExternalId__c = externalId;

        policyGroups.add(policyGroup);
        return policyGroup;
    }

    //Store related objects creation
    public WebStore getStore(String Name){
        WebStore store = new WebStore();
        store.Name = Name;
        store.ExternalId__c = externalId;

        stores.add(store);
        return store;
    }

    public WebStoreCatalog getStoreCatalog(ProductCatalog catalog, Webstore store){
        WebStoreCatalog storeCatalog = new WebStoreCatalog();
        storeCatalog.ProductCatalog = new ProductCatalog(ExternalId__c = catalog.ExternalId__c);
        storeCatalog.SalesStore = new WebStore(ExternalId__c = store.ExternalId__c);
        storeCatalog.ExternalId__c = externalId;

        storeCatalogs.add(storeCatalog);
        return storeCatalog;
    }

    public WebStoreBuyerGroup getStoreBuyerGroup(BuyerGroup buyerGroup, WebStore store){
        WebStoreBuyerGroup storeBuyerGroup = new WebStoreBuyerGroup();
        storeBuyerGroup.BuyerGroup = new BuyerGroup(ExternalId__c = buyerGroup.ExternalId__c);
        storeBuyerGroup.WebStore = new WebStore(ExternalId__c = store.ExternalId__c);
        storeBuyerGroup.ExternalId__c = externalId;

        storeBuyerGroups.add(storeBuyerGroup);
        return storeBuyerGroup;
    }

    public virtual class MockConnectApiServiceAdapter implements ConnectApiService {
        public ConnectApi.PricingResult pricingResult = new ConnectApi.PricingResult();
        public ConnectApi.ProductCategoryPath categoryPath = new ConnectApi.ProductCategoryPath();
        public ConnectApi.CartSummary cartSummary = new ConnectApi.CartSummary();
        public ConnectApi.CartItem cartItem = new ConnectApi.CartItem();
        
        public virtual ConnectApi.PricingResult getProductPrices(String webStoreId, String effectiveAccountId, ConnectApi.PricingInput pricingInput) {
          return null;
        }
        public virtual ConnectApi.ProductCategoryPath getProductCategoryPath(String webstoreId, String productCategoryId) {
            return null;
        }
        public virtual ConnectApi.CartSummary getCartSummary(String webstoreId, String effectiveAccountId, String activeCartOrId) {
            return null;
        }
        public virtual ConnectApi.CartItem addItemToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, ConnectApi.CartItemInput cartInput) {
            return null;
        }
        public virtual List<ConnectApi.BatchResult> addItemsToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, List<ConnectApi.BatchInput> cartItems) {
            return null;
        }
        
        public virtual void setupMockPricingResults() {
            this.pricingResult.success = true;
            this.pricingResult.currencyIsoCode = 'USD';
            List<ConnectApi.PricingResultLineItem> items = new List<ConnectApi.PricingResultLineItem>();
            ConnectApi.PricingResultLineItem p1 = new ConnectApi.PricingResultLineItem();
            p1.success = true;
            p1.unitPrice = '10.00';
            p1.listPrice = '12.00';
            p1.productId = 'MockProduct1Id';
            p1.pricebookEntryId = 'MockPBEntry1Id';
            items.add(p1);
            ConnectApi.PricingResultLineItem p2 = new ConnectApi.PricingResultLineItem();
            p2.success = true;
            p2.unitPrice = '20.00';
            p2.listPrice = '22.00';
            p2.productId = 'MockProduct2Id';
            p2.pricebookEntryId = 'MockPBEntry2Id';
            items.add(p2);
            ConnectApi.PricingResultLineItem p3 = new ConnectApi.PricingResultLineItem();
            p3.success = true;
            p3.unitPrice = '30.00';
            p3.listPrice = '32.00';
            p3.productId = 'MockProduct3Id';
            p3.pricebookEntryId = 'MockPBEntry3Id';
            items.add(p3);
            this.pricingResult.pricingLineItemResults = items;
        }
        
        public virtual void setupMockProductCategoryPath() {
            List<ConnectApi.ProductCategoryData> pathList = new List<ConnectApi.ProductCategoryData>();
            ConnectApi.ProductCategoryData cat1 = new ConnectApi.ProductCategoryData();
            cat1.id = 'MockCategory1Id';
            cat1.name = 'Category1';
            cat1.description = 'Description for Category1';
            pathList.add(cat1);
            ConnectApi.ProductCategoryData cat2 = new ConnectApi.ProductCategoryData();
            cat2.id = 'MockCategory2Id';
            cat2.name = 'Category2';
            cat2.description = 'Description for Category2';
            pathList.add(cat2);
            this.categoryPath.path = pathList;
        }
        
        public virtual void setupMockCartSummary() {
            this.cartSummary.accountId = [SELECT Id FROM Account WHERE Name = 'Store Account' LIMIT 1].Id;
            this.cartSummary.cartId = 'MockCartId';
            this.cartSummary.currencyIsoCode = 'USD';
            this.cartSummary.grandTotalAmount = '131.60';
            this.cartSummary.name = 'Cart Summary Name';
            this.cartSummary.ownerId = 'MockOwnerId';
            this.cartSummary.purchaseOrderNumber = '12345';
            this.cartSummary.status = ConnectApi.CartStatus.Active;
            this.cartSummary.totalChargeAmount = '15.00';
            this.cartSummary.totalListPrice = '110.00';
            this.cartSummary.totalProductAmount = '110.00';
            this.cartSummary.totalProductCount = '6';
            this.cartSummary.totalTaxAmount = '6.60';
            this.cartSummary.type = ConnectApi.CartType.Cart;
            this.cartSummary.uniqueProductCount = 3;
            this.cartSummary.webstoreId = [SELECT Id FROM Webstore WHERE Name = 'Test Store' LIMIT 1].Id;
        }
        
        public virtual void setupMockCartItem() {
            this.cartItem.listPrice = '12.00';
            this.cartItem.salesPrice = '10.00';
            this.cartItem.totalAdjustmentAmount = '0.00';
            this.cartItem.totalAmount = '10.00';
            this.cartItem.totalListPrice = '10.00';
            this.cartItem.totalPrice = '10.00';
            this.cartItem.totalTax = '0.60';
      }
  }

}