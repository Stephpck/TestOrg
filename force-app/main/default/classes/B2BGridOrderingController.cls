public with sharing class B2BGridOrderingController {
    @TestVisible
    private static ConnectApiService connectApiSvc = new ConnectApiServiceImpl();

    @AuraEnabled
    public static List<ProductsByCategoryWrapper> getProductsWithCategoriesAndPrices(Id accountId) {
        List<ProductCategory> categories = [SELECT Id, Name FROM ProductCategory ORDER By ProductCategory.SortOrder ASC];
        Map<Id, PricebookEntry> productMap = new B2BProductService().getProductMap(accountId);
        List<ProductCategoryProduct> categoryProducts = [SELECT ProductCategory.Id, ProductCategory.Name, ProductCategory.SortOrder, IsPrimaryCategory, ProductId, Product.Sort_Order__c
                                                         FROM ProductCategoryProduct
                                                         WHERE ProductId IN :productMap.keySet()
                                                         ORDER By ProductCategory.SortOrder ASC, Product.Sort_Order__c ASC, Product.Name ASC];
                                                         
        
        Map<Id, List<ProductWrapper>> categoryProductsMap = new Map<Id, List<ProductWrapper>>();
        for (ProductCategoryProduct categoryProduct : categoryProducts) {
            PriceBookEntry entry = productMap.get(categoryProduct.ProductId);
            ProductWrapper wrapper = new ProductWrapper(entry.Product2, entry.UnitPrice, entry.Pallet_Price_Formula__c);
            if (categoryProductsMap.containsKey(categoryProduct.ProductCategory.Id)) {
                categoryProductsMap.get(categoryProduct.ProductCategory.Id).add(wrapper);
            } else {
                List<ProductWrapper> wrappers = new List<ProductWrapper>();
                wrappers.add(wrapper);
                categoryProductsMap.put(categoryProduct.ProductCategory.Id, wrappers);
            }
        }
        List<ProductsByCategoryWrapper> result = new List<ProductsByCategoryWrapper>();
        for (ProductCategory category : categories) {
            if (categoryProductsMap.containsKey(category.Id) && categoryProductsMap.get(category.Id).size() > 0) {
                result.add(new ProductsByCategoryWrapper(category.Name, categoryProductsMap.get(category.Id)));
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static Boolean addItemsToCart(List<ProductQuantity> itemList, Id accountId, Id communityId){
        Boolean validCart = true;
        Id webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();
        System.debug('ItemList: '+itemList);
        for(ProductQuantity item : itemList){
            ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
            cartItemInput.productId = item.productId;
            cartItemInput.quantity = item.quantity;
            cartItemInput.type = ConnectApi.CartItemType.PRODUCT;

            ConnectApi.BatchInput bI = new ConnectApi.BatchInput(cartItemInput);
            batchInputList.add(bI);
        }
        System.debug('BatchInputList: '+batchInputList);
        connectApiSvc.addItemsToCart(webstoreId, accountId, 'current', batchInputList);

        return validCart;
    }

    public class ProductsByCategoryWrapper {
        @AuraEnabled
        public String categoryName;

        @AuraEnabled
        public List<ProductWrapper> products;

        public ProductsByCategoryWrapper(String categoryName, List<ProductWrapper> products) {
            this.categoryName = categoryName;
            this.products = products;
        }
    }

    public class ProductWrapper {
        @AuraEnabled
        public Product2 product;

        @AuraEnabled
        public Decimal price;

        @AuraEnabled
        public Decimal palletPrice;

        public ProductWrapper(Product2 product, Decimal price, Decimal palletPrice) {
            this.product = product;
            this.price = price;
            this.palletPrice = palletPrice;
        }
    }

    public class ProductQuantity {
        @AuraEnabled
        public Id productId {get; set;}

        @AuraEnabled
        public String quantity  {get; set;}
    }
}