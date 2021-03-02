public class StateAndCountryPicklistGenerator{

    //API name of the sObject containing the to country and state picklists.
    public String sObjectApiName {get; set;}

    //Attributes pertaining to country custom field
    public String countryFieldApiName {get; set;}
    public String countryFieldDescription {get; set;}
    public String countryFieldLabel {get; set;}
    public boolean countryFieldRestricted {get; set;}

    //Attributes pertaining to state custom field
    public String stateFieldApiName {get; set;}
    public String stateFieldDescription {get; set;}
    public String stateFieldLabel {get; set;}
    public boolean stateFieldRestricted {get; set;}

    //Attributes pertaining to country global value set.
    public String countryValueSetLabel {get; set;}
    public String countryValueSetDescription {get; set;}
    public String countryValueSetName {get; set;}

    //Attributes pertaining to state global value set.
    public String stateValueSetLabel {get; set;}
    public String stateValueSetDescription {get; set;}
    public String stateValueSetName {get; set;}

    //Flags for turning on/off global value set or custom field creation.
    public boolean createStateField {get; set;}
    public boolean createCountryField {get; set;}
    public boolean createGlobalValueSet {get; set;}

    public StateAndCountryPicklistGenerator(String sObjectApiName){
        this.sObjectApiName = sObjectApiName;
        this.countryFieldApiName = 'Country__c';
        this.countryFieldDescription = 'Custom Country Picklist';
        this.countryFieldLabel = 'Country';
        this.countryFieldRestricted = true;

        this.countryValueSetLabel = 'Country';
        this.countryValueSetDescription = 'Custom country global picklist / value set';
        this.countryValueSetName = 'Country';

        this.stateFieldApiName = 'State__c';
        this.stateFieldDescription = 'Custom State Picklist';
        this.stateFieldLabel = 'State';
        this.stateFieldRestricted = true;

        this.stateValueSetLabel = 'State';
        this.stateValueSetDescription = 'Custom state global picklist / value set';
        this.stateValueSetName = 'State';

        this.createCountryField = true;
        this.createStateField = true;
        this.createGlobalValueSet = true;
    }

    public void run(){

        MetadataService.CustomField stateField = new MetadataService.CustomField();
        MetadataService.CustomField countryField = new MetadataService.CustomField();
        if(this.createStateField){
            stateField.fullName = this.sObjectApiName + '.' + this.stateFieldApiName;
            stateField.label = this.stateFieldLabel;
            stateField.type_x = 'Picklist';
            stateField.description = this.stateFieldDescription;

            stateField.valueSet = new MetadataService.ValueSet();
            stateField.valueSet.restricted = this.stateFieldRestricted;
            stateField.valueSet.controllingField = this.countryFieldApiName;
            stateField.valueSet.valueSetName = this.stateValueSetName;
            stateField.valueSet.valueSettings = new List<MetadataService.ValueSettings>();
        }

        if(this.createCountryField){
            countryField.fullName = this.sObjectApiName + '.' + this.countryFieldApiName;
            countryField.label = this.countryFieldLabel;
            countryField.type_x = 'Picklist';
            countryField.description = this.countryFieldDescription;

            countryField.valueSet = new MetadataService.ValueSet();
            countryField.valueSet.restricted = this.countryFieldRestricted;
            countryField.valueSet.valueSetName = this.countryValueSetName;
        }


        Map<String,List<PicklistEntryWrapper>> controllingMap = getDependentOptionsImpl(Account.BillingStateCode,Account.BillingCountryCode);

        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.allOrNoneHeader = new MetadataService.AllOrNoneHeader_element();
        service.allOrNoneHeader.allOrNone=true;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.timeout_x = 120000;

        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();

        MetadataService.GlobalValueSet stateGvs = new MetadataService.GlobalValueSet();
        stateGvs.fullName = this.stateValueSetName;
        stateGvs.masterLabel = this.stateValueSetLabel;
        stateGvs.sorted = true;
        stateGvs.description = this.stateValueSetDescription;
        stateGvs.customValue = new List<MetadataService.CustomValue>();

        MetadataService.GlobalValueSet countryGvs = new MetadataService.GlobalValueSet();
        countryGvs.fullName = this.countryValueSetName;
        countryGvs.masterLabel = this.countryValueSetLabel;
        countryGvs.sorted = true;
        countryGvs.description = this.countryValueSetDescription;
        countryGvs.customValue = new List<MetadataService.CustomValue>();

        for(Schema.PicklistEntry countryPle : Account.BillingCountryCode.getDescribe().getPicklistValues()){
            MetadataService.CustomValue countryCv = new MetadataService.CustomValue();
            countryCv.fullName = countryPle.getValue();
            countryCv.label = countryPle.getLabel();
            countryCv.IsActive = countryPle.isActive();
            countryCv.default_x = countryPle.isDefaultValue();
            countryGvs.customValue.add(countryCv);

            for(PicklistEntryWrapper statePle : controllingMap.get(countryPle.getValue())){
                MetadataService.CustomValue stateCv = new MetadataService.CustomValue();
                stateCv.fullName = countryPle.getValue() + '_' + statePle.value;
                stateCv.label = statePle.label;
                stateCv.IsActive = statePle.active;
                stateCv.default_x = statePle.defaultValue;
                stateGvs.customValue.add(stateCv);

                if(this.createStateField){
                    MetadataService.ValueSettings vs = new MetadataService.ValueSettings();
                    vs.valueName = stateCv.fullName;
                    vs.controllingFieldValue = new List<String>{countryPle.getValue()};
                    stateField.valueSet.valueSettings.add(vs);
                }
            }
        }

        if(this.createGlobalValueSet){
            results.addAll(service.createMetadata(new List<MetadataService.GlobalValueSet>{countryGvs,stateGvs}));
        }

        if(this.createCountryField){
            results.addAll(service.createMetadata(new List<MetadataService.CustomField>{ countryField }));
        }

        if(this.createStateField){
            results.addAll(service.createMetadata(new List<MetadataService.CustomField>{ stateField }));
        }

        for(MetadataService.SaveResult result : results){
            if(result.errors != null){
                String ex = '';
                for(MetadataService.Error err : result.errors){
                    System.debug('Error serialized: ' + JSON.serialize(err));
                    System.debug('Error message: ' + err.message);
                    if(err.extendedErrorDetails != null){
                        for(MetadataService.ExtendedErrorDetails detail : err.extendedErrorDetails){
                            System.debug('Error extended code: ' + detail.extendedErrorCode);
                        }
                    }
                }
            }
        }
    }

    //Private helper methods for getting dependent options
    private static Map<String, List<PicklistEntryWrapper>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {

        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());

        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, List<PicklistEntryWrapper>> objResults = new Map<String, List<PicklistEntryWrapper>>();
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getValue();
            objResults.put(label, new List<PicklistEntryWrapper>());
            controllingValues.add(label);
        }

        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(plew);
                }
            }
        }

        return objResults;
    }

    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    private static String decimalToBinary(Integer val){
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }


    private static final String base64Chars = '' +
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
            'abcdefghijklmnopqrstuvwxyz' +
            '0123456789+/';


    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    private class PicklistEntryWrapper{
        public boolean active {get; set;}
        public boolean defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
}
