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
	@permission_names = 'publish_stream,read_friendlists,publish_actions'
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
			selected.compact!
			size = selected.length
			font_size = (180/size) #replace this by a literal
			max_len = selected.max_by{|a| a.length}
			max_len = max_len.gsub(" ","").length
			#font_size -=(max_len*font_size-850) if max_len>850
			set :thread , Thread.new{	Thread.current[:output] = Facebook::fetch_friends session[:access_token],session[:friends]}
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
	session[:pic_name]
	haml :show
end

get'/friends' do
	options.thread.join		
	@friends = options.thread[:output]
	content_type :json
	@friends.to_json
end

post '/success' do
	redirect '/' if session[:access_token].nil?||session[:pic_name].nil?
	users = params[:friends].split(',')
	users.collect!{|user| user unless user==""}
	users.compact!
	params[:file_name] = "/public/usr_images/#{session[:pic_name]}"
	params[:user_list]= users
	params[:message] = params[:message]
	params[:option] = params[:pub_opt]
	params[:access_token] = session[:access_token]
	session[:pic_name] = nil
	Facebook::upload_photo params
	haml :success
end

get '/thanks' do
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
	redirect '/search'
end