// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import PrivacyKit

/// Provides an API to walk the client through the creation of a Privacy
/// Manifest via a series of questions.
final class PrivacyManifestWizard {
  private let builder: PrivacyManifest.Builder
  private var questionnaire: Questionnaire

  static func makeWizard(xcframework: URL) -> Self {
    let builder = PrivacyManifest.Builder()
    let privacyQuestionnaire = Questionnaire.makePrivacyQuestionnaire(
      for: xcframework,
      with: builder
    )
    return Self(builder: builder, questionnaire: privacyQuestionnaire)
  }

  private init(builder: PrivacyManifest.Builder,
               questionnaire: Questionnaire) {
    self.builder = builder
    self.questionnaire = questionnaire
  }

  func nextQuestion() -> String? {
    questionnaire.nextQuestion()?.question
  }

  func processAnswer(_ answer: String) throws {
    let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)

    let answer: Questionnaire.Answer = {
      switch trimmedAnswer {
      case "yes": return .bool(true)
      case "no": return .bool(false)
      default: return .string(trimmedAnswer)
      }
    }()

    try questionnaire.processAnswer(answer)
  }

  func createManifest() throws -> PrivacyManifest {
    try builder.build()
  }
}
