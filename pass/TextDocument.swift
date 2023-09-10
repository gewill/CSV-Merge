//
//  TextDocument.swift
//  pass
//
//  Created by  will on 2023/9/10.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TextDocument: FileDocument {
  public static var readableContentTypes: [UTType] =
    [.text, .json, .xml]

  var text: String = ""

  init(_ text: String = "") {
    self.text = text
  }

  init(configuration: ReadConfiguration) throws {
    if let data = configuration.file.regularFileContents {
      text = String(decoding: data, as: UTF8.self)
    }
  }

  func fileWrapper(configuration: WriteConfiguration)
    throws -> FileWrapper {
    let data = Data(text.utf8)
    return FileWrapper(regularFileWithContents: data)
  }
}
