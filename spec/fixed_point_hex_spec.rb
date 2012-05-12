require 'spec_helper'

describe FixedPoint do
  it "Create 4 bit hex 7" do
    format = FixedPoint::Fixdt.new(0, 4, 0)
    fixt = FixedPoint::Number.new(0, format)
    
    fixt.hex = "7"
    fixt.source.should    == 7.0
    fixt.to_f.should      == 7.0
    fixt.to_s.should      == "7.0"
    fixt.to_i.should      == 7
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "7"
    fixt.to_b.should      == "0111"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end
  
  it "Create 4 bit hex F" do
    format = FixedPoint::Fixdt.new(0, 4, 0)
    fixt = FixedPoint::Number.new(0, format)
    
    fixt.hex = "F"
    fixt.source.should    == 15.0
    fixt.to_f.should      == 15.0
    fixt.to_s.should      == "15.0"
    fixt.to_i.should      == 15
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "f"
    fixt.to_b.should      == "1111"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end
  
  it "Create 4 bit hex F Signed" do
    format = FixedPoint::Fixdt.new(1, 4, 0)
    fixt = FixedPoint::Number.new(0, format)
    
    fixt.hex = "F"
    fixt.source.should    == -1.0
    fixt.to_f.should      == -1.0
    fixt.to_s.should      == "-1.0"
    fixt.to_i.should      == -1
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "f"
    fixt.to_b.should      == "1111"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end
  
  it "Create 4 bit hex F Signed" do
    format = FixedPoint::Fixdt.new(1, 4, 0)
    fixt = FixedPoint::Number.new(0, format)
    
    fixt.hex = "F"
    fixt.source.should    == -1.0
    fixt.to_f.should      == -1.0
    fixt.to_s.should      == "-1.0"
    fixt.to_i.should      == -1
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "f"
    fixt.to_b.should      == "1111"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Create 8 bit Signed hex f0 [1,4,4] = -1.0" do
    format = FixedPoint::Format.new(1, 4, 4)
    fixt   = FixedPoint::Number.new(0, format)
    
    fixt.hex = "f0"
    fixt.source.should    == -1.0
    fixt.to_f.should      == -1.0
    fixt.to_s.should      == "-1.0"
    fixt.to_i.should      == -1
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "f0"
    fixt.to_b.should      == "1111.0000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "hex= should ignore masb past word length" do
    format = FixedPoint::Format.new(1, 4, 4)
    fixt   = FixedPoint::Number.new(0, format)
    
    fixt.hex = "f80"
    fixt.source.should    == -8.0
    fixt.to_f.should      == -8.0
    fixt.to_s.should      == "-8.0"
    fixt.to_i.should      == -8
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "80"
    fixt.to_b.should      == "1000.0000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Bin= check 0x removal " do
    format = FixedPoint::Format.new(1, 4, 4)
    fixt   = FixedPoint::Number.new(0, format)
    
    fixt.hex = "0xf0"
    fixt.source.should    == -1.0
    fixt.to_f.should      == -1.0
    fixt.to_s.should      == "-1.0"
    fixt.to_i.should      == -1
    fixt.frac.should      == 0.0
    fixt.to_h.should      == "f0"
    fixt.to_b.should      == "1111.0000"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end

  it "Bin= check 0x removal " do
    format = FixedPoint::Format.new(1, 4, 4)
    fixt   = FixedPoint::Number.new(0, format)
    
    fixt.hex = "0xf1"
    fixt.source.should    == -0.9375
    fixt.to_f.should      == -0.9375
    fixt.to_s.should      == "-0.9375"
    fixt.to_i.should      == 0
    fixt.frac.should      == -0.9375
    fixt.to_h.should      == "f1"
    fixt.to_b.should      == "1111.0001"
    fixt.overflow?.should  == false
    fixt.underflow?.should == false
  end
end

