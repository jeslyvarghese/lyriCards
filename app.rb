require 'sinatra'
require 'haml'
require_relative 'trax.rb'

enable :sessions

get '/' do
	haml :index
end

get '/select' do
	haml :select
end

post '/select' do
	query_song = params[:query]
	search_result = Trax.find query_song
	content_type :json
	search_result.to_json 
end

post '/select/get_lyrics' do
	track_id = params[:track_id]
	@lyric = Trax.lyrics? track_id
	@lyric = @lyric.split("\n")
	@lyric.pop
	@lyric
	haml :lyrics,:layout=>false
end

post '/spice' do
	selected = params[:selected_lyrics]
	@sel = {}
	#@sel[:artist] = params[:artist]
	#@sel[:album] = params[:album]
	selected = selected.split("\n")
	selected.map! do |line| 
		line.gsub!(/\(\d\)/,"")
		line.gsub!(/\<.*\>/)
		line unless (line.strip!).length==0
	end
	size = selected.length
	font_size = 200/size #replace this by a literal
	@sel[:lyrics] = selected
	@sel[:font_size]= font_size
	@sel
	haml :spice
end

get '/show' do
	haml :show
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