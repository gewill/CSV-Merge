//
//  ContentView.swift
//  pass
//
//  Created by  will on 2023/9/10.
//

import SwiftCSV
import SwiftUI

struct ContentView: View {
  @State var isImporting = false
  @State var isExporting = false
  @State var urls: [URL] = []
  @State private var text = ""
  @State var error: Error?
  var body: some View {
    VStack {
      if let error {
        Text(error.localizedDescription)
          .foregroundColor(.pink)
      }
      HStack {
        Button {
          isImporting = true
        } label: {
          Label("Import file",
                systemImage: "square.and.arrow.down")
        }
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [.text],
                      allowsMultipleSelection: true) { result in
          // Result<[URL]>, Error>
          switch result {
          case let .success(success):
            urls = success
          case let .failure(failure):
            error = failure
          }
        }

        Button {
          if let url = urls.first,
             let csv = try? CSV<Named>.init(url: url, delimiter: .comma) {
            text = csv.rows.description
          }
        } label: {
          Text("Read dic")
        }

        Button {
          if let url = urls.first,
             let csv = try? CSV<Named>.init(url: url, delimiter: .comma) {
            print("header: \(csv.header)")
//            ["cardBrand", "cardExpiryDateMonth", "cardExpiryDateYear", "cardNumber", "cardType", "cardVerificationCode", "createdAt", "notes", "otherFields", "pin", "tags", "title", "updatedAt"]
            text = csv.rows.reduce(into: "title,cardNumber,cardVerificationCode,notes,createdAt,updatedAt", { partialResult, dic in
              var notes = ""
              if let v = dic["cardExpiryDateYear"], v.isEmpty == false {
                notes += "cardExpiryDateYear: \(v)\n"
              }
              if let v = dic["cardExpiryDateMonth"], v.isEmpty == false {
                notes += "cardExpiryDateMonth: \(v)\n"
              }
              if let v = dic["cardType"], v.isEmpty == false {
                notes += "cardType: \(v)\n"
              }
              if let v = dic["cardBrand"], v.isEmpty == false {
                notes += "cardBrand: \(v)\n"
              }
              if let v = dic["otherFields"], v.isEmpty == false {
                notes += "otherFields: \(v)\n"
              }
              if let v = dic["notes"], v.isEmpty == false {
                notes += "\(v)\n"
              }
              if notes.hasSuffix("\n") {
                notes.removeLast()
              }
              partialResult += "\n\(dic["title"] ?? ""),\(dic["cardNumber"] ?? ""),\(dic["cardVerificationCode"] ?? ""),\"\(notes)\",\(dic["createdAt"] ?? ""),\(dic["updatedAt"] ?? "")"
            })
          }
        } label: {
          Text("Convert💳")
        }

        Button {
          isExporting = true
        } label: {
          Label("Export file", systemImage: "square.and.arrow.up")
        }
        .fileExporter(isPresented: $isExporting,
                      document: TextDocument(text),
                      contentType: .text,
                      defaultFilename: "export.csv") { result in
          if case let .failure(error) = result {
            self.error = error
          }
        }
      }
      Divider()
      Text("CSV")
      List {
        ForEach(urls, id: \.self) {
          Text($0.absoluteString)
        }
      }
      .frame(height: 100)
      ScrollView {
        Text(text)
          .padding()
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
