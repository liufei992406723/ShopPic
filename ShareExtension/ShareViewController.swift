import UIKit

class ShareViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .systemBackground
        processIncomingItem()
    }

    private func processIncomingItem() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments
        else {
            finish()
            return
        }

        guard let imageProvider = attachments.first(where: {
            $0.hasItemConformingToTypeIdentifier("public.image")
        }) else {
            finish()
            return
        }

        imageProvider.loadItem(forTypeIdentifier: "public.image", options: nil) {
            [weak self] item, error in
            guard let self else { return }

            let image = self.extractImage(from: item)
            if let image {
                _ = AppGroupConstants.saveImage(image)
                UIPasteboard.general.image = image
            }

            DispatchQueue.main.async {
                self.finish()
                if let url = URL(string: "shoppic://imageReady") {
                    self.extensionContext?.open(url, completionHandler: nil)
                }
            }
        }
    }

    private func extractImage(from item: NSSecureCoding?) -> UIImage? {
        if let url = item as? URL {
            return UIImage(contentsOfFile: url.path)
        }
        if let image = item as? UIImage {
            return image
        }
        if let data = item as? Data {
            return UIImage(data: data)
        }
        return nil
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
