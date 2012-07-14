require 'sinatra'
require 'haml'

enable :sessions

get '/' do
	haml :index
end

get '/select' do
	haml :select
end

get '/spice' do
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