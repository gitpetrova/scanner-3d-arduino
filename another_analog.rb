require 'arduino_firmata'

board = ArduinoFirmata.connect '/dev/ttyUSB0'
sensor_pin = 0


board.pin_mode(sensor_pin, ArduinoFirmata::INPUT)

def calculate_distance(raw_ADC)
    output = raw_ADC
    voltage = output * 5.0/1024.0
    numr = voltage**(-1.173)
    distance = 29.988 * numr
end

def other_calc(raw_ADC)
    output = raw_ADC
    dist = -
end

# while true do
@distance = 0
@biggest = 0
@smallest = 1000
100.times do 
    raw_ADC = board.analog_read(sensor_pin)
    # puts "sensor pin: #{format('%.2f', raw_ADC)}"
    puts calculate_distance(raw_ADC)
    @distance += raw_ADC    
    sleep(0.001)
    @biggest = raw_ADC if raw_ADC > @biggest
    @smallest = raw_ADC if raw_ADC < @smallest
    puts "biggest = #{@biggest}/// smallest = #{@smallest}"
    sleep(0.02)
end
puts "difference is #{calculate_distance(@biggest) - calculate_distance(@smallest)}"

@distance = @distance /100
distance = calculate_distance(@distance)
puts "distance = #{distance}"

board.close