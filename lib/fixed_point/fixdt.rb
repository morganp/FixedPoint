module FixedPoint
  class Fixdt < Format
    #Designed to be compatible with Matlab/Simulink types
    def initialize(signed, width, frac_bits)
      super( signed, width-frac_bits, frac_bits )
    end
  end
end #module FixedPoint
