# Clib

This is a gem containing a library of methods and classes for the personal use of Chris. It is primarily to allow Chris to share this code across different apps. As such is it not meant to be used by other people. Sorry...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clib', git: 'https://github.com/obromios/clib.git'
```

And then execute:

    $ bundle


## Usage

To format a date in the Australian way, use `date.charmians_format` on any Date object.
```
  class Date
       charmians_format
  end
```

## Contributing
There is no need to contribute, but in case you feel you have to...

1. Fork it ( https://github.com/[my-github-username]/clib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
