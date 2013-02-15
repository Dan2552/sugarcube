describe "SugarCube::AnimationChain" do
  tests SugarCube::AnimationChainController

  it "should have a view" do
    controller.view.should != nil
  end

  it "should support chains" do
    SugarCube::AnimationChain.chains.length.should == 0
    @variable_a = nil
    @variable_b = nil
    UIView.animation_chain(duration:0.1){
      @variable_a = 'a'
    }.and_then(duration: 0.1){
      @variable_b = 'b'
    }.start
    SugarCube::AnimationChain.chains.length.should == 1

    wait 0.3 {
      @variable_a.should == 'a'
      @variable_b.should == 'b'
      SugarCube::AnimationChain.chains.length.should == 0
    }
  end

  it "should support multiple chains" do
    SugarCube::AnimationChain.chains.length.should == 0
    @variable_a = nil
    @variable_b = nil
    UIView.animation_chain(duration:0.1, delay:0.1){
      @variable_a = 'a'
    }.start
    UIView.animation_chain(duration:0.1, delay:0.1){
      @variable_b = 'b'
    }.start
    SugarCube::AnimationChain.chains.length.should == 2

    wait 0.3 {
      @variable_a.should == 'a'
      @variable_b.should == 'b'
      SugarCube::AnimationChain.chains.length.should == 0
    }
  end

end
