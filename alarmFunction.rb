require 'sinatra'
require 'sinatra/reloader'
configure do
  enable :sessions
end

get '/' do
	session[:alarmTime]||={}
	currentAlarm ||= ""
	erb :index
	#, :locals => { :currentAlarm => currentAlarm}
end

post '/' do
	#currentAlarm << 
	currentAlarm = params[:alarmTime]

	erb :index
	#, :locals => { :currentAlarm => currentAlarm}
end