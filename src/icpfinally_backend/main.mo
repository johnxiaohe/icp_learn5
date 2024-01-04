import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import List "mo:base/List";
import Iter "mo:base/Iter";

actor{

  stable var name: Text = "";
  stable var followed: List.List<Principal> = List.nil();
  stable var articals: List.List<Message> = List.nil();

  public type Message = {
    content: Text;
    ctime: Time.Time;
    author: Principal;
  };

  public type MessageVo = {
    content: Text;
    ctime: Time.Time;
    author: Principal;
    authorName: Text;
  };

  public type FollowVo = {
    id: Principal;
    name: Text;
  };

  public type MicroBlog = actor {
    set_name: shared(Text) -> async();
    get_name: shared() -> async ?Text;
    follow: shared(Principal) -> async ();
    follows: shared query () -> async[FollowVo];
    post: shared(Text) -> async();
    posts: shared query (Time.Time) -> async[MessageVo];
    timeline: shared (Time.Time) -> async[MessageVo];
  };

  public shared func set_name(newName : Text): async (){
    name := newName;
  };

  public shared func get_name(): async ?Text{
    ?name;
  };

  public shared func follow(id: Principal): async (){
    followed  := List.push(id, followed);
  };

  public shared func follows(): async[FollowVo]{
    var result : List.List<FollowVo> = List.nil();
    for(follow in Iter.fromList(followed)){
      let microBlog: MicroBlog = actor(Principal.toText(follow));
      var authorName : Text = "undifiend";
      switch(await microBlog.get_name()){
        case null{};
        case (?name){
          authorName := name;
        };
      };
      let vo: FollowVo = {
        id = follow;
        name = authorName;
      };
      result := List.push(vo, result);
    };
    List.toArray(result);
  };

  public shared({caller}) func post(text: Text): async (){
    let message: Message = {
      content = text;
      ctime = Time.now();
      author = caller;
    };
    articals := List.push(message, articals);
  };

  public shared({caller}) func posts(since: Time.Time): async [MessageVo]{
    var result: List.List<MessageVo> = List.nil();
    for (artical in Iter.fromList(articals)){
        if(since <= artical.ctime){
          let vo = {
            content = artical.content;
            ctime = artical.ctime;
            author = artical.author;
            authorName = name;
          };
          result:= List.push(vo, result);
        }
    };
    return List.toArray(result);
  };

  public shared({caller}) func timeline(since: Time.Time) :async [MessageVo]{
    var result: List.List<MessageVo> = List.nil();
    for(follow in Iter.fromList(followed)){
      let microBlog: MicroBlog = actor(Principal.toText(follow));
      let thisArticals:[MessageVo] = await microBlog.posts(since);
      for (vo in Iter.fromArray(thisArticals)){
        result := List.push(vo, result);
      }

    };
    List.toArray(result);
  }


};
