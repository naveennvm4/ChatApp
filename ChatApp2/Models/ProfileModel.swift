//
//  ProfileModel.swift
//  ChatApp
//
//  Created by MackBookAir on 08/06/21.
//
import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
