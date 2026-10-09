import { LightningElement,wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccount';
import createNewAccount from '@salesforce/apex/AccountController.createNewAccount'
export default class CreateAccount extends LightningElement {
    accountName;
    maxRecords=10;
    errors;
    accounts;
    @wire (getAccounts,{ maxRecords:"$maxRecords"})
wired_getAccounts({errors,data}){
    if(data){
        this.accounts= data; this.error=undefined;
        }else if (errors){
            this.accounts=undefined;  this.errors=errors;
        }
}
    handleAccountNameChange(event){
        this.accountName=event.target.value;
    }
    handleMaxRecordsChange(event){
        this.maxRecords =event.target.value;
    }
handleCreateAccount(){
createNewAccount({accountName:this.accountName}).then(result=>{
console.log('Resultis :',result);
}).catch(error=>{
    console.log('error is occured',error)
})

}
}