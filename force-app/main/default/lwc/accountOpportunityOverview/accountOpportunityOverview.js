import { LightningElement,wire,track} from 'lwc';
import getAccountOpportunities from '@salesforce/apex/AccountOpportunityController.getAccountOpportunities';
import updateOpportunityStage from '@salesforce/apex/AccountOpportunityController.updateOpportunityStage';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountOpportunityOverview extends LightningElement {

  @track accountData;
    @track isLoading = true;
    @track isModalOpen = false;
    
    selectedOppId;
    selectedStageValue = '';
    wiredDataResult;

    // Simple option array configuration
    get stageOptions() {
        return [
            { label: 'Closed Won', value: 'Closed Won' },
            { label: 'Closed Lost', value: 'Closed Lost' }
        ];
    }

    // Basic wire connector method
    @wire(getAccountOpportunities)
    wiredAccounts(result) {
        this.wiredDataResult = result;
        if (result.data) {
            this.accountData = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.showToast('Error', 'Failed to load data', 'error');
            this.isLoading = false;
        }
    }

    handleMarkAsClosedClick(event) {
        this.selectedOppId = event.target.dataset.id; // Get the id from the row button clicked
        this.selectedStageValue = ''; 
        this.isModalOpen = true; // Open popup
    }

    closeModalDialog() {
        this.isModalOpen = false;
    }

    handleStageDropdownChange(event) {
        this.selectedStageValue = event.target.value;
    }

    handleStageUpdateSubmit() {
        if (this.selectedStageValue === '') {
            this.showToast('Error', 'Please select a stage value', 'error');
            return;
        }

        this.isLoading = true;
        this.isModalOpen = false;

        // Basic Trainee Imperative Server Call Structure
        updateOpportunityStage({ oppId: this.selectedOppId, newStage: this.selectedStageValue })
            .then(() => {
                this.showToast('Success', 'Opportunity Updated Successfully', 'success');
                return refreshApex(this.wiredDataResult); // Refreshes the display list instantly
            })
            .catch(error => {
                this.showToast('Error', 'Failed to update record', 'error');
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}