import Foundation



private let responseQueue = dispatch_queue_create("com.VK.responseQueue", DISPATCH_QUEUE_CONCURRENT)



internal class Response {
  internal weak var request : Request?
  internal private(set) var error : VK.Error? {
    didSet {success != nil ? success = nil : ()}
  }
  internal private(set) var success : JSON? {
    didSet {error != nil ? error = nil : ()}
  }
  
  
  internal func setError(newError: VK.Error) {
    error = newError
  }
  
  
  
  internal func create(data: NSData?) {
    if data != nil {
      var err : NSError?
      var json = JSON(data: data!, error: &err)
      
      if err != nil {
        error = VK.Error(ns: err!, req: request!)
      }
        
      else if json["response"].count > 0 {
        VK.Log.put(request!, "Parse response data to success")
        success = json["response"]
      }
        
      else if json["error"].count > 0 {
        VK.Log.put(request!, "Parse response data to error:")
        error = VK.Error(json: json["error"], request: request!)
      }
        
      else {
        VK.Log.put(request!, "Parse response data to sucsess")
        success = json
      }
    }
    else {
      VK.Log.put(request!, "Fail parse response data")
      error = VK.Error(domain: "VKSDKDomain", code: 4, desc: "Fail parse response data", userInfo: nil, req: request)
    }
  }
  
  
  
  internal func execute() {
    guard let request = request where request.cancelled == false else {return}
    
    if let error = error {
      if request.catchErrors {
        error.`catch`()
      }
      else if request.canSend == true {
        request.trySend()
      }
      else {
        request.isAPI == true && request.isAsynchronous == false
          ? executeError()
          : dispatch_async(responseQueue) {self.executeError()}
      }
    }
    else if let _ = success {
      request.isAPI == true && request.isAsynchronous == false
        ? executeSuccess()
        : dispatch_async(responseQueue) {self.executeSuccess()}
    }
    else {
      VK.Log.put(request, "Response data is not set")
    }
  }
  
  
  
  internal func executeError() {
    guard let request = request where request.cancelled == false else {return}
    
    guard request.errorBlockIsSet else {
      VK.Log.put(request, "Error block is not set")
      return
    }
    guard let error = error else {
      VK.Log.put(request, "Error is not set")
      return
    }
    
    VK.Log.put(request, "Executing error block")
    request.errorBlock(error: error)
    clean()
    VK.Log.put(request, "Error block is executed")
  }
  
  
  
  internal func executeSuccess() {
    guard let request = request where request.cancelled == false else {return}
    
    guard request.successBlockIsSet else {
      VK.Log.put(request, "Success block is not set")
      return
    }
    guard let success = success else {
      VK.Log.put(request, "Success is not set")
      return
    }
    
    VK.Log.put(request, "Executing success block")
    request.successBlock(response: success)
    clean()
    VK.Log.put(request, "Success block is executed")
  }
  
  
  internal func clean() {
    self.success = nil
    self.error = nil
  }
}