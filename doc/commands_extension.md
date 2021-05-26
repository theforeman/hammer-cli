Extend an existing command
-------------------------

Each command can be easily extended with one ore more `HammerCLI::CommandExtensions`:
- Define the extension
  ```ruby
  class Extensions < HammerCLI::CommandExtensions
    # Tells if those extensions are inherited by subcommands (false by default)
    # Can be changed for specific object, e.g. MyExtensions.new(inheritable: false)
    inheritable true
    # Simply add a new option to a command is being extended
    option(option_params)
    # Add option family to a command
    option_family(common_options = {}) do
      parent option_params
      child option_params
    end
    # Extend hash with data returned from server before it is printed
    before_print do |data, command_object, command_class|
      # data modifications
    end
    # Extend command's output definition
    output do |definition, command_object, command_class|
      # output definition modifications
    end
    # Extend command's help definition
    help do |h|
      # help modifications
    end
    # Extend hash with headers before request is sent
    request_headers do |headers, command_object, command_class|
      # headers modifications
    end
    # Extend hash with options before request is sent
    request_options do |options, command_object, command_class|
      # options modifications
    end
    # Extend hash with params before request is sent
    request_params do |params, command_object, command_class|
      # params modifications
    end
    # Extend option sources
    option_sources do |sources, command_object, command_class|
      # no need to call super method
      # simply add your sources to sources variable
    end
  end
  ```
- Extend the command
  ```ruby
  MyCommand.extend_with(Extensions.new)
  # Also it is possible to specify exact extensions you want to apply
  # This can be useful when you want to use several extensions
  MyCommand.extend_with(
    # Apply only the output extensions from Extensions
    Extensions.new(only: :output),
    # Apply all except output and help extensions from OtherExtensions
    OtherExtensions.new(except: [:output, :help])
  )
  ```

__NOTE:__
  - `request_*` extensions are applied before sending a request to the server
  - `option`, `output`, `help` extensions are applied right away after the command is extended with `extend_with`
  - `before_print` extensions are applied right away after the server returns the data
  - `request_*`, `output`, `before_print` extensions have access to the command object
    after the command with the extension was initialized

#### Example
```ruby
class MyCommandExtensions < HammerCLI::CommandExtensions

  option ['--new-option'], 'TYPE', _('Option description')

  option_family(
    description: _('Common description')
  ) do
    parent ['--new-option'], 'TYPE', _('Option description')
    child ['--new-option-ver2'], 'TYPE', _('Option description')
  end

  before_print do |data|
    data['results'].each do |result|
      result['status'] = process_errors(result['errors'])
    end
  end
  # To use your custom helpers define them as class methods
  def self.process_errors(errors)
    errors.empty? ? 'ok' : 'fail'
  end

  output do |definition|
    definition.append do
      field nil, 'Statuses', Fields::Label do
        from 'results' do
          field 'status', _('Status')
        end
      end
    end
  end

  help do |h|
    h.text('Something useful')
  end

  request_headers do |headers|
    headers[:ssl] = true
  end

  request_options do |options|
    options[:with_authentication] = true
  end

  request_params do |params|
    params[:thin] = false
  end

  option_sources do |sources, command|
    sources.find_by_name('IdResolution').insert_relative(
      :after,
      'IdParams',
      HammerCLIForeman::OptionSources::PuppetEnvironmentParams.new(command)
    )
    sources
  end
end

MyCommand.extend_with(MyCommandExtensions.new)
```
