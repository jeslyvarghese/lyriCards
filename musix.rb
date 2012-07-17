require 'musix_match'

module Musix #Wrapping MusixMatch APIs
	MusixMatch::API::Base.api_key = '1964c381c2f1849f9eda1e3cbeacd55d'	
	def self.search(query_string)
		response = MusixMatch.search_track(:q => query_string,:page_size=>500)
		if response.status_code == 200
		  return response
		end
	end

	def self.get_lyrics(track_id)
	  response = MusixMatch.get_lyrics(track_id)
	  if response.status_code == 200 && lyrics = response.lyrics
	  	return lyrics
	  else
	  	return response.status_code
	  end
	end
end