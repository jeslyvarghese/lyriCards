require 'sinatra'
require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection(  
:adapter => "mysql",  
:host => 'instance21633.db.xeround.com',
:port=>14290,  
:database => "lyri",
:username=> "lyri_root",
:password => "walnut"  
)

class Track<ActiveRecord::Base
	belongs_to :artist
	belongs_to :album
	has_one :lyric
	validates :mxid, :uniqueness=>true
end

class Artist<ActiveRecord::Base
	has_many :albums
	has_many :tracks , :through=>:albums
	validates :mxid, :uniqueness=>true
end

class Album<ActiveRecord::Base	
	belongs_to :artist
	has_many :tracks
	validates :mxid, :uniqueness=>true
end

class Lyric<ActiveRecord::Base	
	belongs_to :track
	belongs_to :album
	validates :mxid, :uniqueness=>true
end

class User<ActiveRecord::Base
	has_many :posts
end

class Post<ActiveRecord::Base
	belongs_to :user
end