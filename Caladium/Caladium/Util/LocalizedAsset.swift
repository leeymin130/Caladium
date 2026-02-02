//
//  LocalizedAsset.swift
//  Caladium
//
//  Created by Codex.
//

import Foundation

enum LocalizedAsset {
    static func toolbarImageName(_ baseName: String) -> String {
        guard Locale.current.languageCode == "en" else {
            return baseName
        }

        let mapping: [String: String] = [
            "btn-delete-0": "delete-0 1E",
            "btn-delete-1": "delete-1 1E",
            "btn-move-0": "move-0 1E",
            "btn-move-1": "move-1 1E",
            "btn-cancel-0": "cancel-0 1E",
            "btn-cancel-1": "cancel-1 1E",
            "btn-select-0": "choose-0 1E",
            "btn-select-1": "select-1 1E",
            "btn-makevideo-0": "makevideo-0 1E",
            "btn-makevideo-1": "makevideo-1 1E",
            "btn-export-0": "export-0 1E",
            "btn-export-1": "export-1 1E"
        ]

        return mapping[baseName] ?? baseName
    }
}
