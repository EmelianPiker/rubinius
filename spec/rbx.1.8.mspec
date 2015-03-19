# vim: filetype=ruby

class MSpecScript
  # Language features specs
  set :language, [
    'spec/ruby/language',
    'spec/language'
  ]

  # Core library specs
  set :core, [
    'spec/ruby/core',
    'spec/core',

    # 1.9
    '^core/basicobject'
  ]

  # Standard library specs
  set :library, [
    'spec/library',
  ]

  set :capi, [
    '^spec/ruby/optional/capi/encoding',
  ]

  # JIT specs
  set :jit, [
    'spec/jit',
  ]

  # An ordered list of the directories containing specs to run
  set :files, get(:language) + get(:core) + get(:library) + get(:jit) +
              get(:capi) + get(:compiler) + get(:build) + get(:command_line)

  set :ruby, [
    'spec/ruby',
  ]

  # An ordered list of the directories containing specs to run
  # as the CI process.
  set :ci_files, [
    'spec/ruby/core',
    'spec/ruby/language',
    'spec/ruby/command_line',
    'spec/core',
    'spec/jit',
    'spec/language',
    'spec/command_line',
    'spec/ruby/optional/capi',
    'spec/library',

    'spec/build',

    # 1.9 features
    '^spec/ruby/core/basicobject',
    '^spec/ruby/optional/capi/encoding',
  ]

  set :travis, get(:ci_files)

  # The set of substitutions to transform a spec filename
  # into a tag filename.
  set :tags_patterns, [
                        [%r(spec/), 'spec/tags/'],
                        [/_spec.rb$/, '_tags.txt']
                      ]

  # Enable language features
  if Rubinius::Config["hash.hamt"]
    MSpec.enable_feature :hash_hamt
  else
    MSpec.enable_feature :hash_bucket
  end

  # The Readline specs are not enabled by default because the functionality
  # depends heavily on the underlying library, including whether certain
  # methods are implemented or not. This makes it extremely difficult to
  # make the specs consistently pass. Until a suitable scheme to handle
  # all these issues, the specs will not be enabled by default.
  #
  # MSpec.enable_feature :readline
end