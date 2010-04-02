require 'digest/sha2'
require 'uuid'

class Object
  def blank?
    self.nil? || (self.respond_to?(:empty?) && self.empty?)
  end
end

class Object
  def metaclass; (class << self; self; end) end
  def meta_eval *args, &block; metaclass.instance_eval *args, &block end
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
