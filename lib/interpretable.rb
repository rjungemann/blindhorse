module Interpretable
  def permit_interpretables m
    unless (@command_modules ||= []).include? m
      @command_modules << m
      
      class_eval { include m }
    end
  end
  
  def interpret data, can_eval = true
    lex(data.strip).each do |command|
      if can_eval && command.first[0].chr == "`"
        begin
          instance_eval command.first[1..-2]
        rescue
        end
      else
        method, args = command.first, command[1..-1]
        
        self.send(method, *args) if (@command_modules ||= []).find do |m|
          m.public_method_defined? method
        end
      end
    end
    nil
  end
  
  def lex data
    delims = ["'", '"', "`"]

    data.split(";").collect do |str|
      command, i = [], 0

      while i < str.size
        if delims.include? str[i]
          j = i

          until j > i && str[j] == str[i]
            j += 1

            quotable = str[i] == '"' ? "'\"'" : "\"#{str[i]}\""
            
            raise %{No matching #{quotable} found.} if j >= str.size
          end

          command << (str[i] == "`" ? str[i..j] : str[(i + 1)..(j - 1)]).strip

          i = j + 1
        elsif str[i] != " "
          j = i
            
          j += 1 while j < str.size &&
            !(delims.include? str[j]) && !(str[j] == " ")

          command << str[i..(j - 1)].strip

          i = j + 1
        else str[i] == " "; i += 1 end
      end

      command
    end
  end
end