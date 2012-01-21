module FixedPoint

  class Format

    attr_reader :signed, :int_bits, :frac_bits
    
    # Calculated attributes
    attr_reader :width
    attr_reader :resolution, :max_value, :min_value 
    attr_reader :max_int_signed, :max_int_unsigned
    attr_reader :max_frac
    attr_reader :max_signed, :max_unsigned

    def initialize(signed, int_bits, frac_bits)
      @signed    = signed
      @int_bits  = int_bits
      @frac_bits = frac_bits

      calculate_attributes(signed, int_bits, frac_bits)
    end

    def signed?
      (@signed == 1)
    end

    #Format Should hold the maxim possible values
    #not part of number (Value)
    def calculate_attributes(signed, int_bits, frac_bits)
      @width     = int_bits + frac_bits

      #Calculate Number ranges
      @resolution       = 2**(-@frac_bits)
      @max_frac         = 1 - 2**(-@frac_bits)
      @max_int_signed   = ( 2**(@int_bits - 1) - 1)
      @max_int_unsigned = ( 2**@int_bits       - 1)
      @max_signed       = @max_int_signed   + @max_frac
      @max_unsigned     = @max_int_unsigned + @max_frac

      @min_signed       = (-2**(@int_bits-1))
      @min_unsigned     = 0

      #Set Max/Min values
      if signed?
        @max_value = @max_signed
        @min_value = @min_signed 
      else 
        @max_value = @max_unsigned
        @min_value = @min_unsigned
      end

    end

  end

end #module FixedPoint
