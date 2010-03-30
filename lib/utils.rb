require 'digest/sha2'
require 'uuid'

class Object
  def blank?
    self.nil? || (self.respond_to?(:empty?) && self.empty?)
  end
end

class Generate
  @@uuid = UUID.new
  
  def self.salt
    [Array.new(6) { rand(256).chr }.join].pack('m').chomp
  end
  
  def self.hash password, salt
    Digest::SHA256.hexdigest password + salt
  end
  
  def self.uuid
    @@uuid.generate
  end
end

class Array
  def sum array; a = self.dup; a.sum! array; a end
  def sum! array; 0.upto(size - 1) { |i| self[i] += array[i] }; self end
  
  %w[x y z].each_with_index do |n, i|
    class_eval "def #{n}; self[#{i}] end; def #{n}= n; self[#{i}] = n end"
  end
end

class Direction
  def self.offset d
    direction, offset = d.to_sym, [0, 0, 0]
    case direction
      when :up, :u; offset.z -= 1
      when :down, :d; offset.z += 1
      when :north, :n; offset.y -= 1
      when :south, :s; offset.y += 1
      when :west, :w; offset.x -= 1
      when :east, :e; offset.x += 1
    end 
    offset
  end
end

module Interpretable
  def permit_interpretables m
    unless (@command_modules ||= []).include? m
      @command_modules << m
      
      class_eval { include m }
    end
  end
  
  def interpret data, can_eval = true
    data.strip.split(".").each do |raw_command|
      if can_eval && raw_command[0].chr == "`"
        begin
          instance_eval raw_command[1..-2]
        rescue
        end
      else
        command = raw_command.strip.split
        method, args = command.first, command[1..-1]

        self.send(method, *args) if @command_modules.find do |m|
          m.public_method_defined? method
        end
      end
    end
    nil
  end
end
