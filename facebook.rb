require 'koala'
require 'fb_graph'

module Facebook
	def self.fetch_friends(access_token)
		graph =  Koala::Facebook::GraphAPI.new(access_token)
		friends = graph.get_connections("me", "friends")
		return friends
	end

	def self.upload_photo(params)
		me = FbGraph::User.me(params[:access_token])
		tags =[]
		tag_thread = Thread.new{
			params[:user_list].each do |user|
				fb_user = FbGraph::User.fetch(user)
				tags<< FbGraph::Tag.new(
    						:id => fb_user.identifier.to_i,
    						:name =>fb_user.name,
    						:x => 20+Random.rand(90),
    						:y => 10+Random.rand(90)
  				)
		end
		}
		Thread.new{
			puts tags
			tag_thread.join
	    	FbGraph::User.me(params[:access_token]).photo!(
				:source=> File.new(File.join(File.dirname(__FILE__), params[:file_name])),
				:message=>params[:message],
				:tags=>tags
				)
	    	Facebook::log_post fb_user.identifier.to_i, params[:file_name]
	    	ActiveRecord::Base.connection.close
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

	def self.user(uid)
		User.find_or_create_by_fbuid(:fbuid=>uid)
	end

	def self.log_post(fbuid,filename)
		Post.create(:fbuid=>fbuid,:filename=>filename)
	end
end