require 'spec_helper'

# def initialize(number, Format.new(signed=1, int_bits=12, frac_bits=20), decimal_mark=".")
# source Input Number 
# to_f   quantised value as float
# to_i   quantised value as integer
# frac   fractional part of quantised value
# to_h   quantised value as string formatted as hex
# to_b   quantised value as string formatted as binary
#

describe FixedPoint do

  it "Returns 0.0 for initalise of 0" do
    fixt = FixedPoint::Number.new(0)

    fixt.source.should    == 0.0
    fixt.to_f.should      == 0.0
    fixt.to_s.should      == "0.0"
    fixt.to_i.should      == 0
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "00000000"
    fixt.to_b.should      == "000000000000.00000000000000000000"  
end

it "Integers 0 " do
  format = FixedPoint::Format.new(1,8,0)
  fixt   = FixedPoint::Number.new(7.0, format, "_")

  fixt.source.should   == 7.0
  fixt.to_f.should     == 7.0
  fixt.to_s.should     == "7.0"
  fixt.to_i.should     == 7
  fixt.frac.should     == 0.0
  fixt.to_h.should     == "07"
  fixt.to_b.should     == "00000111"
end

it "Different Decimal Mark _ instead of ." do
  format = FixedPoint::Format.new(1,12,20)
  fixt   = FixedPoint::Number.new(0, format, "_")

  fixt.source.should   == 0.0
  fixt.to_f.should     == 0.0
  fixt.to_s.should     == "0.0"
  fixt.to_i.should     == 0
  fixt.frac.should     == 0.0
  fixt.to_h.should     == "00000000"
  fixt.to_b.should     == "000000000000_00000000000000000000"
end

(1...20).to_a.reverse_each do |x|
  int_bits = 12
  it "Returns 0.0 for initalise of 0 with #{x} fractional bits" do
    format = FixedPoint::Format.new(1, int_bits, x)
    fixt   = FixedPoint::Number.new(0, format)
    #fixt = FixedPoint::Number.new(0,1,int_bits,x)

    fixt.source.should   == 0.0
    fixt.to_f.should     == 0.0
    fixt.to_s.should     == "0.0"
    fixt.to_i.should     == 0
    fixt.frac.should     == 0.0
    #Calculate hex length and fill with 0's
    hex = ""
    hex_length = ((x.to_f+int_bits.to_f)/4).ceil
    hex_length.times { hex += "0" }
    fixt.to_h.should     == hex
    #Calculate binary fractional length and fill with 0's
    lsbs = ""
    x.times { lsbs += "0" }
    fixt.to_b.should     == "000000000000.#{lsbs}"
end
end


it "Zero fractional bits " do
  format = FixedPoint::Format.new(1,12,0)
  fixt   = FixedPoint::Number.new(0, format, "_")

  fixt.source.should   == 0.0
  fixt.to_f.should     == 0.0
  fixt.to_s.should     == "0.0"
  fixt.to_i.should     == 0
  fixt.frac.should     == 0.0
  fixt.to_h.should     == "000"
  fixt.to_b.should     == "000000000000"
end


