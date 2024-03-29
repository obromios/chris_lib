# chris_lib

This is a gem containing an eclectic library of methods. Most of the methods are for scientific computing, but there is a helper for Rspec, extensions to the Date class, and methods for building ruby bash scripts.

## Installation

Add this line to your application's Gemfile:

```
gem 'chris_lib', git: 'https://github.com/obromios/chris_lib.git'
```
or use
```
gem 'chris_lib'
```

And then execute:

    $ bundle

## Usage

The date methods are mainly to put date in some convenient formats.  For example to format a date in the Australian way, use `date.charmians_format` on a Date object.

The ```test_access``` methods can eliminate those repetitive access tests for controllers.

The maths methods include median and other statistical functions.

## Contributing
There is no need to contribute, but in case you feel you have to...

1. Fork it ( https://github.com/[my-github-username]/chris_lib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
