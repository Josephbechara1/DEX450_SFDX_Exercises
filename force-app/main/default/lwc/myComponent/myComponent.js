import { LightningElement,api,wire,track } from 'lwc';
import getRelatedContacts from '@salesforce/apex/AccountContactController.getRelatedContacts';
import deleteSingleContact from '@salesforce/apex/AccountContactController.deleteSingleContact';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ACTIONS = [
    { label: 'Delete', name: 'delete', iconName: 'utility:delete' }
];

const COLUMNS = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { type: 'action', typeAttributes: { rowActions: ACTIONS } }
];
export default class MyComponent extends LightningElement {
@api async invoke(){
        await MyComponent.open({
            size: 'medium',
            accountId: this.recordId
        })
    }
 @api recordId; 
    @track contacts = [];
    columns = COLUMNS;
    isLoading = false;
    isCreateModalOpen = false;
    wiredContactsResult;

    @wire(getRelatedContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Failed to load contacts.', 'error');
            this.contacts = [];
        }
    }

    // Modal Control Logic
    openCreateModal() {
        this.isCreateModalOpen = true;
    }

    closeCreateModal() {
        this.isCreateModalOpen = false;
    }

    // Handle Datatable Action Menu click triggers
 // Replace the old handleRowAction method with this one:
handleCardDeleteClick(event) {
    // Captures data-id from the specific button-icon clicked
    const contactIdToDelete = event.currentTarget.dataset.id; 
    if (contactIdToDelete) {
        this.processDeleteContact(contactIdToDelete);
    }
}


    // Delete isolated Contact Row
    async processDeleteContact(contactIdToDelete) {
        this.isLoading = true;
        try {
            await deleteSingleContact({ contactId: contactIdToDelete });
            this.showToast('Success', 'Contact deleted successfully.', 'success');
            await refreshApex(this.wiredContactsResult);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Could not delete contact.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Contact Creation Form Success Callbacks
    async handleContactCreateSuccess() {
        this.showToast('Success', 'New Contact added successfully.', 'success');
        this.closeCreateModal();
        this.isLoading = true;
        await refreshApex(this.wiredContactsResult);
        this.isLoading = false;
    }

    handleContactCreateError(event) {
        this.showToast('Error Creating Record', event.detail.detail, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}