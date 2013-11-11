#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

# require 'logger'
# class ::Logger; alias_method :write, :<<; end
# 
# if ENV['RACK_ENV'] == 'production'
#   logger = ::Logger.new("log/production.log")
#   logger.level = ::Logger::DEBUG
#   use Rack::CommonLogger, logger
# end

run Padrino.application