it "returns 2.5 for initalise of 2.5" do
  fixt = FixedPoint::Number.new(2.5)

  fixt.source.should   == 2.5
  fixt.to_f.should     == 2.5
  fixt.to_s.should     == "2.5"
  fixt.to_i.should     == 2
  fixt.frac.should     == 0.5
  fixt.to_h.should     == "00280000"
  fixt.to_b.should     == "000000000010.10000000000000000000"
  end


  it "Truncates fractional numbers correctly" do
    format = FixedPoint::Format.new(1,12,1)
    fixt   = FixedPoint::Number.new(2.501, format)

    fixt.source.should   == 2.501
    fixt.to_f.should     == 2.5
    fixt.to_s.should     == "2.5"
    fixt.to_i.should     == 2
    fixt.frac.should     == 0.5
    fixt.to_h.should     == "0005"
    fixt.to_b.should     == "000000000010.1"
  end

  ##############################################
  ###   Overflow Section
  ##############################################
  it "Forced Overflow 4 Int Bits, 0 fractional bits " do
    format = FixedPoint::Format.new(1, 4, 0)
    fixt   = FixedPoint::Number.new(2**3, format, "_")

    fixt.source.should     == 2**3
    fixt.to_f.should       == 2**3-1
    fixt.to_s.should       == "7.0"
    fixt.to_i.should       == 2**3-1
    fixt.frac.should       == 0.0
    fixt.to_h.should       == "7"
    fixt.to_b.should       == "0111"
    fixt.overflow?.should  == true
    fixt.underflow?.should == false
  end

  it "Forced Overflow Zero fractional bits " do
    format = FixedPoint::Format.new(1, 12, 0)
    fixt   = FixedPoint::Number.new(2**11, format, "_")

    fixt.source.should    == 2**11
    fixt.to_f.should      == 2**11-1
    fixt.to_s.should      == "2047.0"
    fixt.to_i.should      == 2**11-1
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "7ff"
    fixt.to_b.should      == "011111111111"
    fixt.overflow?.should  == true
    fixt.underflow?.should == false
  end

  it "Forced Overflow 4 fractional bits " do
    format = FixedPoint::Format.new(1, 12, 4) 
    fixt   = FixedPoint::Number.new(2**11, format, ".")

    max_fractional_value  = (1.0/2) + (1.0/4) + (1.0/8) + (1.0/16)

    fixt.source.should    == 2**11
    fixt.to_f.should      == 2**11 -1 + max_fractional_value
    fixt.to_s.should      == "2047.9375"
    fixt.to_i.should      == 2**11 -1
    fixt.frac.should      == max_fractional_value
    fixt.to_h.should      == "7fff"
    fixt.to_b.should      == "011111111111.1111"
    fixt.overflow?.should  == true
    fixt.underflow?.should == false
  end

  it "Forced Overflow  Large overflow" do
    format = FixedPoint::Format.new(1, 12, 4) 
    fixt   = FixedPoint::Number.new(2**17, format, ".")

    fixt.source.should    == 2**17

    max_fractional_value = (1.0/2) + (1.0/4) + (1.0/8) + (1.0/16)

    fixt.to_f.should      == 2**11 -1 + max_fractional_value
    fixt.to_s.should      == "2047.9375"
    fixt.to_i.should      == 2**11 -1
    fixt.frac.should      == max_fractional_value
    fixt.to_h.should      == "7fff"
    fixt.to_b.should      == "011111111111.1111"
    fixt.overflow?.should  == true
    fixt.underflow?.should == false
  end

  ##############################################
  ###   Underflow Section
  ##############################################
  #Max Negative value
  it "Forced Overflow Zero fractional bits " do
    format = FixedPoint::Format.new(1, 12, 0) 
    fixt   = FixedPoint::Number.new(-2**11, format, "_")

    fixt.source.should    == -2**11
    fixt.to_f.should      == -2**11
    fixt.to_s.should      == "-2048"
    fixt.to_i.should      == -2**11
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "800"
    fixt.to_b.should      == "100000000000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Forced Overflow Zero fractional bits " do
    format = FixedPoint::Format.new(1, 12, 0) 
    fixt   = FixedPoint::Number.new(-2**11-1, format,"_")

    fixt.source.should    == -2**11-1
    fixt.to_f.should      == -2**11
    fixt.to_s.should      == "-2048"
    fixt.to_i.should      == -2**11
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "800"
    fixt.to_b.should      == "100000000000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == true
  end

  it "Forced Overflow 4 fractional bits " do
    format = FixedPoint::Format.new(1, 12, 4) 
    fixt   = FixedPoint::Number.new(-2**11-1, format, ".")

    fixt.source.should    == -2**11-1
    fixt.to_f.should      == -2**11
    fixt.to_s.should      == "-2048"
    fixt.to_i.should      == -2**11
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "8000"
    fixt.to_b.should      == "100000000000.0000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == true
  end

  it "Forced Overflow  Large overflow" do
    format = FixedPoint::Format.new(1, 12, 4) 
    fixt   = FixedPoint::Number.new(-2**17, format, ".")


    fixt.source.should    == -2**17
    fixt.to_f.should      == -2**11
    fixt.to_s.should      == "-2048"
    fixt.to_i.should      == -2**11
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "8000"
    fixt.to_b.should      == "100000000000.0000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == true
  end


  it "Creating via binary form 011_01" do
    fixt = FixedPoint::Number.new(0)

    fixt.binary = "011_01"
    fixt.source.should    == 3.25
    fixt.to_f.should      == 3.25
    fixt.to_s.should      == "3.25"
    fixt.to_i.should      == 3
    fixt.frac.should      == 0.25
    fixt.to_h.should      == "0d"
    fixt.to_b.should      == "011_01"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Creating via binary form 0_1" do
    fixt = FixedPoint::Number.new(0)

    fixt.binary = "0_1"
    fixt.source.should    == 0.5
    fixt.to_f.should      == 0.5
    fixt.to_s.should      == "0.5"
    fixt.to_i.should      == 0
    fixt.frac.should      == 0.5
    fixt.to_h.should      == "1"
    fixt.to_b.should      == "0_1"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Creating Signed via binary form 1000_1" do
    fixt = FixedPoint::Number.new(0)

    fixt.binary = "1000_1"
    fixt.source.should    == -7.5
    fixt.to_f.should      == -7.5
    fixt.to_s.should      == "-7.5"
    fixt.to_i.should      == -7
    fixt.frac.should      == -0.5
    fixt.to_h.should      == "11"
    fixt.to_b.should      == "1000_1"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Creating Unsigned via binary form 1000_1" do
    format = FixedPoint::Format.new(0, 12, 20) 
    fixt = FixedPoint::Number.new(0,format)

    fixt.binary = "1000_1"
    fixt.source.should    == 8.5
    fixt.to_f.should      == 8.5
    fixt.to_s.should      == "8.5"
    fixt.to_i.should      == 8
    fixt.frac.should      == 0.5
    fixt.to_h.should      == "11"
    fixt.to_b.should      == "1000_1"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Creating Unsigned binary form 1000_1 using Fixdt datatype" do
    format = FixedPoint::Fixdt.new(0, 32, 20)  #Signed,width,frac_bits
    fixt   = FixedPoint::Number.new(0,format)

    fixt.binary = "1000_1"
    fixt.source.should    == 8.5
    fixt.to_f.should      == 8.5
    fixt.to_s.should      == "8.5"
    fixt.to_i.should      == 8
    fixt.frac.should      == 0.5
    fixt.to_h.should      == "11"
    fixt.to_b.should      == "1000_1"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  #need overflow test
  #need underflow test
  #Integer only binary test
end
