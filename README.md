# RSpec-CTRF

RSpec formatter to output test results in CTRF (https://www.ctrf.io/) JSON format.

## Usage

Add to Gemfile:

```ruby
gem "rspec-ctrf"
```

Add formatter to either `.rspec` or CLI:

```
rspec --format Ctrf::RSpecFormatter --out <path>.ctrf.json
```
