import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import addItemsToCart from '@salesforce/apex/B2BGridOrderingController.addItemsToCart';
import getProductsWithCategoriesAndPrices from '@salesforce/apex/B2BGridOrderingController.getProductsWithCategoriesAndPrices';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';

export default class B2BGridOrderingComponent extends LightningElement {
  @api effectiveAccountId;

  isLoading = true;
  activeSections = [];
  productsByCategory = [];
  productQuantities = {};
  @track successMessage;
  @track errorMessage;

  @track isCartLocked = true;

  get showErrorMessage() {
    return this.errorMessage != null;
  }

  get showSuccessMessage() {
    return this.successMessage != null;
  }

  connectedCallback() {
    getProductsWithCategoriesAndPrices({accountId: this.effectiveAccountId}).then(result => {
      if (result != null && result.length > 0) {
        this.productsByCategory = result;
      }
    }).finally(() => {
      this.isLoading = false;
    });
    this.updateCartInformation();
  }

  handleInputBlur(e) {
    const value = parseInt(e.target.value);
    if (isNaN(value) || value === "0" || value === "") {
      e.target.value = "0";
      delete this.productQuantities[e.target.name];
    } else {
      this.productQuantities[e.target.name] = value;
      e.target.value = value.toString();
    }
  }

  addToCart() {
    if (!this.isCartLocked) {
      this.successMessage = null;
      this.errorMessage = null;
      Object.keys(this.productQuantities).forEach(key => {
        const value = this.productQuantities[key];
        if (value == null || isNaN(value) || value < 1 || value > 9999) {
          delete this.productQuantities[key];
        } 
      });
      if (Object.keys(this.productQuantities).length > 0) {
        console.log('Adding to cart', this.productQuantities);
        this.isLoading = true;
        let itemList = [];
        this.productsByCategory.forEach(category => {
          category.products.forEach(p => {
            if (Object.keys(this.productQuantities).includes(p.product.Id)) {
              itemList.push({productId: p.product.Id, quantity: (this.productQuantities[p.product.Id]).toString()});
            }
          });
        });
        console.log('ItemList: ', itemList);
        addItemsToCart({itemList: itemList, accountId: this.effectiveAccountId, communityId: communityId})
        .then(res => {
          this.successMessage = 'Products successfully added to your cart.';
          this.template.querySelectorAll('lightning-input').forEach(i => i.value = "0");
          this.productQuantities = {};
        })
        .catch(err => {
          this.errorMessage = 'There was an error trying to add products to your cart.';
        })
        .finally(() => this.isLoading = false);
      } else {
        this.errorMessage = 'You do not have a valid quantity for any products.';
      }
    }
  }

  updateCartInformation() {
    getCartSummary({
      communityId: communityId,
      effectiveAccountId: this.effectiveAccountId
    })
    .then((result) => {
      if (result != null && result.status != null)
        this.isCartLocked = result.status === 'Processing' || result.status === 'Checkout';
    });
}
}