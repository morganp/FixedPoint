FixedPoint
============

Ruby gem for modelling fixed point signed and unsigned data types with methods for nicely displaying hex and binary forms.

Install
-------

    gem install fixed_point

Usage
-----

Checkout the examples folder, but here are a few:
 
    require 'fixed_point'

    #Create fixed point format, Signed, 12 integer bits, 4 fractional bits
    format  = FixedPoint::Format.new(1, 12, 4) 

    #Create fixed_point with value 1024.75
    fix_num = FixedPoint::Number.new(1024.75, format )

    puts fix_num.to_f # Float
    puts fix_num.to_h # Hexadecimal
    puts fix_num.to_b # Binary
    
Building tables:

    require 'fixed_point'
    
    #Signed 8 bit, (4 bit Integer, 4 bit fractional)
    format = FixedPoint::Format.new(1,4,4)

    table_for_conversion = [ 
      2.7505, 2.5, 2.25, 2, 0.5, 0, -0.5, -4.5   
    ]

    table_for_conversion.each do |num|
      fixt   = FixedPoint::Number.new(num, format, '_')
      puts "#{format.width}'b#{fixt.to_b}  // Quantised %7.4f  Source %7.4f" % [ fixt.to_f, fixt.source]
    end

Returns:

    8'b0010_1100  // Quantised  2.7500  Source  2.7505
    8'b0010_1000  // Quantised  2.5000  Source  2.5000
    8'b0010_0100  // Quantised  2.2500  Source  2.2500
    8'b0010_0000  // Quantised  2.0000  Source  2.0000
    8'b0000_1000  // Quantised  0.5000  Source  0.5000
    8'b0000_0000  // Quantised  0.0000  Source  0.0000
    8'b1111_1000  // Quantised -0.5000  Source -0.5000
    8'b1011_1000  // Quantised -4.5000  Source -4.5000




TODO
----


LICENSE
-------

See the LICENSE file
