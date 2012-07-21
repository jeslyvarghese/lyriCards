require 'koala'
require 'fb_graph'

module Facebook
	def self.fetch_friends(access_token,result_list)
		graph =  Koala::Facebook::GraphAPI.new(access_token)
		friends = graph.get_connections("me", "friends")
		result_list = friends
		return result_list
	end

	def self.upload_photo(params)
		me = FbGraph::User.me(params[:access_token])
		tags =[]
		tag_thread = Thread.new{
			params[:user_list].each do |user|
				fb_user = FbGraph::User.fetch(user)
				tags<< FbGraph::Tag.new(
    						:id => user,
    						:name =>fb_user.name,
    						:x => 20+Random.rand(800),
    						:y => 10+Random.rand(300)
  				)
		end
		}
		
		Thread.new{
			tag_thread.join
		me.photo!(
				:source=> File.new(File.join(File.dirname(__FILE__), params[:file_name])),
				:message=>params[:message],
				:tags=>tags)
		}

		#case secrecy
		#	when "coverpic" 
		#		Facebook::as_cover albums
		#	when "public"
		#		Facebook::as_wall_pic albums
		#	when "secret"
		#		Facebook::as_private_message
		#end
	end

	def self.as_cover album
	  album = albums.detect{ |album| album.type == "cover_photo"}
	  album
	end

	def self.as_wall_pic
	  album = albums.detect{ |album| album.type == "cover_photo"}
	  album
	end

	def self.as_private_message
	end
end