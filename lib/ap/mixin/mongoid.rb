# Copyright (c) 2010 Michael Dvorkin
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module AwesomePrintMongoid

  def self.included(base)
    puts "#{base} available"
    
    base.send :alias_method, :printable_without_mongoid, :printable
    base.send :alias_method, :printable, :printable_with_mongoid
  end

  # Add Mongoid to the dispatcher pipeline.
  #------------------------------------------------------------------------------
  def printable_with_mongoid(object)
    
    printable = printable_without_mongoid(object)
    if printable == :self
      if object.respond_to?(:fields)
        printable = :mongoid_instance
      end
    elsif printable == :class and !object.respond_to?(:to_model)
      printable = :mongoid_class
    end
    printable
  end

  # Format Mongoid instance object.
  #------------------------------------------------------------------------------
  def awesome_mongoid_instance(object)
    keys = (object.fields.keys + object.attributes.keys).uniq
      data = keys.inject(ActiveSupport::OrderedHash.new) do |hash, name|
        hash[name.to_sym] = object.send(name) if object.respond_to?(name)
        hash
      end
    "#{object} " + awesome_hash(data)
  end

  # Format Mongoid class object.
  #------------------------------------------------------------------------------
  def awesome_mongoid_class(object)
    if object.respond_to?(:fields)
      keys = (object.fields.keys + object.associations.keys).uniq
      data = keys.inject(ActiveSupport::OrderedHash.new) do |hash, c|
        hash[c.to_sym] = object.fields.keys.include?(c) ? object.fields[c].options.to_s : object.associations[c].options.to_s
        hash
      end
      "class #{object} < #{object.superclass} " << awesome_hash(data)
    else
      object.inspect
    end
  end
  
end

AwesomePrint.send(:include, AwesomePrintMongoid)