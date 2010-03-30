$:.unshift(File.dirname(__FILE__) + '/../vendor/redis-rb/lib')

require 'active_support'
require 'json'
require 'redis'

require "#{File.dirname(__FILE__)}/utils"
require "#{File.dirname(__FILE__)}/models"
require "#{File.dirname(__FILE__)}/interpretable"
require "#{File.dirname(__FILE__)}/commands"
require "#{File.dirname(__FILE__)}/server"

include Blindhorse
