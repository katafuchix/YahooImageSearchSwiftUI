//
//  GridCell.swift
//  YahooImageSearchSwiftUI
//
//  Created by cano on 2021/05/09.
//

import SwiftUI
import QGrid

struct GridCell: View {
    
    var imageData: ImageData
    
    // 監視対象にしたいデータに@ObservedObjectをつける。
    @ObservedObject var container: ImageContainer
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                AsyncImage(url: imageData.url) { image in
                    image.resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(uiImage: container.image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
    }
}

// ObservableObjectを継承したデータモデル
final class ImageContainer: ObservableObject {

    // @PublishedをつけるとSwiftUIのViewへデータが更新されたことを通知してくれる
    @Published var image = UIImage(systemName: "photo")!

    init(from resource: URL) {
        // ネットワークから画像データ取得
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: resource, completionHandler: { [weak self] data, _, _ in
            guard let imageData = data,
                let networkImage = UIImage(data: imageData) else {
                return
            }

            DispatchQueue.main.async {
                // 宣言時に@Publishedを付けているので、プロパティを更新すればView側に更新が通知される
                self?.image = networkImage
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
}
