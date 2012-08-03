require 'musix_match'

module Musix #Wrapping MusixMatch APIs
	MusixMatch::API::Base.api_key = 'XXXXXXXXXXXXXXXXXXXXXXX' #get one its free
	def self.search(query_string)
		response = MusixMatch.search_track(:q => query_string,:page_size=>500)
		if response.status_code == 200
		  return response
		else
		  raise response.status_code
		end
	end

	def self.get_lyrics(track_id)
	  response = MusixMatch.get_lyrics(track_id)
	  if response.status_code == 200 && lyrics = response.lyrics
	  	return lyrics
	  else
	  	  raise response.status_code
	  end
	end
end
