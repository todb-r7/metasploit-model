shared_examples_for 'Metasploit::Model::Module::Instance is not stanced with module_type' do |context_module_type|
  context "with #{context_module_type.inspect}" do
    # define as a let so that lets from outer context can access option to set detail.
    let(:module_type) do
      context_module_type
    end

    it "should have #{context_module_type.inspect} for module_class.module_type" do
      module_instance.module_class.module_type.should == module_type
    end

    it { should_not be_stanced }

    context 'with nil stance' do
      let(:stance) do
        nil
      end

      it { should be_valid }
    end
  end
end