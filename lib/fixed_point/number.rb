module FixedPoint

  class Number
    attr_reader :source
    attr_reader :format

    #Flags
    attr_reader :overflow
    attr_reader :underflow


    def bin(val="")
      return @binary
    end

    def hex(val="")
      return hexadecimal
    end

    #To Binary form
    def to_b
      return @binary
    end

    #To Hexadecimal form
    def to_h
      return hexadecimal
    end

    #To Floating Point form, quantised version of _source_
    def to_f
      return (@number_int + @number_frac)
    end

    #To Integer, limited integer part of _source_ 
    def to_i
      return @number_int
    end

    # Method returns fractional section of fixed point type
    # not a to_ method as it is not representative of the whole number
    def fraction
      return @number_frac
    end

    # Method to set binary value
    # int_bits frac_bits and decimal_mark are also interpretted from string 
    # Signed is assumed.
    def binary(text="")
      #Should match ([01]*)(.?)([01]*)
      #int_bits     = Size of \1
      #decimal_mark = \2
      #frac_bits    = \3

      unless text == ""
        if text.match(/([01]*)(.?)([01]*)/ )
          #Currently init forces @signed to 1 if not defined
          #but we should not override if already set
          #@signed       ||= 1
          int_bits      = $1.size 
          @decimal_mark = $2
          frac_bits     = $3.size

          #TODO Warn if the number of bits supplied does not match @format 

          #This should now create a new format type
          @format = Format.new(@format.signed, int_bits, frac_bits)

          ###########################
          ### Routine to generate source from binary
          ###########################
          @source       = 0.0
          index = 0
          $1.reverse.each_char do |x|
            if x == "1"
              #If input is signed then MSB is negative
              if ((index + 1) == @format.int_bits) and (@format.signed?)
                @source = @source + -2**index 
              else  
                @source = @source + 2**index 
              end
            end
            index = index +1
          end

          index = 1
          $3.each_char do |x|
            if x == "1"
              @source = @source + 2**-index
            end
            index = index + 1
          end
          ################################

          set_values
          if text == to_b
            return to_b
          else
            #Rasie exception  with programming bug

          end
        else 
          puts "ERROR invalid input binary\(#{text}\)"
          return nil
        end
      else
        return to_b
      end
    end

    #TODO
    #def log
    #def log2

    #TODO all input to init can be set and set method just calls set_values

    ##Convert Decimal numbers to fixed point Binary
    #def initialize(number, signed=1, int_bits=12, frac_bits=20, decimal_mark=".")
    def initialize(number, input_format=Format.new(1,12,20), decimal_mark=".")

      @source       = number
      @format       = input_format
      @decimal_mark = decimal_mark

      @warnings     = false

      #Now construct values based on config data
      set_values
    end


    def warnings( val=true )
      @warnings = val
    end

    private


    def set_values
      #Overflow / Underflow flags
      @overflow  = false
      @underflow = false

      #WARN +VE
      if (@source > 0) and (@source > @format.max_value)
        puts "WARNING Maximum number is #{@format.max_value} input was #{@source}" if @warnings 
        @overflow = true
      end

      ##WARN -VE
      if (@source < 0) and (@source < @format.min_value)
        puts "WARNING Minimum number is #{@format.min_value} input was #{@source}" if @warnings
        @underflow = true
      end


      ## Create Integer only number
      @number_int  = Integer(@source)

      ## Create fractional only number
      @number_frac = @source - @number_int



      #Logic for fractional negative numbers is different
      if ((@source < 0) and (not @number_frac==0))
        #integer bits become 1 more negative
        @number_int  = Integer(@source)-1
        #The @fractional part inverts so int+frac = original number
        @number_frac = (@source - @number_int)
      end

      if @overflow == true
        if @format.signed == 1
          @number_int  = @format.max_int_signed
          @number_frac = @format.max_frac
        else
          @number_int  = @format.max_int_unsigned
          @number_frac = @format.max_frac
        end
      end

      if @underflow == true
        if @format.signed == 1
          @number_int  = 2**(@format.int_bits-1)
          @number_frac = 0
        else
          @number_int  = 0
          @number_frac = 0
        end
      end

      ##Roll the integer number over the number space so binary conversion gives correct Twos complement
      if @number_int < 0
        @number_int = @format.max_int_unsigned + (@number_int+1)
      end

      ## Create Integer Binary String
      ret_bin_int = ""

      ## Create fractional Binary String
      ret_bin_frac = ""

      ##Integer
      ret_bin_int = @number_int.to_s(2) 
      padding_bits = @format.int_bits - ret_bin_int.length 
      begin
        ret_bin_int =  Array.new(padding_bits, "0").join + ret_bin_int 
      rescue
        ##The new limiters for correct binary/hex numbers should mean this never gets seen
        puts "WARNING not enough integer bits to represent #{number}" if @warnings
      end

      ## fractional
      ret_bin_frac = Integer(@number_frac * 2**@format.frac_bits).to_s(2)

      padding_bits = @format.frac_bits - ret_bin_frac.length 

      if padding_bits > 0 
        ret_bin_frac =  Array.new(padding_bits, "0").join + ret_bin_frac 
      end

      #throwing away original value of @number_frac
      #Until this point @number_frac has been the fractional part of source not the quantised version
      @number_frac = ret_bin_frac.to_i(2).to_f / (2**@format.frac_bits)
      if @format.frac_bits > 0
        @binary = ret_bin_int +  @decimal_mark + ret_bin_frac
      else 
        @binary = ret_bin_int
      end

      #puts
      #puts "#{@number_int} . #{@number_frac}"


      # TODO Comment on what this is actually doing
      # some sought of signed conversion
      if (@source < 0) and @number_frac.nonzero?
        @number_int  = @number_int - @format.max_int_unsigned
        @number_frac = @number_frac - 1
      end

      if (@source < 0) and @number_frac.zero?
        @number_int  = @number_int - @format.max_int_unsigned - 1
        @number_frac = 0
      end
      #puts "#{@number_int} . #{@number_frac}"

    end

    def hexadecimal
      #Clean Binary code (remove _ - . etc)
      clean_binary = to_b.scan(/[01]/).join('')

      #Convert to unsidnged int then to hex
      hex          = clean_binary.to_i(2).to_s(16)
      hex_chars    = (@format.width/4.0).ceil

      ## Extend to the correct length
      ## Negative numbers will already have MSBs this if for small +VE
      @hexadecimal = hex.rjust(hex_chars, '0')
    end

    def normalised
      #This use to be only for positive numbers

      # This function shiftes the fixedpoint number 
      #   so it can be represented as an integer.
      return  Integer((@number_int+@number_frac)*(2**@format.frac_bits))
    end

    def FixedPoint_debug(msg)
      if true == false
        puts msg
      end
    end
  end #class number
end #module FixedPoint
