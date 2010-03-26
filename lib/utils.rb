class Object
  def blank?
    self.nil? || (self.respond_to?(:empty?) && self.empty?)
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
      when :up; offset.z -= 1
      when :down; offset.z += 1
      when :north; offset.y -= 1
      when :south; offset.y += 1
      when :west; offset.x -= 1
      when :east; offset.x += 1
    end 
    offset
  end
end

module Interpretable
  def permit_interpretables m
    unless (@command_modules ||= []).include? m
      @command_modules << m
      
      self.class.instance_eval { include m }
    end
  end
  
  def interpret data
    data.strip.split(".").each do |raw_command|
      if raw_command[0].chr == "`"
        instance_eval raw_command[1..-2]
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