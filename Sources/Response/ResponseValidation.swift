import Foundation
import When

// MARK: - Validations

public extension Promise where T: Response {
  func validate(using validator: Validating) -> Promise<Response> {
    return then({ response -> Response in
      try validator.validate(response)
      return response
    })
  }

  func validate<T: Sequence>(statusCodes: T) -> Promise<Response> where T.Iterator.Element == Int {
    return validate(using: StatusCodeValidator(statusCodes: statusCodes))
  }

  func validate<T: Sequence>(contentTypes: T) -> Promise<Response> where T.Iterator.Element == String {
    return validate(using: ContentTypeValidator(contentTypes: contentTypes))
  }

  func validate() -> Promise<Response> {
    return validate(statusCodes: 200..<300).then({ response -> Response in
      guard response.statusCode != 204 else {
        return response
      }

      let contentTypes: [String]

      if let accept = response.urlRequest.value(forHTTPHeaderField: "Accept") {
        contentTypes = accept.components(separatedBy: ",")
      } else {
        contentTypes = ["*/*"]
      }

      try ContentTypeValidator(contentTypes: contentTypes).validate(response)

      return response
    })
  }
}
