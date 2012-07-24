require 'koala'
require 'fb_graph'

module Facebook
	def self.fetch_friends(access_token)
		graph =  Koala::Facebook::GraphAPI.new(access_token)
		friends = graph.get_connections("me", "friends")
		return friends
	end

	def self.upload_photo(params)
		tagged =[]
		params[:user_list].each do |user|
			fb_user = FbGraph::User.fetch(user)
			tagged= FbGraph::Tag.new(
    		:name =>'Some one is tagged'
    		:x => 20+Random.rand(90),
    		:y => 10+Random.rand(90)
  		)
		end
	    
	    photo = FbGraph::User.me(params[:access_token]).photo!(
			:source=> File.new(File.join(File.dirname(__FILE__), params[:file_name])),
			:message=>params[:message],
			:tags=>tagged
			)
	    #User.create(:fbuid=>FbGraph::User.me(params[:access_token]).identifier,:filename=> params[:file_name])
	end

	def self.user(uid)
		User.find_or_create_by_fbuid(:fbuid=>uid,:friends=>(Facebook::fetch_friends session[:access_token]).to_json)
	end

	def self.log_post(fbuid,filename)
		Post.create(:fbuid=>fbuid,:filename=>filename)
	end
end