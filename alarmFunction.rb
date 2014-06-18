require 'rubygems'
#Sinatra
require 'sinatra'
require 'sinatra/reloader'
#Scheduler
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

def ring(time_diff)
  @refresh = time_diff*10 #*60
end

@delete_alarm = 'hidden = "true"'
@@alarm_count = nil
@alarm_toggle = nil
@alarm_delete = nil
#Sinatra routing
get '/' do
	session[:alarmTime]||={}
	time_now ||= ""
	@refresh = 999999999999999999999999

	if params[:delete] == "Delete Alarm"
		@@alarm_count = nil
		@alarm_delete = nil
	end
	# if session[:alarm_toggle = ]
	if @@alarm_count == nil
		@autoplay = 'autoplay = "false"'
	end

	if @@alarm_count == 0
		@autoplay = 'autoplay = "true"'
		@alarm_turn_off = '<button><a href="/">Turn off alarm</a></button>'
		@@alarm_count = nil
	end

	erb :index, :locals => { :currentAlarm => session[:alarmTime],
													 :time_now => time_now,
													 :autoplay => @autoplay,
													 :refresh => @refresh,
													 :alarm_count => @@alarm_count,
													 :alarm_turn_off => @alarm_turn_off,
													 :alarm_delete => @alarm_delete
												 }
end

post '/' do
	time_now = Time.now.strftime("%H:%M")
	session[:alarmTime] = params[:alarmTime]
	#time_diff is just the output of the 'convert' function saved
	#in the session. 
	session[:time_diff]=convert(time_now, session[:alarmTime])
	ring(session[:time_diff])
	@autoplay = 'autoplay = "false"'
	@@alarm_count = 0
	@alarm_delete = '<form method = "get" action="/">
<input type="submit" value="Delete Alarm" name="delete">
</form>'
	erb :index, :locals => { :currentAlarm => session[:alarmTime],
													 :time_now => time_now,
													 :autoplay => @autoplay,
													 :refresh => @refresh,
													 :alarm_count => @@alarm_count,
													 :alarm_turn_off => @alarm_turn_off,
													 :alarm_delete => @alarm_delete
												 }
end