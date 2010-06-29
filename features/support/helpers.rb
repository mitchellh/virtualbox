module VirtualBox
  module IntegrationHelpers
    # Tests that given a mappings hash (see `VM_MAPPINGS` in env.rb),
    # a model, and an output hash (string to string), that all the
    # mappings from model match output.
    def test_mappings(mappings, model, output)
      mappings.each do |model_key, output_key|
        value = model.send(model_key)

        if [TrueClass, FalseClass].include?(value.class)
          # Convert true/false to VirtualBox-style string boolean values
          value = value ? "on" : "off"
        end

        output_value = output[output_key.to_sym] || output[output_key]
        value, output_value = yield value, output_value if block_given?
        value.to_s.should == output_value
      end
    end
  end
end

World(VirtualBox::IntegrationHelpers)
