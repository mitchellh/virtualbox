$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'virtualbox/command'
require 'virtualbox/abstract_model'
require 'virtualbox/attached_device'
require 'virtualbox/hard_drive'
require 'virtualbox/nic'
require 'virtualbox/storage_controller'
require 'virtualbox/vm'