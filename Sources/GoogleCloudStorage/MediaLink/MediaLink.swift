//
//  MediaLink.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//

import Foundation
import RegexBuilder

public struct MediaLink {
    public let bucket: String
    public let object: String
    
    public init(bucket: String, object: String) {
        self.bucket = bucket
        self.object = object
    }

}


extension MediaLink {
    public init? (urlString: String) {
        
        let regex = Regex {
            // 匹配固定的前綴
            "https://storage.googleapis.com/download/storage/v1/b/"
            
            // 捕獲 bucket 名稱（字母、數字、連字符）
            Capture {
                OneOrMore {
                    CharacterClass(
                        .anyOf("-"),
                        ("a"..."z"),
                        ("A"..."Z"),
                        ("0"..."9")
                    )
                }
            }
            
            // 匹配固定的分隔符
            "/o/"
            
            // 捕獲 object 名稱（字母、數字、連字符、點、百分比符號、斜線）
            Capture{
                OneOrMore {
                    CharacterClass(
                        .anyOf("-._%/"),
                        ("a"..."z"),
                        ("A"..."Z"),
                        ("0"..."9")
                    )
                }
            }
            
            // 可選地匹配查詢參數，忽略其內容
            Optionally {
                "?"
                ZeroOrMore(.any)
            }
        }
        
        if let match = try? regex.wholeMatch(in: urlString) {
            self.bucket = match.1.description // First capture group
            self.object = match.2.description // Second capture group
            print("Bucket: \(bucket)")
            print("Object: \(object)")
        } else {
            print("No match")
            return nil
        }
    }
}
