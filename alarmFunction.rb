require 'rubygems'
#Sinatra
require 'sinatra'
require 'sinatra/reloader'
#Weather
require 'forecast_io'

#Scheduler
# require 'rufus/scheduler'
# @@scheduler = Rufus::Scheduler.new
# #end
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
		time = diff
	else
		time = diff + (1440) # 24 hours * 60 minutes
	end

	if session[:weather_toggle] == "true"
		if weather(time) > 0.5
			session[:diff] = time
			return time - 15
		else
			session[:diff] = time
			return time
		end
	else
		session[:diff] = time
		return time
	end

end

def weather(time_diff)
	ForecastIO.api_key = 'b6e2ffc9d69a08d04659a92599cc7ea8'
	session[:forecast] = ForecastIO.forecast(41.3111, -72.9241, time: (Time.now + (time_diff*60)).to_i) # params are: latitude, longitude
	#puts forecast.currently # gives you the current forecast datapoint
	return session[:forecast].currently.precipProbability # =>"Mostly Cloudy"
end

def ring(time_diff)
  @refresh = time_diff*5 #*60
end

def select_song()
	ForecastIO.api_key = 'b6e2ffc9d69a08d04659a92599cc7ea8'
	session[:forecast] = ForecastIO.forecast(41.3111, -72.9241, time: (Time.now + (session[:diff]*60)).to_i)

	if session[:forecast].currently.temperature > 70 && session[:forecast].currently.cloudCover < 0.5
		return 'src="sunny.m4a"'
	elsif session[:forecast].currently.cloudCover > 0.5
		return 'src="cloudy.m4a"'
	elsif session[:forecast].currently.precipProbability > 0.5 && session[:forecast].currently.temperature < 32
		return 'src="snowy.m4a"'
	elsif session[:forecast].currently.precipProbability > 0.5
		return 'src="rainy.m4a"'
	else
		return 'src="default.wav"'
	end
end

#'src="song.wav"'

#Set all of the parameters for which we use conditionals to true
@@alarm_count = nil
@@alarm_toggle = nil
@@alarm_delete = nil
#Sinatra routing
get '/' do
	session[:alarmTime]||={}
	time_now ||= ""
	#We initialize refresh in this way so that it is there, but that
	#it never refreshes the page unless we wanted to
	@refresh = 999999999999999999999999

	if params[:delete] == "Delete Alarm" #if users presses the Delete
	# Alarm button, it sets the page back to resting state
		@@alarm_count = nil
		@@alarm_delete = nil
	end

	if @@alarm_count == nil  #alarm_count is the variable that determines
		#if the song plays or not. 
		@autoplay = 'autoplay = "false"'
	end

	if session[:sat_toggle] == "true"
		@@alarm_count = nil
		@@alarm_delete = nil
		redirect '/alarm'
	else
		if @@alarm_count == 0
		#Triggers the alarm and turns on the alarm turn off button
		@autoplay = 'autoplay = "true"'
		@alarm_turn_off = '<button><a href="/">Turn off alarm</a></button>'
		@@alarm_count = nil
		@@alarm_delete = nil
		@song = select_song()
		
		end
	end

	

	erb :index, :locals => { :currentAlarm => session[:alarmTime],
													 :time_now => time_now,
													 :autoplay => @autoplay,
													 :refresh => @refresh,
													 :alarm_count => @@alarm_count,
													 :alarm_turn_off => @alarm_turn_off,
													 :alarm_delete => @@alarm_delete,
													 :song => @song
												 }
end

post '/' do
	time_now = Time.now.strftime("%H:%M")
	session[:alarmTime] = params[:alarmTime]
	session[:sat_toggle] = params[:sat_toggle]
	session[:weather_toggle] = params[:weather_toggle]
	#time_diff is just the output of the 'convert' function saved
	#in the session. 
	session[:time_diff]=convert(time_now, session[:alarmTime])
	ring(session[:time_diff])
	@autoplay = 'autoplay = "false"' #initialize the autoplay
	@@alarm_count = 0
	@@alarm_delete = '<form method = "get" action="/">
<input type="submit" value="Delete Alarm" name="delete">
</form>' #the alarm delete only comes on after the alarm is set.

	erb :index, :locals => { :currentAlarm => params[:alarmTime],
													 :time_now => time_now,
													 :autoplay => @autoplay,
													 :refresh => @refresh,
													 :alarm_count => @@alarm_count,
													 :alarm_turn_off => @alarm_turn_off,
													 :alarm_delete => @@alarm_delete,
													 :song => @song
												 }
end


q_array = [

['Test #1 - answer is B
Read the following SAT test question and then click on a button to select your answer.
<br>
Which of the following CANNOT be the lengths of the sides of a triangle?
<form method="get" action="/alarm">
<input type="radio" name="question" value="A">1,1,1<br>
<input type="radio" name="question" value="B">1,2,4<br>
<input type="radio" name="question" value="C">1,75,75<br>
<input type="radio" name="question" value="D">2,3,4<br>
<input type="radio" name="question" value="E">5,6,8<br>
<input type="submit">
</form>',"B"],


['Choose the word or set of words that, when inserted in the sentence, best fits the meaning of the sentence as a whole. 
<br>
While a “rock” is usually defined as ------- , or a combination, of one or more minerals, geologists often ------- the 
<br> definition to include such materials as clay, loose sand, and certain limestones.
<form method="get" action="/alarm">
<input type="radio" name="question" value="A">a conglomeration . . limit<br>
<input type="radio" name="question" value="B">an aggregate . . extend<br>
<input type="radio" name="question" value="C">an element . . eliminate<br>
<input type="radio" name="question" value="D">a blend . . restrict<br>
<input type="radio" name="question" value="E">a product . . provide<br>
<input type="submit">
</form>', "B"],

['Choose the word or set of words that, when inserted in the sentence, best fits the meaning of the sentence as a whole. 
<br>
Those scholars who believe that the true author of the poem died in 1812 consider the authenticity of this particular manuscript ------- because 
<br>it includes references to events that occurred in 1818.
<form method="get" action="/alarm">
<input type="radio" name="question" value="A">ageless<br>
<input type="radio" name="question" value="B">tenable<br>
<input type="radio" name="question" value="C">suspect<br>
<input type="radio" name="question" value="D">unique<br>
<input type="radio" name="question" value="E">legitimate<br>
<input type="submit">
</form>', "C"]

]

@@question_counter = 0
get '/alarm' do
  if @@question_counter == 0
    session[:num] = rand(0..1)
    @question = q_array[session[:num]][0]
    @answer = q_array[session[:num]][1]
    session[:question] = @question
    session[:answer] = @answer
    @@question_counter = 1
  end
  if params[:question] == session[:answer]
      session[:sat_toggle] = nil
      @@question_counter = 0
      redirect '/'
  end
  @song = select_song()
  erb :alarm, :locals => {:question => session[:question],
                          :answer => session[:answer],
                          :question_counter => @@question_counter,
                          :song => @song
                         }
end