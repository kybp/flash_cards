# -*- coding: utf-8 -*-
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'

class SupportTestCase < ActiveSupport::TestCase
  attr_accessor :print_name
end

class ControllerTestCase < ActionController::TestCase
  attr_accessor :print_name
end

class SpecReporter < Minitest::Reporters::SpecReporter
  def record_print_status(test)
    if test.print_name
      test_name = test.print_name
    else
      with_spaces = test.name.sub(/^test_/, '').gsub('_', ' ')
      test_name   = with_spaces.sub(/^./) { |c| c.upcase }
    end

    if test.passed?
      print(green { pad_mark("✓") })
      puts " #{test_name}"
    elsif test.skipped?
      puts(yellow { "#{pad_mark('-')} #{test_name}" })
    else
      puts(red { "#{pad_mark('✗')} #{test_name}" })
    end
  end

  def record_print_failures_if_any(test)
    if !test.skipped? and test.failure
      message = "Assertion error: #{test.failure.message}"
      print_with_info_padding("\e#{red}#{message}\e[0m")
    end
  end
end

class ActiveSupport::TestCase
  fixtures :all
  Minitest::Reporters.use! [SpecReporter.new]
end
