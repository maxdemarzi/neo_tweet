module Follows
  @queue = :follows
  @neo = Neography::Rest.new

  def self.perform(uid)
    user = User.find_by_uid(uid)
    commands = [] 
    cursor = "-1"

    while cursor != 0 do
      friends = user.client.friend_ids({:cursor => cursor})
      cursor = friends.next_cursor

      friends.ids.each do |f|
        friend = user.client.user(f)
        commands << [:create_unique_node, "users_index", "uid", friend.id, 
                     {"name"      => friend.name,
                      "nickname"  => friend.screen_name,
                      "location"  => friend.location,
                      "image_url" => friend.profile_image_url,
                      "uid"       => friend.id
                      }]
      end

    end

    batch_result = @neo.batch *commands

    commands = [] 

    batch_result.each do |b|
      commands << [:create_unique_relationship, "follows_index", "nodes",  "#{uid}-#{b["body"]["data"]["uid"]}", "follows", user, b["body"]["self"].split("/").last]
    end

    @neo.batch *commands

  end
end