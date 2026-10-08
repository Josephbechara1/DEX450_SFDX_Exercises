import { LightningElement, track } from 'lwc';

export default class Exercice1 extends LightningElement {
    employees = [
        { id: 1, name: 'John Smith', department: 'IT', position: 'Developer' },
        { id: 2, name: 'Sarah Johnson', department: 'HR', position: 'Recruiter' },
        { id: 3, name: 'Mike Brown', department: 'IT', position: 'QA Engineer' },
        { id: 4, name: 'Emma Davis', department: 'Finance', position: 'Accountant' },
        { id: 5, name: 'Chris Wilson', department: 'HR', position: 'HR Manager' }
    ];

    @track selectedDept = '';
    @track selectedEmployee = null; // Stays null until an employee link is clicked

    get departmentOptions() {
        const uniqueDepts = [...new Set(this.employees.map(emp => emp.department))];
        return uniqueDepts.map(dept => ({ label: dept, value: dept }));
    }

    handleDropdownChange(event) {
        this.selectedDept = event.detail.value;
        this.selectedEmployee = null; // Automatically clear the old detail card when swapping departments
    }

    // FIXED: Now filters directly using the active dropdown selection
    get filterEmployees() {
        if (!this.selectedDept) {
            return [];
        }
        return this.employees.filter(emp => emp.department === this.selectedDept);
    }

    get hasEmployees() {
        return this.filterEmployees.length > 0;
    }

    handleEmployeeClick(event) {
        event.preventDefault();
        const targetId = parseInt(event.currentTarget.dataset.id, 10);
        this.selectedEmployee = this.employees.find(emp => emp.id === targetId);
    }
}
