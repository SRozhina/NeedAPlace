import Promises

enum CancelableRequestErrors: Error {
    case canceled
}

typealias CancelAction = () -> Void

class CancelableRequest<T> {
    let promise: Promise<T>
    private var canceled = false
    private var task: URLSessionDataTask?
    
    init(promise: Promise<T>, task: URLSessionDataTask? = nil) {
        self.promise = promise
        self.task = task
    }
    
    func cancel() {
        if canceled {
            return
        }
        task?.cancel()
        promise.reject(CancelableRequestErrors.canceled)
        canceled = true
    }
}
