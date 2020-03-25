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

## Security issue
You may have noticed that Github has flagged the escape_javascript unknown_input [security issue](https://github.com/obromios/chris_lib/network/alert/Gemfile.lock/actionview/open).  We have not upgraded actionview, because this repository does not use the escape_javascript unknown_input method. If you do disagree with this explanation or have identified any potential security issues with this repository, please contact us.

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
