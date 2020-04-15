# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/samesystem'
require_relative 'rubocop/samesystem/version'
require_relative 'rubocop/samesystem/inject'

RuboCop::Samesystem::Inject.defaults!

require_relative 'rubocop/cop/samesystem_cops'
