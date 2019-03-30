# FindMyMac

FindMyMac, and its helper class, Scraper, reaches out to Apple's refurbished computer site to compile a searchable list of available computers.  Scraper initiates the process by scraping the Apple site and returning a hash array of computers.  FindMyMac then loads up the corresponding @iMac, @iMacPro, @MacBookAir, etc., objects, queries the user about which configuration the user would like to search, and returns a list of available computers matching that configuration.  The user may then select from the list to see additional information, including a link directly back to the details page for the selected computer.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'findMyMac'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install findMyMac

## Usage

There are two ways to use this gem:

1.  Invoke
        hash = Scraper::scrape_refurbished_mac : to manually receive the hash array of all computers available. T FindMyMac::Finder(hash) :  passing in the hash returned from Scraper.
2.  Invoke finder = FindMyMac::Finder.new  : with no arguments

Once finder has been instantiated, the entry point to running the search is:

     finder.findMacs

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marysue/findMyMac. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the (http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FindMyMac project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/marysue/findMyMac/blob/master/CODE_OF_CONDUCT.md).
