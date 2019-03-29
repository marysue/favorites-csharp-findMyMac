
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "findMyMac/version"

Gem::Specification.new do |spec|
  spec.name          = "findMyMac"
  spec.version       = FindMyMac::VERSION
  spec.authors       = ["Mary Lark"]
  spec.email         = ["mary@marylark.com"]
  spec.date          = '2019-03-28'

  spec.summary       = %q{A command line tool that reaches out to apple's refurbished site, and creates a searchable list of refurbished computers currently available.}
  spec.description   = %q{A command line tool that reaches out to apple's refurbished computer site.  Using the Scraper singleton class, FindMyMac reaches out to apple's refurbished computers site and returns all of the current inventory.  FindMyMac dynamically creates desktop and laptop objects representing each computer available.  Using the findMacs method, FindMyMac queries the user for the current available configurations and presents a list of computers that match this configuration.  Currently only display sizes, cpu's and number of cores are specified.  A list is presented of all matching computers currently available.  From that list the user can reach the details page for the selected computer and retrieve more information, like type and size of hard drive, gpu information, and when the computer was originally released.}
  spec.files = ["lib/Macs/desktop.rb", "lib/Macs/laptop.rb", "lib/Macs/unknown.rb", "lib/findMyMac.rb", "lib/concerns.rb", "lib/command_line_interface.rb", "lib/mac.rb", "lib/scraper.rb"]
  spec.homepage      = "https://github.com/marysue/findMyMac."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  #  spec.metadata["homepage_uri"] = spec.homepage
  #  spec.metadata["source_code_uri"] = "https://github.com/marysue/findMyMac"
  #  spec.metadata["changelog_uri"] = "https://github.com/marysue/findMyMac/commits/master"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  #end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
