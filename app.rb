require 'sinatra'
require 'haml'
require 'koala'

require_relative 'trax.rb'
require_relative 'image_maker.rb'
require_relative 'facebook.rb'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
end

@friends={}
get '/' do
	@app_id = 	'474165465927936'
	@redirect_id = 'http://lyricards.redatomize.com/authenticate'
	@permission_names = 'publish_stream,publish_actions'
	@state_string=(0...25).map{65.+(rand(25)).chr}.join
	haml :index
end

get '/search' do
	  haml :search
end

get '/select' do
	query_song = params[:query]
	begin
		@search_result = Trax.find query_song
		@search_result
		haml :select
	rescue Exception => e
		@error = e
		haml :err
	end
end

get '/lyrics' do
	redirect '/' if session[:access_token].nil?
	track_id = params[:track_id]
	begin
		@lyric = Trax.lyrics? track_id
		@lyric = @lyric.split("\n")
		@lyric.pop
		@lyric
		haml :lyrics
	rescue Exception => e
		@error = e
		haml :err		
	end
end

post '/spice' do
	redirect '/' if session[:access_token].nil?
	selected = params[:selected_lyrics]
	session[:pic_name] = nil
	begin
			@sel = {}
			#@sel[:artist] = params[:artist]
			#@sel[:album] = params[:album]
			selected = selected.split("\n")
			selected.map! do |line| 
				line.gsub!(/\(\d\)/,"")
				line.gsub!(/\<.*\>/)
				line.gsub("\n","")
				line unless (line.strip!).length==0
			end
			@friends[session[:access_token]]=Thread.new{Facebook::fetch_friends session[:access_token]}
			selected.compact!
			size = selected.length
			font_size = (180/size) #replace this by a literal
			max_len = selected.max_by{|a| a.length}
			max_len = max_len.gsub(" ","").length
			#font_size -=(max_len*font_size-850) if max_len>850
			@sel[:max_size] = max_len
			@sel[:lyrics] = selected
			@sel[:font_size]= font_size
			@sel
			haml :spice
	rescue Exception => e
		@error = e
		haml :err			
	end

end

post '/show' do
	redirect '/' if session[:access_token].nil?
	if session[:pic_name].nil?
		@file_path = ImageMaker::make_image params
		session[:pic_name] = @file_path
	end
	@friends = "https://graph.facebook.com/#{(FbGraph::User.me(session[:access_token]).identifier)}/friends?access_token=#{session[:access_token]}"
	haml :show
end

get'/friends' do
	@friends[session[:access_token]].join
	content_type :json 
	@friends[session[:access_token]].to_json
end

post '/success' do
	redirect '/' if session[:access_token].nil?||session[:pic_name].nil?
	users = params[:friends].split(',')
	users.collect!{|user| user unless user==""}
	users.compact!
	p users
	params[:file_name] = "/public/usr_images/#{session[:pic_name]}"
	params[:user_list]= users
	params[:message] = params[:message]
	params[:option] = params[:pub_opt]
	params[:access_token] = session[:access_token]
	session[:pic_link] = session[:pic_name]
	session[:pic_name] = nil
	Facebook::upload_photo params
	haml :success
end

get '/thanx' do
	FbGraph::User.me(session[:access_token]).feed!(
			:message => "I made a card via lyriCards.. :) <3",
			:picture => "http://lyricards.redatomize.com/usr_images/#{session[:pic_link]}",
			:link => "http://lyricards.redatomize.com/images/heart.png",
			:name => "lyriCards",
			:description => 'Make awesome cards from the lyrics you love..'
			)
	haml :thanx
end

get '/err' do
	haml :err
end

get '/songs' do
	tracks = Track.find(:all,:conditions=>["name LIKE ?","#{params[:query]}%"],:select=>"DISTINCT(name)")
	response = []
	tracks.each do |track|
		song={}
		song[:name] = track.name
		response<<song
	end
	content_type :json
	response.to_json
end

get '/authenticate' do
	state = params[:state]
	code = params[:code]
	haml :not_allowed if params[:error_reason]=="user_denied"
	@oauth = Koala::Facebook::OAuth.new(474165465927936, "3460693681a1781d0677d60447e8b88f",'http://lyricards.redatomize.com/authenticate')
	access_token = @oauth.get_access_token(code)
	session[:access_token] = access_token
		Thread.new{Facebook::user FbGraph::User.me(access_token).identifier
		ActiveRecord::Base.connection.close
	}
	redirect '/search'
end

error do
  @error = request.env['sinatra_error'].name
  haml :err
end

not_found do
  @val = 'Oh my!!! There is no page like!!!'
  haml :err
end