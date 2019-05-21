Modify an existing command
-------------------------

### Modification of output fields

Each command (as well as each field) might have its own
output definition. You can modify the output definition of existing
command or a specific field of that command by following output
definition interface:

```ruby
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
  # Appends fields to the end.
  # Where:
  #   fields is one or more existing fields
  #   block is block of code with new fields
  definition.append(fields) do
    label
    field
    collection
  end
  # Inserts one or more fields.
  # Where:
  #   :mode is one of [:before, :after, :replace]
  #   :id is field's id or key. Field's label can be used if field does not
  # have id
  #   fields is one or more existing fields
  #   block is block of code with new fields
  definition.insert(:mode, :id, fields) do
    label
    field
    collection
  end
  # Returns output definition of the command or field specified with path.
  # Where:
  #   path is an Array of field's :key or/and :id or/and 'label'
  definition.at(path)
  # Returns field from current output definition.
  definition.find_field(:id)
  # Finds and adds fields to a set (creates a new one if the set doesn't exist).
  # Where:
  #   sets is an Array of String with set names
  #   fields is an Array of field's :key or/and :id or/and 'label'
  definition.update_field_sets(sets, fields)
  # Deletes all fields from current output definition.
  definition.clear
end
```
#### Examples
```ruby
# Append some fields to the end
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                     definition.at(_('Collection Field Label'))
                                               .append do
                                                 field :value3, _('Value 3')
                                               end
                                    end
# Change field's label
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                      definition.at(:path)
                                      .find_field(:id).label = _('New label')
                                    end
# Update fields in a field set
# Adds fields with :field_id and 'My field' to 'SET' set
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                      definition.at(:path)
                                      .update_field_sets('SET', [:field_id, 'My field'])
                                    end
# Expand a field with new definition
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                      definition.at([_('some'), :path])
                                      .insert(:replace, :not_container_field_id) do
                                        field nil, _('Label with new fields'), Fields::Label, id: :now_container_field_id do
                                        field :new_field1, _('New field 1')
                                        field :new_field2, _('New field 2')
                                        end
                                      end
                                    end
# Insert a new field after specific field
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                     definition.at([_('some'), :path])
                                     .insert(:after, :other_field_id, [Fields::Field.new(label: _('My field'), id: :my_field_id)])
                                    end
# Insert a new field before specific field
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                      definition.insert(:before, :other_field_id,
                                        Fields::Field.new(label: _('My field'), id: :my_field_id))
                                    end
# Remove field
HammerCLIForeman::Host::InfoCommand.extend_output_definition do |definition|
                                      definition.insert(:replace, :field_id) do; end
                                    end
```
