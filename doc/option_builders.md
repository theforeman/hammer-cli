Option builders
---------------

Option builders offer a mechanism for dynamic option creation.
This is useful in situations when there's a common pattern or options
can be created automatically based on some data.

The [builder's interface](https://github.com/theforeman/hammer-cli/blob/master/lib/hammer_cli/option_builder.rb)
is very simple. It has to define the only method `build(builder_params={})` that returns
array of `HammerCLI::Options::OptionDefinition` instances.

Example of a simple option builder follows:
```ruby
class DimensionsOptionBuilder < AbstractOptionBuilder

  def initialize(option_names)
    @option_names = option_names
  end

  def build(builder_params={})
    opts = []
    @option_names.each do |name|
      opts << option("--#{name}-height", "#{name.upcase}_HEIGHT", "Height of the #{name}")
      opts << option("--#{name}-width", "#{name.upcase}_WIDTH", "Width of the #{name}")
    end
    opts
  end

end
```

Each command class has an option builder defined in method `option_builder`.
It is executed by calling class method `build_options`.

```ruby
class HouseCommand < HammerCLI::AbstractCommand

  # define your own option builder
  def self.option_builder
    DimensionsOptionBuilder.new(["door", "window"])
  end

  # create the options at class level
  build_options
end
```

```
hammer house -h
Usage:
    hammer house [OPTIONS]

    --door-height DOOR_HEIGHT     Height of the door
    --door-width DOOR_WIDTH       Width of the door
    --window-height WINDOW_HEIGHT Height of the window
    --window-width WINDOW_WIDTH   Width of the window
    -h, --help                    print help
```

The default option builder is `OptionBuilderContainer` that
is useful for chaining multiple builders. Command's class
method `custom_option_builders` is there exactly for this reason. It's output
is passed to the container and can be used for defining custom builders.

```ruby
def self.custom_option_builders
  [
    DimensionsOptionBuilder.new(["door", "window"]),
    IdentifierOptionBuilder.new,
    SomeOtherCoolBuilder.new
  ]
end
```

If an option with the same `--flag` is already defined (either statically or from another builder)
any other option with the same flag is ignored.

