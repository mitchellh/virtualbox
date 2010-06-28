Given /the "(.+?)" relationship/ do |relationship|
  @relationship = @model.send(relationship)
end

Given /I reload the model/ do
  @model.reload
end

When /I read the "(.+?)"/ do |property|
  @value = @model.send(property)
end

When /I set the property "(.+?)" to "(.+?)"/ do |key, value|
  value = value == "true" if %W[true false].include?(value)
  @model.send("#{key}=", value)
end

When /I set the relationship property "(.+?)" to "(.+?)"/ do |key, value|
  old = @model
  @model = @relationship
  When %Q[I set the property "#{key}" to "#{value}"]
  @model = old
end

When /I add the new record to the relationship/ do
  @relationship << @new_record
end

When /I save the relationship/ do
  @relationship.save
end

When /I save the model/ do
  @model.save
end
