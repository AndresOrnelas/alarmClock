require 'sinatra'
require 'sinatra/reloader'
configure do
  enable :sessions
end
#functions
def convert(current, alarm)
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

get '/' do
	session[:alarmTime]||={}
	time_now ||= ""
	erb :index, :locals => { :currentAlarm => session[:alarmTime], :time_now => time_now}
end

post '/' do
	time_now = Time.now.strftime("%H:%M")
	session[:alarmTime] = params[:alarmTime]
	
	return convert(time_now, session[:alarmTime]).to_s
	# diff_time(time_now, session[:alarmTime])
	# return diff_time
	erb :index, :locals => { :currentAlarm => session[:alarmTime], :time_now => time_now}
end