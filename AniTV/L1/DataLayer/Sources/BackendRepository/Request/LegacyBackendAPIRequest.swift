import Foundation

/// Старый (v1) контракт запросов, на котором написан весь L2.
///
/// Адаптер `LegacyBackendAPIRequestAdapter` переводит его в новый
/// REST-контракт мастера (`requestData: RequestData`) — таким образом
/// код L2/L3 не требует переписывания.
protocol LegacyBackendAPIRequest {
    associatedtype ResponseObject: Decodable

    var baseUrl: String? { get }
    var endpoint: String { get }
    var apiVersion: String { get }
    var method: NetworkManager.Method { get }
    var parameters: [String: Any] { get }
    var body: (any Encodable)? { get }
    var headers: [String: String]? { get }
    var customResponseConverter: BackendResponseConverter? { get }
    var decodingInfo: [CodingUserInfoKey: any Sendable]? { get }
}

extension LegacyBackendAPIRequest {
    var baseUrl: String? { nil }
    var apiVersion: String { "" }
    var body: (any Encodable)? { nil }
    var headers: [String: String]? { nil }
    var customResponseConverter: BackendResponseConverter? { nil }
    var decodingInfo: [CodingUserInfoKey: any Sendable]? { nil }
}

/// Универсальная обёртка: старый запрос -> новый контракт `BackendAPIRequest`.
struct LegacyBackendAPIRequestAdapter<Request: LegacyBackendAPIRequest>: BackendAPIRequest {
    typealias ResponseObject = Request.ResponseObject

    var requestData: RequestData
    var customResponseConverter: BackendResponseConverter?
    var decodingInfo: [CodingUserInfoKey: any Sendable]?

    init(_ request: Request) {
        self.requestData = RequestData(
            baseUrl: request.baseUrl,
            endpoint: request.endpoint,
            apiVersion: request.apiVersion,
            method: request.method,
            parameters: request.parameters,
            body: request.body,
            headers: request.headers ?? [:]
        )
        self.customResponseConverter = request.customResponseConverter
        self.decodingInfo = request.decodingInfo
    }
}

extension BackendRepository {
    /// Перегрузка для старых (v1) запросов: прогоняет их через адаптер.
    func request<T: LegacyBackendAPIRequest>(_ request: T) -> AnyPublisher<T.ResponseObject, Error> {
        request(LegacyBackendAPIRequestAdapter(request))
    }
}
