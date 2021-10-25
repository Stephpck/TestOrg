import { LightningElement, wire, api, track } from 'lwc';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { refreshApex } from '@salesforce/apex';
import getCartSummary from '@salesforce/apex/B2BCheckoutSummaryController.getCartSummary';


// Import message service features required for subscribing and the message channel
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from 'lightning/messageService';

export default class B2bCartTotals extends LightningElement {
  subscription = null;

  @track cartTotal;
  @track cartTotalTons;

  @wire(getCartSummary, {cartId: '$cartId'})
  wireCart(result) {
    this.wireResults = result;
    if(result.data) {
      this._cart = result.data.cart;
      this.cartTotal = this._cart.GrandTotalAmount || 0;
      this.cartTotalTons = this._cart.TotTons__c || 0;
    } else if(result.error) {
      console.error(result.error);
    }
  }

  //this is part of the update cart subscription
  @wire(MessageContext) messageContext;

  @api
  get cartId() {
    return this._cartId;
  }
  set cartId(value) {
    this._cartId = value;
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  /**
   * sets up subscription to the cart changed event
   */
  subscribeToMessageChannel() {
    if(!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        cartChanged,
        (message) => refreshApex(this.wireResults),
        { scope: APPLICATION_SCOPE }
      )
    }
  }

  /**
   * unsubscribes to the cart changed event.
   * if this doesn't happen before the component is disconnected
   * then there can be some hanging event listeners in the app
   */
  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }
  
  get showMinWeightMessage() {
    return this.cartTotalTons < 3;
  }
  
  _cartId;
  _cart;
}