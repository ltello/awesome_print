# Copyright (c) 2010 Michael Dvorkin
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module AwesomePrintMongoid

  def self.included(base)
    base.send :alias_method, :printable_without_mongoid, :printable
    base.send :alias_method, :printable, :printable_with_mongoid
  end

  # Add ActiveRecord class names to the dispatcher pipeline.
  #------------------------------------------------------------------------------
  def printable_with_mongoid(object)
    
      puts "Object inside awesome: #{object.inspect}"
    printable = printable_without_mongoid(object)
        puts "printable"+printable.inspect
    if printable == :self
      if object.is_a?(ActiveRecord::Base)
        printable = :mongoid_instance
      end
    elsif printable == :class and object.ancestors.include?(ActiveRecord::Base)
      printable = :mongoid_class
    end
    printable
  end

  # Format ActiveRecord instance object.
  #------------------------------------------------------------------------------
  def awesome_mongoid_instance(object)
    data = object.class.column_names.inject(ActiveSupport::OrderedHash.new) do |hash, name|
      hash[name.to_sym] = object.send(name) if object.has_attribute?(name) || object.new_record?
      hash
    end
    "#{object} " + awesome_hash(data)
  end

  # Format ActiveRecord class object.
  #------------------------------------------------------------------------------
  def awesome_mongoid_class(object)
    if object.respond_to?(:columns)
      data = object.columns.inject(ActiveSupport::OrderedHash.new) do |hash, c|
        hash[c.name.to_sym] = c.type
        hash
      end
      "class #{object} < #{object.superclass} " << awesome_hash(data)
    else
      object.inspect
    end
  end
  
end

AwesomePrint.send(:include, AwesomePrintMongoid)
