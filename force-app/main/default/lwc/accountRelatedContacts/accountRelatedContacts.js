import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRelatedContacts from '@salesforce/apex/AccountContactController.getRelatedContacts';
import deleteContact from '@salesforce/apex/AccountContactController.deleteContact';

// Définition des colonnes de la datatable incluant le bouton d'action "Delete"
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

export default class AccountRelatedContacts extends LightningElement {
    @api recordId; // ID du compte automatiquement injecté par Salesforce
    
    @track isContactsModalOpen = false;
    @track isCreateModalOpen = false;
    
    columns = COLUMNS;
    contacts = [];
    wiredContactsResult; // Stocke le résultat du wire pour pouvoir le rafraîchir

    // Récupération automatique des contacts liés via Apex wire
    @wire(getRelatedContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error fetching contacts', 'error');
        }
    }

    // Gestion de la visibilité des modales
    openContactsModal() {
        this.isContactsModalOpen = true;
        // Rafraîchit les données au cas où des modifications externes auraient eu lieu
        refreshApex(this.wiredContactsResult); 
    }

    closeContactsModal() {
        this.isContactsModalOpen = false;
    }

    openCreateModal() {
        this.isCreateModalOpen = true;
    }

    closeCreateModal() {
        this.isCreateModalOpen = false;
    }

    // Gestion du clic sur une action de la datatable
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'delete') {
            this.handleDeleteContact(row.Id);
        }
    }

    // Méthode de suppression de contact
    handleDeleteContact(contactId) {
        deleteContact({ contactId: contactId })
            .then(() => {
                this.showToast('Success', 'Contact deleted successfully', 'success');
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Succès lors de la création d'un contact via lightning-record-edit-form
    handleContactSuccess() {
        this.showToast('Success', 'Contact created successfully', 'success');
        this.closeCreateModal();
        refreshApex(this.wiredContactsResult); // Actualise la table
    }

    // Utilitaire pour afficher les notifications Toast
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
