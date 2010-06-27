Given /the "(.+?)" relationship/ do |relationship|
  @relationship = @model.send(relationship)
end

When /I read the "(.+?)"/ do |property|
  @value = @model.send(property)
end

When /I save the relationship/ do
  @relationship.save
end

When /I save the object/ do
  @model.save
end
