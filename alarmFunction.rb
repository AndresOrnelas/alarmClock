require 'sinatra'
require 'sinatra/reloader'
#Scheduler
require 'rubygems'
require 'rufus/scheduler'
@@scheduler = Rufus::Scheduler.new
#end
configure do
  enable :sessions
end
#Functions
def convert(current, alarm)
	# This function takes the time entered by the user and
	# the current time generated when the user clicks the button and
	# returns the difference of both in minutes.
	curr_arr = current.split(":")
	alarm_arr = alarm.split(":")

	curr_hours = curr_arr[0].to_i*60
	curr_min = curr_arr[1].to_i
	curr_time_min = curr_hours + curr_min

	alarm_hours = alarm_arr[0].to_i*60
	alarm_min = alarm_arr[1].to_i
	alarm_time_min = alarm_hours + alarm_min

	diff = alarm_time_min - curr_time_min
	if diff > 0
		return diff
	else
		return diff + (1440) # 24*60
	end
end

def ring
	@@scheduler.in session[:time_diff].to_s + 'm' do
  	puts "order ristretto"
	end
end



#Sinatra routing
get '/' do
	session[:alarmTime]||={}
	time_now ||= ""
	erb :index, :locals => { :currentAlarm => session[:alarmTime], :time_now => time_now}
end

post '/' do
	time_now = Time.now.strftime("%H:%M")
	session[:alarmTime] = params[:alarmTime]
	#time_diff is just the output of the 'convert' function saved
	#in the session. 
	session[:time_diff]=convert(time_now, session[:alarmTime])
	ring()
	erb :index, :locals => { :currentAlarm => session[:alarmTime], :time_now => time_now}
end