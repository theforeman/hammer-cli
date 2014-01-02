Option normalizers
------------------

The goal of option normalizers is to:
 - provide description of valid option values
 - check format and preprocess values passed by users
 - offer value completion

Every normalizer must be descendant of `HammerCLI::Options::Normalizers::AbstractNormalizer`.

Example usage:
```ruby
option "--enabled", "ENABLED", "Should the host be enabled?",
  :format => HammerCLI::Options::Normalizers::Bool.new
```

#### Description of valid values
There is method `description` that should return a help string. It's value is used in output of `-h`,
which can then look for example like this:

```
--enabled ENABLED             Should the host be enabled?
                              One of true/false, yes/no, 1/0.
```

Abstract normalizer returns empty string by default.


#### Check and format passed values

Normalizer's method `format` is used for such checks. The method behaves as a filter taking
string value as it's input and returning value of any type.

If the value is not valid `ArgumentError` with an appropriate message should be risen.
Implementation in `Bool` normalizer is a good example of such functionality:

```ruby
def format(bool)
  bool = bool.to_s
  if bool.downcase.match(/^(true|t|yes|y|1)$/i)
    return true
  elsif bool.downcase.match(/^(false|f|no|n|0)$/i)
    return false
  else
    raise ArgumentError, "value must be one of true/false, yes/no, 1/0"
  end
end
```


#### Value completion

Normalizers can also provide completion of option values via method `complete`. It takes one argument - current option value at the time the completion was requested. In the simplest cases the method returns array of all possible values. More complex completions can use the current value argument for building the return values.

We distinguish two types of offered completion strings:

**Terminal completions**
- used in most cases
- the value is terminal and the completion finishes when it is selected
- terminal strings have to end with a blank space

**Partial complations**
- used to offer completion pieces, eg. directory names when completing file path
- the completion continues until a terminal string is selected
- the values have to end with any character but blank space

Completing file paths demonstrate the difference nicely:
```ruby
# "hammer some command --file /etc/f"
file_normalizer.complete("/etc/f")
[
  "/etc/foreman/", # partial completion, can continue with the directory contents
  "/etc/foo/",     # -- || --
  "/etc/foo.conf " # terminal, the completion can't continue
]
```
Example of a simple completion method for boolean values:
```ruby
def complete(value)
  ["yes ", "no "]
end
```
Example of a method completing file paths:
```ruby
def complete(value)
  Dir[value.to_s+'*'].collect do |file|
    if ::File.directory?(file)
      file+'/'
    else
      file+' '
    end
  end
end
```

See more examples in [normalizers.rb](../lib/hammer_cli/options/normalizers.rb).
