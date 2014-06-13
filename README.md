# Akashi

Wrapping aws-sdk

## Installation

Add this line to your application's Gemfile:

    gem 'akashi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install akashi

## Usage

``` ruby
require "yaml"
require "akashi"

Akashi::Aws.config = YAML.load_file("aws.yml"))

Akashi.application = application
Akashi.environment = environment
Akashi.manifest    = YAML.load_file("#{Akashi.name(separator: "_")}.yml")

Akashi.send(action.intern)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
