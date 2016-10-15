Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'honorroll'
  s.version = '0.0.1'
  s.date = '2016-10-15'

  s.description = 'A library of classic machine-learning algorithms.'
  s.summary     = s.description

  s.authors = ['Justin Molineaux']
  s.email   = ['justin.molineaux@gmail.com']

  s.licenses = ['MIT']

  s.files = Dir[
    'README.md',
    'Rakefile',
    'honorroll.gemspec',
    'lib/**/*'
  ]
  s.require_path = 'lib'

  s.add_development_dependency 'minitest', '~> 5.9'
  s.add_development_dependency 'rake', '~> 10.1'

  s.has_rdoc = false
  s.homepage = 'https://github.com/hellojustin/honorroll'
  s.rubygems_version = '2.6.7'
end
