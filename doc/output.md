Output
------------------------------

### Adapters
Output adapter is responsible for rendering the output in a specific way using
__formatters__ (see below).
Hammer comes with following adapters:
  * __base__   - simple output, structured records
  * __table__  - records printed in tables, ideal for printing lists of records
  * __csv__    - comma separated output, ideal for scripting and grepping
  * __yaml__   - YAML output
  * __json__   - JSON output
  * __silent__ - no output, used for testing

### Formatters
Formatter is a bit of code that can modify a representation of a field during
output rendering. Formatter is registered for specific field type. Each field
type can have multiple formatters.
  * __ColorFormatter__    - colors data with a specific color
  * __DateFormatter__     - formats a date string with `%Y/%m/%d %H:%M:%S` style
  * __ListFormatter__     - formats an array of data with csv style
  * __KeyValueFormatter__ - formats a hash with `key => value` style
  * __BooleanFormatter__  - converts `1/0`/`true/false`/`""` to `"yes"`/`"no"`
  * __LongTextFormatter__ - adds a new line at the start of the data string
  * __InlineTextFormatter__    - removes all new lines from data string
  * __MultilineTextFormatter__ - splits a long data string to fixed size chunks
  with indentation

### Formatter/Adapter features
Currently used formatter (or adapter) features are of two kinds.
The first one help us to align by structure of the output:
  * __:serialized__ - means the fields are serialized into a string (__table__, __csv__, __base__ adapters)
  * __:structured__ - means the output is structured  (__yaml__, __json__ adapters)
  * __:inline__     - means that the value will be rendered into single line without newlines (__table__, __csv__ adapters)
  * __:multiline__  - means that the properly indented value will be printed over multiple lines (__base__ adapter)

The other kind serves to distinguish the cases where we can use the xterm colors
to improve the output:
  * __:rich_text__  - means we can use the xterm colors (__table__, __base__ adapters)
  * __:plain_text__ - unused yet

All the features the formatter has need to match (be present in) the adapter's
features. Otherwise the formatter won't apply.
