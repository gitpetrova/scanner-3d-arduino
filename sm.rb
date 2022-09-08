require 'arduino_firmata'

BOARD = ArduinoFirmata.connect '/dev/ttyUSB0'
SENSOR_PIN = 0
PLATFORM_STEP_PIN = 3
PLATFORM_DIR_PIN = 2
VERTICAL_STEP_PIN = 5 
VERTICAL_DIR_PIN = 6

def motor_controller(steps, period, step_pin, dir_pin, direction = true)
	steps.times do
		BOARD.digital_write(dir_pin, direction)
		BOARD.digital_write(step_pin, true)
		sleep(period)
		BOARD.digital_write(step_pin, false)
		sleep(period)
	end
end

MOTOR_ROTATION_STEPS = 200.0
DISTANCE_TO_THE_CENTER = 11.2

RADIANS = (360.0/MOTOR_ROTATION_STEPS)*((Math::PI)/180.0)
@angle = 0

Z_LAYER_HEIGHT = 0.2
THREAD_PITCH = 8
ONE_STEP_HEIGH = THREAD_PITCH/MOTOR_ROTATION_STEPS
STEPS_PER_LAYER = Z_LAYER_HEIGHT/ONE_STEP_HEIGH

NUM_OF_SCANS = 20
DELAY_BETWEEN_SURVEYS = 0.01

def calculate_distance(raw_ADC)
	output = raw_ADC
	voltage = output * 5.0/1024.0
	numr = voltage**(-1.173)
	distance = 29.988 * numr
end

def sensor_controller
	@distance = 0
	NUM_OF_SCANS.times do 
		raw_ADC = BOARD.analog_read(SENSOR_PIN)
		# puts "sensor pin: #{format('%.2f', raw_ADC)}"
		@distance += raw_ADC
		sleep(DELAY_BETWEEN_SURVEYS)
	end
	return @distance = @distance/NUM_OF_SCANS
end

@zlayer = 0.0

def platform
	sensor = calculate_distance(sensor_controller)
	# break if (sensor < 10 || sensor > 24)
	puts sensor.round(2), " "
	if sensor > 7.8 && sensor < 11
		dimension = DISTANCE_TO_THE_CENTER - sensor 
		@angle = @angle + RADIANS
		# puts "dimension =#{dimension} and anngle = #{@angle}"
		x = (Math.sin(@angle)*dimension).round(4)
		y = (Math.cos(@angle)*dimension).round(4)
		motor_controller(1,0.0001,PLATFORM_STEP_PIN,PLATFORM_DIR_PIN)
		@text = "#{x} #{y} #{@zlayer.round(2)}" 
		puts "#{@text} | #{dimension.round(4)}"
	else 
		zaxis
	end
	return @text
end

def zaxis
	motor_controller(STEPS_PER_LAYER.to_i,0.001,VERTICAL_STEP_PIN,VERTICAL_DIR_PIN, true)
  @zlayer+=(Z_LAYER_HEIGHT*0.1).round(3)
end

def zaxis_back
	motor_controller(50,0.001,VERTICAL_STEP_PIN,VERTICAL_DIR_PIN, true)
  @zlayer+=1
end

def mesh_read
  time = Time.now.strftime("%Y-%m-%d_%H_%M_%S")
  File.open("meshes/mesh#{time}.txt",'a+') do |file|
    250.times do |i|
			200.times do |vert|
				platform
				file.puts(@text)
				print "__#{i} #{vert}__"
			end
      zaxis
    end
  end
  #until distances are cool, keep going
  #max and minimal height
  #write it to txt file in format needed
end

def test_mesh_read
  time = Time.now.strftime("%Y-%m-%d_%H_%M_%S")
  File.open("meshes/mesh#{time}.txt",'a+') do |file|
    280.times do |i|
			1.times do 
				platform
				file.puts(@text)
			end
      puts @zlayer
      zaxis
    end
  end
end

mesh_read
# zaxis_back
# platform
puts STEPS_PER_LAYER 
puts ONE_STEP_HEIGH 
BOARD.close