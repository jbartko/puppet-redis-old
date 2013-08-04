require 'puppet-lint/tasks/puppet-lint'

# Who uses 2.6?
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

task :default => :lint
