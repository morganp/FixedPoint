FixedPoint
============

For modeling fixed point signed and unsigned data types and having nice function for printing hex and binary forms.

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
    
TODO
----


LICENSE
-------

See the LICENSE file
