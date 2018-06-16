import Promises

extension URLSession {
    func dataTaskPromised(with urlRequest: URLRequest) -> Promise<Data> {
        return Promise<Data> { fulfill, reject in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    reject(error)
                    return
                }
                guard let responseData = data else
                {
                    let defaultError = NetworkError.badData
                    reject(defaultError)
                    return
                }
                fulfill(responseData)
            }
            task.resume()
        }
    }
}
