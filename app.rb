require 'sinatra'
require 'haml'
require 'koala'

require_relative 'trax.rb'
require_relative 'image_maker.rb'
require_relative 'facebook.rb'

enable :sessions
@friends={}
get '/' do
	@app_id = 	'232653716855302'
	@redirect_id = 'http://localhost:4567/authenticate'
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
	track_id = params[:track_id]
	#begin
		@lyric = Trax.lyrics? track_id
		@lyric = @lyric.split("\n")
		@lyric.pop
		@lyric
		haml :lyrics
	#rescue Exception => e
	#	@error = e
	#	haml :err		
	#end
end

post '/spice' do
	selected = params[:selected_lyrics]
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
			p max_len
			max_len = max_len.gsub(" ","").length
			#font_size -=(max_len*font_size-850) if max_len>850
			#p font_size
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
	@file_path = ImageMaker::make_image params
	@file_path
	haml :show
end

get'/friends' do
	Facebook::fetch_friends session[:access_token],session[:friends]
	@friends = session[:friends]
	content_type :json
	@friends.to_json
end

get '/success' do
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
	@oauth = Koala::Facebook::OAuth.new(232653716855302, "8a4a0d15cb6be51df31d1ac1a16bd61c",'http://localhost:4567/authenticate')
	access_token = @oauth.get_access_token(code)
	session[:access_token] = access_token
	redirect '/search'
end