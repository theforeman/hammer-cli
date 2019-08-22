# Modify an existing help

### Help items
Before modifying help, it's good to know which help items are available to use.
There is a list with currently available items:
```ruby
Command.extend_help do |h|
  # Add a simple text to the help output.
  # content - String - text to be shown
  # options - Hash   - options (id:, richtext:)
  h.text(content, options = {})
  # Add a notification to the help output (LABEL: content).
  # content - String - text to be shown
  # options - Hash   - options (same as #text, label:)
  h.note(content, options = {})
  # Add a list of items to the help output.
  # items   - Array - array of items to be shown. Each item can be either string
  #                   or an array of ['Key', 'Value', bold: true/false].
  #                   Item options are optional.
  #   Example: h.list(['a', 'b', 'c']) => "a\n b\n c\n"
  #            h.list([['a', 'b', bold: true], ['c', 'd']]) => "a   b\nc   d\n"
  # options - Hash  - same as #text
  h.list(items, options = {})
  # Add a section to the help output.
  # label   - String - Section header
  # options - Hash   - same as #text
  # block   - block with section definition (may include lists/texts/etc.)
  h.section(label, options = {}) { |h| ... }
end
```
Every `Section`, `List` and simple `Text` is _help item_ defined as `HammerCLI::Help::AbstractItem`, so everything might have its own ID now for easier addressing.

### Help modification

Each command might have its own help definition. This definition is composed of various [_help items_](#Help-items), which might contain their own definitions.

Let's say `hammer host create -h` help string has the following structure:
```
hammer host create -h
+-- Usage
+-- Options
+-- Additional info
|   +-- Section(Available keys for --interface:)
|   |  +-- List
|   |  +-- Section
|   |  |  +-- List
|   |  +-- Section
|   |  |  +-- List
|   |  +-- Section
|   |  |  +-- List
|   +-- Section(Provider specific options:)
|   |  +-- Section
|   |  |  +-- Section
|   |  |  |  +-- List
...
|   |  +-- Section(Libvirt:)
|   |  |  +-- Section(--compute-attributes:)
|   |  |  |  +-- List[
                   cpus                Number of CPUs
                   memory              String, amount of memory, value in bytes
                   start               Boolean (expressed as 0 or 1), whether to start the machine or not
                 ]
...
|   |  |  +-- Section
|   |  |  |  +-- List
```

To modify the structure above, you might use the following:
```ruby
HammerCLIForeman::Host::CreateCommand.extend_help do |h|
  # Simple addition to the end.
  h.section
  h.list
  h.text

  # Inserts one or more help items.
  # Where:
  #   :mode is one of [:before, :after, :replace]
  #   :item_id is item's id or label. Item's label can be used if it does not
  # have an id, e.g. any Section
  #   block is block of code with new items
  h.insert(:mode, :item_id) do |h|
    h.section
    h.list
    h.text
  end
  # Addition to custom path.
  # Where:
  #   path is Array of :item_id or/and 'item_label'
  #   block is the code block with new help items.
  h.at(path) do |h|
    ...
    h.section
    h.list
    h.text
    ...
  end
  # Returns help item from current definition.
  h.find_item(:item_id)
end
```

#### Examples
```ruby
# Add a new section with list to the end of the Libvirt section.
HammerCLIForeman::Host::CreateCommand.extend_help do |h|
  h.at(['Provider specific options', 'Libvirt']) do |h|
    h.section('--new-section-with-list', id: :section_with_list) do |h|
      h.list([
        ['item1', _('Desc1')],
        ['item2'],
        ['item3', _('Desc3')]
      ], id: :list_with_id)
    end
  end
end

# Add important information
HammerCLIForeman::Host::CreateCommand.extend_help do |h|
  h.at(['Provider specific options']) do |h|
    h.insert(:before, 'EC2') do |h|
      h.text('Something important for all providers')
    end
    h.at(['EC2']) do |h|
      h.insert(:before, '--compute-attributes') do |h|
        h.text('Something important for EC2 only')
      end
    end
  end
end

# Delete the Libvirt section from Provider specific options section.
HammerCLIForeman::Host::CreateCommand.extend_help do |h|
  h.at('Provider specific options') do |h|
    h.insert(:replace, 'Libvirt') do |h|; end
  end
end

# Add more text
HammerCLIForeman::Host::CreateCommand.extend_help do |h|
  h.at('Provider specific options') do |h|
    h.insert(:before, 'EC2') do |h|
      h.text('Imagine it already was here', id: :old_text_id)
    end
  end
  h.at(['Provider specific options', :old_text_id]) do |h|
    h.text('Additional information', id: :additional_text)
  end
end
```
