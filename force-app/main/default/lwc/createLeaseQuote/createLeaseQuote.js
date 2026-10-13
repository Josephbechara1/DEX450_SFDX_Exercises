import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import LEASE_TYPE from '@salesforce/schema/Opportunity.Lease_Type__c';
const OPP_FIELDS = [LEASE_TYPE];
export default class CreateLeaseQuote extends  NavigationMixin(LightningElement) {

@api recordId; // opp id
    @track leaseType;
    @track startDate;
    @track durationYears;
    @track calculatedEndDate;
    @wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS}) wire__getRecord({error, data}) {
        if (data) {
            this.leaseType = getFieldValue(data, LEASE_TYPE);
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to fetch Opportunity Lease Type',
                    variant: 'error'
                })
            ); 
        }
    }
    get isOfficeOrRetail(){
        return this.leaseType === 'Office'  || this.leaseType === 'Retail';
    }
    get isRetail(){
        return this.leaseType === 'Retail';
    }
    get isLand(){
        return this.leaseType === 'Land';
    }
    // auto calculate end date for land lease
    handleStartDateChange(event){
        this.startDate = event.target.value;
        this.calculateLandEndDate();
    }
    handleDurationDate(event){
        this.durationYears = event.target.value;
        this.calculateLandEndDate();
    }
    calculateLandEndDate() {
        if (this.startDate && this.durationYears && this.durationYears >= 30) {
            let start = new Date(this.startDate);
            // Add years dynamically based on input duration value
            start.setFullYear(start.getFullYear() + parseInt(this.durationYears, 10));
            // Format to YYYY-MM-DD for lightning-input
            this.calculatedEndDate = start.toISOString().split('T')[0];
        } else {
            this.calculatedEndDate = null;
        }
    }
    // Inject calculated fields into the form submission payload
    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        
        // pass Opp Id reference
        fields.OpportunityId = this.recordId;
        if (this.isLand && this.calculatedEndDate) {
            fields.Proposed_End_Date__c = this.calculatedEndDate;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess(event) {
        this.showToast('Success', 'Quote created successfully!', 'success');
        
        // Navigate to the newly created Quote record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });
    }
    handleError(event) {
        this.showToast('Error saving record', event.detail.detail, 'error');
    }
    handleCancel() {
        // Navigate back to the parent Opportunity record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}