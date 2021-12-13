//
//  Img.swift
//  YahooImageSearchSwiftUI
//
//  Created by cano on 2021/05/09.
//

import Foundation

// 表示データ用モデル
// QGridで表示するためにはIdentifiableが必要

struct ImageData: Identifiable {
    var id = UUID()
    let url: URL
}

// エラー
enum ImageError: Error {
    case serverError
    case noData
}
