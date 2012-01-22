
begin
  require 'rubygems'
  require 'fixed_point'
rescue
  require_relative '../lib/fixed_point'
end


puts
puts 'Unsigned 4 bit Integer'

#Unsigned, 4 bit integer
format = FixedPoint::Format.new(0,4,0)

(0...16).each do |num|
  fixt   = FixedPoint::Number.new(num, format)
  puts "#{format.width}'b#{fixt.to_b}  // #{fixt.to_f} "
end



puts
puts 'Signed 8 bit (6 bit int, 2 bit frac)'

format = FixedPoint::Format.new(1,4,4)

table_for_conversion = [ 
  2.7505, 2.5, 2.25, 2, 0.5, 0, -0.5, -4.5   
]

table_for_conversion.each do |num|
  fixt   = FixedPoint::Number.new(num, format, '_')
  puts "#{format.width}'b#{fixt.to_b}  // Quantised #{fixt.to_f}  Source #{fixt.source}"
end


puts
puts 'As above, in hex and better string formatting in comments'

## NB "%min_length.frac_length" % float_number, min_length wil lpad with saces as required
table_for_conversion.each do |num|
  fixt   = FixedPoint::Number.new(num, format, '_')
  puts "#{format.width}'h#{fixt.to_h}  // Quantised %7.4f  Source %7.4f" % [ fixt.to_f, fixt.source]
end

