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

motor_controller(1000,0.001,VERTICAL_STEP_PIN,VERTICAL_DIR_PIN, false)


BOARD.close
#false = down