# frozen_string_literal: true

# Pagy initializer file (7.0.6)
# Customize only what you really need and notice that the core Pagy works also without any of the following lines.
# Should you just cherry pick part of this file, please maintain the require-order of the extras

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables
Pagy::DEFAULT[:page]   = 1                            # default
Pagy::DEFAULT[:items]  = 20                           # default
Pagy::DEFAULT[:outset] = 0                            # default

# Other Variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#other-variables
Pagy::DEFAULT[:size]         = [1, 4, 4, 1] # default in pagy < 7.0
Pagy::DEFAULT[:page_param]   = :page # default
# Pagy::DEFAULT[:count_args]   = []                     # example for non AR ORMs
# Pagy::DEFAULT[:params]       = {}                     # default
# NOTICE: The :params can be also set as a lambda e.g:
# ->(params){ params.exclude('useless').merge!('custom' => 'useful') }

# Extras
# See https://ddnexus.github.io/pagy/categories/extra

# When you are done setting your own default freeze it, so it will not get changed accidentally
Pagy::DEFAULT.freeze
