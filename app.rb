require 'sinatra'
require 'haml'
require_relative 'trax.rb'
require_relative 'image_maker.rb'
enable :sessions

get '/' do
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