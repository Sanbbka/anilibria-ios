//
//  FullDataResponseConverter.swift
//
//  Конвертер для «сырых» ответов API v1 (login/logout/social),
//  которые приходят без стандартной оболочки { status, data }.
//

import Foundation

final class FullDataResponseConverter: BackendResponseConverter {
    func convert<T>(request: T, response: NetworkResponse) -> (T.ResponseObject?, Error?) where T : BackendAPIRequest {
        do {
            let decoder = JSONDecoder()
            if let info = request.decodingInfo {
                decoder.userInfo = info
            }
            decoder.dateDecodingStrategy = .iso8601
            return (try decoder.decode(T.ResponseObject.self, from: response.data), nil)
        } catch {
            if let type = T.ResponseObject.self as? ExpressibleByNilLiteral.Type,
               let result = type.init(nilLiteral: ()) as? T.ResponseObject {
                return (result, nil)
            }
            return (nil, AppError.error(code: MRKitErrorCode.parsingError))
        }
    }
}
