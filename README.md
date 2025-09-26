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

### Documentation

YARD annotations are included throughout the gem. Generate HTML docs with:

```bash
bundle exec yard doc
open doc/index.html
```

For a live server:

```bash
bundle exec yard server --reload --server webrick
```

Then browse to http://localhost:8808.

## Usage

### Core extensions

- `DateExt` extends `Date` with helpers such as `#charmians_format` for Australian-style formatting and `#us_format_with_weekday` for full weekday strings.
- `TestAccess` ships an RSpec macro (`it_should_route_to`) that keeps controller access tests terse.
- `ChrisMath` enriches Ruby core classes (`Array`, `Float`, `Matrix`, `Quaternion`, etc.) with linear algebra and statistics helpers.

### ForChrisLib additions

`ForChrisLib` bundles the analytical helpers that previously lived in a different project. Include it whenever you need the extras:

```ruby
require 'chris_lib'
include ForChrisLib

pdf_from_hist([3, 5, 2], min: -1)
# => {-1=>0.3, 0=>0.5, 1=>0.2}
```

Highlights include:

- `ChiSquaredStdErr` for quick goodness-of-fit tests from means and standard errors.
- Histogram tooling (`pdf_from_hist`, `summed_bins_histogram`, `bin_shift`) for exploratory analysis.
- Weighted statistics (`weighted_mean`, `weighted_sd`, `weighted_skewness`).
- Numerical integration helpers (`simpson`, `cdf_calc`) and inverse-transform sampling utilities.

Some helpers depend on optional gems:

- `minimization` is used by `bias_estimate_by_min` unless you inject a custom minimiser.

Ruby 3.4 treats many standard libraries (`base64`, `bigdecimal`, `logger`, `mutex_m`, `ostruct`, `date`) as default gems. If you see warnings about them not being loaded, add the corresponding gems to your Gemfile or run `gem pristine <name>` inside your Ruby 3.4.2 gemset.

## Acknowledgments
The chris_lib gem is supported by [The Golf Mentor](https://www.thegolfmentor.com).

## Contributing
There is no need to contribute, but in case you feel you have to...

1. Fork it ( https://github.com/[my-github-username]/chris_lib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
