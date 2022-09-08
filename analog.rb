require 'arduino_firmata'
require 'csv'

board = ArduinoFirmata.connect '/dev/ttyUSB0'
sensor_pin = 0


board.pin_mode(sensor_pin, ArduinoFirmata::INPUT)

def calculate_distance(raw_ADC)
    output = raw_ADC
    voltage = output * 5.0/1024.0
    numr = voltage**(-1.173)
    distance = 29.988 * numr
end

SLEEP_TIME = 0.01
TRIALS_PER_RESULT = 10

# while true do
@distance = 0
@biggest = 0
@smallest = 1000
TRIALS_PER_RESULT.times do 
    raw_ADC = board.analog_read(sensor_pin)
    # puts "sensor pin: #{format('%.2f', raw_ADC)}"
    puts calculate_distance(raw_ADC)
    @distance += raw_ADC    
    @biggest = raw_ADC if raw_ADC > @biggest
    @smallest = raw_ADC if raw_ADC < @smallest
    puts "biggest = #{@biggest}/// smallest = #{@smallest}"
    sleep(SLEEP_TIME)
end
puts "difference is #{(calculate_distance(@smallest) - calculate_distance(@biggest)).round(2)}"
@difference = calculate_distance(@smallest) - calculate_distance(@biggest)
@difference = @difference.round(2)

@distance = @distance /TRIALS_PER_RESULT
distance = calculate_distance(@distance).round(2)
puts "distance = #{distance.round(2)}"
CSV.open("sleep_data.csv", 'a+') do |csv|
	csv << ["#{SLEEP_TIME}", "|#{distance}|","#{@difference}", "#{TRIALS_PER_RESULT}"]
end

board.close