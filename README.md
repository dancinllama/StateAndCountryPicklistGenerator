# State and Country Picklist Generator

## Description
This Apex class enables State and Country picklists  (if not already enabled), and then copies the standard state and country picklists into custom, global value sets. If specified, this class also creates custom, *dependent* picklist fields for both countries and states that utilize the global value set.

Why, you might ask?  Because you can only use State and Country picklist on standard address fields / objects currently.

## Use

Deploy to a sandbox <a href="https://githubsfdeploy.herokuapp.com?owner=dancinllama&amp;repo=StateAndCountryPicklistGenerator">
  <img src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png" alt="Deploy to Salesforce" />
</a> Or Deploy to a Salesforce DX scratch org.

Once installed, use the developer console or VS Code to execute the following through Execute Anonymous:

```
//Create the state and country value sets, and state and country picklist for the "Region_Mapping__c" custom object.
StateAndCountryPicklistGenerator scPLE = new StateCountryPicklistGenerator('Region_Mapping__c');
scPLE.run();

//Use the existing state and country value sets, but create the custom picklist fieldsfor the "Region_Mapping__c" custom object.
StateAndCountryPicklistGenerator scPLE = new StateCountryPicklistGenerator('Region_Mapping__c');
sCPLE.createGlobalValueSet = false;
scPLE.run();

//Create only the global value set, giving it a unique name.
StateAndCountryPicklistGenerator scPLE = new StateCountryPicklistGenerator('Region_Mapping__c');
scPLE.createCountryField = false;
scPLE.createStateField = false;
scPLE.countryValueSetName = 'CustomCountry';
scPLE.countryValueSetLabel = 'CustomCountry';
scPLE.countryValueSetDescription = 'Custom Description for Custom Country';
scPLE.run();
```
## Available Attributes / Customizations:
sObjectApiName (String)
    API name of the sObject, where the custom picklist fields will reside.
    
countryFieldApiName (String)
    API name of the custom country picklist field to create.
    
countryFieldDescription (String)
    Description of the custom country picklist field created.
    
countryFieldLabel (String)
    Label of the custom country picklist field created.
    
countryFieldRestricted (boolean)
    Determines if the entered values in the custom country picklist are restricted to the picklist.
    
stateFieldApiName (String)
    API name of the state custom picklist field to create.
    
stateFieldDescription (String) 
    Description of the state custom picklist field created.
    
stateFieldLabel (String)
    Label of the state custom picklist field created.
    
stateFieldRestricted (boolean)
    Determines if the entered values in the custom state picklist are restricted to the picklist.
    
countryValueSetLabel (String)
    Label of the global value set for the country.
    
countryValueSetDescription (String)
    Description of the country global value set.
    
countryValueSetName (String)
    Name of the country global value set.

stateValueSetLabel (String)
    Descriptipn of the state value set
    
stateValueSetName (String)
    Name of the state global value set
    
createStateField (boolean)
    Set to true if you want to create the state custom picklist field, false otherwise (DEFAULT: true)
    
createCountryField (boolean)
    Set to true if you want to create the country custom picklist field, false otherwise.  If state is set to true, then either the country field must already exist, or this boolean must be set to true. (DEFAULT : true)

createGlobalValueSet (boolean)
    Set to true if you want to create the state and country global value sets, false otherwise.  
