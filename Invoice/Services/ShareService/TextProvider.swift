//
//  TextProvider.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit
import PDFKit
import LinkPresentation

class TextProvider: NSObject, UIActivityItemSource {
    
    private var filename: String
    private var shareText: String
    private var iconImage: UIImage
    private var url: URL
    
    init(filename: String, shareText: String, url: URL) {
        self.filename = filename
        self.shareText = shareText
        self.url = url
        
        guard let document = PDFDocument(url: url), document.pageCount > 0 else {
            self.iconImage = UIImage(named: "ShareIcon")!
            return
        }
        
        guard let page = document.page(at: 0) else {
            self.iconImage = UIImage(named: "ShareIcon")!
            return
        }
        
        let rect = CGSize(width: 595.2, height: 841.8)
        self.iconImage = page.thumbnail(of: rect, for: .mediaBox)
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = shareText
        metadata.iconProvider = NSItemProvider(object: iconImage)
        metadata.imageProvider = NSItemProvider(object: iconImage)
        metadata.originalURL = url
        return metadata
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareText
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        return filename + "\n" + shareText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        
        return filename
    }
}

