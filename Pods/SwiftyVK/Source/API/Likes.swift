extension _VKAPI {
  ///Methods for working with "Like". More - https://vk.com/dev/likes
  public struct Likes {
    
    
    
    ///Returns a list of IDs of users who added the specified object to their Likes list. More - https://vk.com/dev/likes.getList
    public static func getList(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "likes.getList", parameters: parameters)
    }
    
    
    
    ///Adds the specified object to the Likes list of the current user. More - https://vk.com/dev/likes.add
    public static func add(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "likes.add", parameters: parameters)
    }
    
    
    
    ///Deletes the specified object from the Likes list of the current user. More - https://vk.com/dev/likes.delete
    public static func delete(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "likes.delete", parameters: parameters)
    }
    
    
    
    ///Checks for the object in the Likes list of the specified user. More - https://vk.com/dev/likes.isLiked
    public static func isLiked(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "likes.isLiked", parameters: parameters)
    }
  }
}
