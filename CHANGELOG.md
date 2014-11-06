# Changelog

## Version 0.0.4

* Exceptions are raised after the general `Fetch::Base` `error` callback is
  run.

## Version 0.0.3

* Adds an general `error` callback to `Fetch::Base` for catching any unhandled
  errors that might occur.

## Version 0.0.2

* Sends fetchable to fetch modules by default.
* The `init` callback only runs once.
* Adds a `defaults` callback for setting up requests.
* Adds a `parse` callback for parsing response bodies before they are processed.
* Adds a `Fetch::JSON` module for automatic JSON parsing.
* Adds a `load` callback for loading fetch modules.

## Version 0.0.1

* Initial release