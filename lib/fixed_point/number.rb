module FixedPoint

  class Number
    attr_reader :source #Input value
    attr_reader :format

    ############################################
    #### Note
    ## All methods which set the @source value
    ## must also set the @quantised value.
    ## Every thing else is calculated on the fly
    ## based on those 2 values
    ############################################


    def initialize(number, input_format=Format.new(1,12,20), decimal_mark=".")
      @source       = number
      @format       = input_format
      @decimal_mark = decimal_mark

      @warnings     = false

      #Now construct values based on config data
      @quantised    = quantise_value( source )
    end

    ####################################
    ### Numerical overflow flag 
    ####################################
    def overflow?
      @overflow
    end

    ####################################
    ### Numerical underflow flag 
    ####################################
    def underflow?
      @underflow
    end

    ####################################
    ### Methods to return number formats
    ####################################

    # Alias for binary.
    def bin
      binary
    end

    # Alias for hexadecimal.
    def hex
      hexadecimal
    end

    # Alias for binary.
    def to_b
      binary
    end

    # Alias for hexadecimal.
    def to_h
      hexadecimal
    end

    #Floating Point form of the quantised value.
    def to_f
      @quantised
    end

    #Integer, integer part of quantised value.
    def to_i
      @quantised.to_i
    end

    # Fractional section of quantised value.
    def frac
      (@quantised - to_i)
    end

    def to_s
      to_f.to_s
    end

    ####################################
    ### Calculate Binary format
    ####################################
    def binary
      #Take signed quantised value and create binary string
      if (@quantised < 0) and frac.nonzero?
        # Fractional numbers not negative
        # So the integer part is 1 less than other wise would be and add 1+frac
        ret_bin_int = (@format.max_int_unsigned + to_i  )
        frac_value  = 1 + frac
      end

      if (@quantised < 0) and frac.zero?
        ret_bin_int = (@format.max_int_unsigned + to_i + 1 )
        frac_value  = frac
      end

      if @quantised >= 0
        ret_bin_int = self.to_i
        frac_value  = frac
      end

      ## Convert to binary String and extend to correct length
      ret_bin_int = ret_bin_int.to_s(2).rjust(@format.int_bits, '0')

      ## Normalise Fractional (fractional bits shifted to appear as integer)
      ret_bin_frac = Integer(frac_value * 2**@format.frac_bits)
      ret_bin_frac = ret_bin_frac.to_s(2).rjust(@format.frac_bits, '0' ) 

      #Decide if we need to add Decimal( Binary ) Point
      if @format.frac_bits > 0
        binary_string = ret_bin_int +  @decimal_mark + ret_bin_frac
      else 
        binary_string = ret_bin_int
      end

      return binary_string
    end 

    ####################################
    ### Calculate Hexadecimal format
    ####################################
    def hexadecimal
      #Clean Binary code (remove _ - . etc)
      clean_binary = to_b.scan(/[01]/).join('')

      #Convert to unsigned int then to hex
      hex          = clean_binary.to_i(2).to_s(16)
      hex_chars    = (@format.width/4.0).ceil

      ## Extend to the correct length
      ## Negative numbers will already have MSBs this if for small +VE
      return hex.rjust(hex_chars, '0')
    end

    ####################################
    ### Methods to set value from fixed point format
    ####################################
    def binary=(text)
      if text.match(/([01]*)(.?)([01]*)/ )
        set_int       = $1
        int_bits      = $1.size 

        @decimal_mark = $2
        set_frac      = $3
        frac_bits     = $3.size

        #TODO Warn if the number of bits supplied does not match @format 

        ## This should now create a new format type
        #  Do not change the Signed format as can not detect that from bit pattern
        @format = Format.new(@format.signed, int_bits, frac_bits)

        @source  = binary_to_float( set_int, set_frac)
        
        ## Set the Quantised value
        @quantised = @source

        return binary
      else 
        $stderr.puts "ERROR invalid binary input \(#{text}\)"
        return nil
      end
    end

    ## TODO this feature for version 0.2.1
    def hex=( text )
      ## Hex numbers do not get delimited
      ## TODO Strip leading \d+'h (Verilog denominator)
      
      if text.match(/(0x)?([0-9a-fA-F]*)/ )
        # Convert Hex to integer
        #   integer to binary string
        binary_bits = $2.to_i(16).to_s(2)
        
        #Ensure min length (for reliability manipulating string)
        binary_bits = binary_bits.rjust(text.size*4, '0')
       
        if @format.frac_bits > 0
          set_frac = binary_bits[-@format.frac_bits, @format.frac_bits]
        else
          set_frac = ""
        end
        
        set_int  = binary_bits[-(@format.width)..-(@format.frac_bits+1)]

        ## Was the input word length too Long
        oversized_bits = binary_bits.size - @format.width 
        if oversized_bits > 0
          # give a semantic name to the discarded bits
          discarded_bits = binary_bits[0,oversized_bits]

          #If data (mix of 1 and 0) contained in the discarded bits raise Error
          unless all_bits_the_same discarded_bits   
            $stderr.puts %{Error using hex=#{text}, format is #{@format.width}, truncated data is #{discarded_bits}
  The MSBs seem to contain data they are not just 0 or 1 padded}
          end
        end

        @source    = binary_to_float( set_int, set_frac )
        @quantised = @source

      else
        $stderr.puts "ERROR invalid hex input \(#{text}\)"
        return nil
      end
    end


    #TODO
    #def log
    #def log2

    def warnings( val=true )
      @warnings = val
    end

    private

    def all_bits_the_same( bin_string )
      word = bin_string.split('')
      all_one = word.all?{|x| x == '1' }
      all_zero = word.all?{|x| x == '0' }
      return  (all_one || all_zero)
    end

    
    def check_for_overflow_underflow( source, format)
      overflow  = false
      underflow = false

      #WARN +VE
      if (source > 0) and (source > format.max_value)
        puts "WARNING Maximum number is #{format.max_value} input was #{source}" if @warnings 
        overflow = true
      end

      ##WARN -VE
      if (source < 0) and (source < format.min_value)
        puts "WARNING Minimum number is #{format.min_value} input was #{source}" if @warnings
        underflow = true
      end

      return [overflow, underflow]
    end


    def quantise_value( source )
      #Overflow / Underflow flags
      @overflow, @underflow = check_for_overflow_underflow( source, @format)
      
      ## Create fractional only number
      source_frac = source - source.to_i

      #Logic for fractional negative numbers is different
      if (( source < 0) and source_frac.nonzero? )
        #Integer bits become 1 more negative
        number_int  = Integer( source )-1

        #The @fractional part inverts so int+frac = original number
        number_frac = ( source - number_int)
      else
        # Create Integer only number
        number_int  = source.to_i
        
        #Fractional Part
        number_frac = source_frac
      end


      if overflow?
        if @format.signed?
          number_int  = @format.max_int_signed
          number_frac = @format.max_frac
        else
          number_int  = @format.max_int_unsigned
          number_frac = @format.max_frac
        end
      end

      if underflow?
        if @format.signed?
          number_int  = 2**(@format.int_bits-1)
          number_frac = 0
        else
          number_int  = 0
          number_frac = 0
        end
      end

      ##Roll the integer number over the number space so binary conversion gives correct Twos complement
      if number_int < 0
        number_int = @format.max_int_unsigned + (number_int + 1)
      end

      ###################################
      ### Quantized Fractional value
      ###################################
      # Normalise, represent as integer
      # Fractional data is removed by the integer.
      # We are only left with @format.frac_bits worth of data
      number_frac_quant = (number_frac * 2**@format.frac_bits).to_i / (2**@format.frac_bits).to_f

      # TODO Comment on what this is actually doing
      # some sought of signed conversion
      if (@source < 0) and number_frac_quant.nonzero?
        number_int        = number_int - @format.max_int_unsigned
        number_frac_quant = number_frac_quant - 1
      end

      if (@source < 0) and number_frac_quant.zero?
        number_int        = number_int - @format.max_int_unsigned - 1
        number_frac_quant = 0
      end

      return (number_int + number_frac_quant)
    end ## quantise_input



    ##
    def binary_to_float(int_part, frac_part ) 
      index    = 0
      value    = 0.0
      int_part.reverse.each_char do |x|
        if x == "1"
          #If input is signed then MSB is negative
          if ((index + 1) == @format.int_bits) and (@format.signed?)
            value = value + -2**index 
          else  
            value = value + 2**index 
          end
        end
        index = index + 1
      end

      index = 1
      frac_part.each_char do |x|
        if x == "1"
          value = value + 2**-index
        end
        index = index + 1
      end

      return value
    end

   
    ## Taking method out until covered by tests
    #def normalised
    #  #This use to be only for positive numbers
    #
    #  # This function shifts the fixedpoint number 
    #  #   so it can be represented as an integer.
    #  return  Integer((@quantised)*(2**@format.frac_bits))
    #end

    def FixedPoint_debug(msg)
      if true == false
        puts msg
      end
    end
  end #class number
end #module FixedPoint
