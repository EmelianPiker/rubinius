require File.expand_path("../spec_helper", __FILE__)

describe "Instruction restore_exception_state" do
  before do
    @spec = InstructionSpec.new :restore_exception_state do |g|
      g.push_nil
      g.ret
    end
  end

  it "<describe instruction effect>" do
    @spec.run.should be_nil
  end
end
