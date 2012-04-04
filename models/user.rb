class User < Neography::Node
  @neo_server = settings.neo

  def self.find_by_uid(uid)
    user = @neo_server.get_node_index("users_index", "uid", uid)

    if user
      self.new(user.first)
    else
      nil
    end
  end

  def self.create_with_omniauth(auth)
    self.new(@neo_server.create_unique_node("users_index", "uid", auth.uid,
                       {"name"      => auth.info.name,
                        "nickname"  => auth.info.nickname,
                        "location"  => auth.info.location,
                        "image_url" => auth.info.image,
                        "uid"       => auth.uid,
                        "token"     => auth.credentials.token,
                        "secret"    => auth.credentials.secret
                        })) 
  end


  def client
    @client ||= Twitter::Client.new(
      :oauth_token => self.token,
      :oauth_token_secret => self.secret
     )
  end

end