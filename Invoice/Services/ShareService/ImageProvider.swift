//
//  ImageProvider.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit

class ImageProvider: NSObject, UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "ShareIcon")!
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return UIImage(named: "ShareIcon")
    }
}

