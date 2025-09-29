# parse_case_flags - Kommandozeilen-Parser

## Verwendung
```bash
parse_case_flags - A versatile bash function to parse command-line flags and options.

Usage:
  parse_case_flags [options] -i <input_parameters>

Options:
  -i, --input                     Input parameters to be parsed (required).
  -d, --dropping <var_name>       Name of the variable to drop (array).
  -D, --dedub <var_name>          Name of the variable to deduplicate (string).
  -R, --rest-params <array_name>  Name of the array to store remaining parameters (string).
  -l, --label <label>             Label for error messages (string).
  -f, --forbid <chars>            Characters to forbid in input (string).
  -a, --allow <chars>             Characters to allow in input (string).
  -o, --return <var_name>         Name of the variable to return the result (array|string).
  -F, --forbid-full <values>      Full values to forbid (multiple strings).
  -A, --allow-full <values>       Full values to allow (multiple strings).
  -m, --min-length <number>       Minimum length of each input value (number).
  -M, --max-length <number>       Maximum length of each input value (number).
  -s, --string [<separator>]      Output as a string with optional separator (default: '|').
  -v, --verbose                   Enable verbose output (boolean).
  -n, --number                    Allow numbers in input (boolean).
  -l, --letters                   Allow letters in input (boolean).
  -t, --toggle                    Toggle a boolean value (boolean).
  -r, --required                  Mark the option as required (boolean).
  -h, --help                      Display this help message and exit.

Examples:
  parse_case_flags --verbose -d "myVar" -o "resultVar" -i "-f value1 -a value2"
  parse_case_flags -D "myArray" --string "," -i "-f value1 value2 value3"

Note:
  This function requires Bash version 4.3 or higher.
```
