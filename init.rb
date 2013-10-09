# This file is required only if installed as plugin such like in
# vendor/plugins/scope_fridge/. In case installed as gem
# package, lib/scope_fridge.rb will work instead.

$LOAD_PATH << File.dirname(__FILE__) + '/lib'

require 'scope_fridge'
ActiveRecord::Base.send(:include, ScopeFridge)
