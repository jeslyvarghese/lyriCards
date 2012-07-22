require_relative 'musix.rb'
require_relative 'database.rb'
module Trax
	def self.find(query) #search
		search_list= Array.new
			tracks = Musix.search(query)
			tracks.each do |track|
				result = Hash.new
				result[:track_name] = track.track_name
				result[:track_id] =  track.track_id
				result[:artist_name] = track.artist_name
				result[:album_name] = track.album_name
				search_list<<result	
			end
		p "search complete..		"
		Thread.new { Trax::result_to_db tracks }
		return search_list
	end

	def self.lyrics?(track_id)
		lyrics = Musix::get_lyrics track_id
		Thread.new{
			Lyric.find_or_create_by_mxid(:mxid=>lyrics.lyrics_id,
			:content=>lyrics.lyrics_body,:track_id=>track_id)
			ActiveRecord::Base.connection.close
			}
		return lyrics.lyrics_body
	end

	def self.result_to_db(tracks)
		tracks.each do |track|
			Track.find_or_create_by_mxid_and_name(
					:mxid=>track.track_id,
					:name=>track.track_name,
					:length=>track.track_length,
					:subtitle_id=>track.subtitle_id,
					:artist_id=>track.artist_id,
					:album_id=>track.album_id,
					)
				Artist.find_or_create_by_mxid_and_name(:mxid=>track.artist_id,:name=>track.artist_name,)
				Album.find_or_create_by_mxid_and_name(:mxid=>track.album_id,
					:name=>track.album_name,
					:cover=>track.album_coverart_100x100,
					:artist_id=>track.artist_id
					)
			ActiveRecord::Base.connection.close
		end
	end
end