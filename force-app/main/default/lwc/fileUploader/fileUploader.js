import { LightningElement } from 'lwc';
import processFileWithBulkAPI  from '@salesforce/apex/BulkAPIService.processFileWithBulkAPI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploader extends LightningElement {
    isProcessing = false;
    selectedFile;
    statusMessage = '';
    statusMessageClass = ''

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles,JSON.stringify(uploadedFiles));
        if(uploadedFiles.length > 0){
            const file = uploadedFiles[0];
            this.selectedFile = {
                title : file.name,
                documentId : file.documentId
            }

        this.statusMessage = 'File Upload Successfully! Ready For Processing';
        this.statusMessageClass = 'slds-notify slds-notify_alert slds-m-top_medium slds-theme_success';
        this.showToast('Success',this.statusMessage,'success');
        }

    }

    handleSubmitForProcessing(){
        this.isProcessing = true;
        this.statusMessage = 'Processing File For Bulk API 2.0';
        this.statusMessageClass = 'slds-notify slds-notify_alert slds-m-top_medium slds-theme_success';
        
        processFileWithBulkAPI({
            fileId : this.selectedFile.documentId
        })
        .then(result=>{
             this.statusMessage = 'File Processed Successfully With Bulk API 2.0';
            this.statusMessageClass = 'slds-notify slds-notify_alert slds-m-top_medium slds-theme_success';
            this.showToast('Success',this.statusMessage,'success');
        })
        .catch(error =>{
            this.statusMessage = 'Error While Processing File'; 
            console.log(error.body?.message || error.message || JSON.stringify(error));
             this.statusMessageClass = 'slds-notify slds-notify_alert slds-m-top_medium slds-theme_error';
             this.showToast('Error',this.statusMessage,'error');
            })
        .finally(()=>{
            this.isProcessing = false;
            this.statusMessage = '';
        })
    }

    get isSubmitButtonDisable(){
        return !this.selectedFile || this.isProcessing;
    }

    handleClearSelection(){
        this.selectedFile = null;
        this.statusMessage = '';
        this.statusMessageClass = '';
    }

   

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}