//
//  CNContact+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import ContactsUI

extension CNContact {
    
    var fullName: String {
        return (!familyName.isEmpty ? familyName + " " : "") + (!givenName.isEmpty ? givenName + " " : "")
    }
    
    var organizationTitle: String {
        return organizationName.isEmpty ? fullName : organizationName
    }
    
    var phoneNumber: String? {
        guard let phoneNumber = phoneNumbers.first else { return nil }
        return phoneNumber.value.stringValue
    }
    
    var emailAddress: String? {
        guard let emailAddress = emailAddresses.first else { return nil }
        return String(emailAddress.value)
    }
    
    var fullAddress: String? {
        guard let address = postalAddresses.first?.value else { return nil }
        
        var fullAddress = ""
        
        if !address.subLocality.isEmpty { fullAddress += (!fullAddress.isEmpty ? ", " : "") + address.subLocality }
        if !address.street.isEmpty      { fullAddress += (!fullAddress.isEmpty ? ", " : "") + address.street }
        if !address.city.isEmpty        { fullAddress += (!fullAddress.isEmpty ? ", " : "") + address.city }
        if !address.state.isEmpty       { fullAddress += (!fullAddress.isEmpty ? ", " : "") + address.state }
        if !address.country.isEmpty     { fullAddress += (!fullAddress.isEmpty ? ", " : "") + address.country }
        
        return fullAddress
    }
}
