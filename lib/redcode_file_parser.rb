module CoreWar
  class RedcodeFileParser
    
    ALLOWED_COMMANDS = %w(MOV ADD SUB MUL DIV MOD JMP JMZ JMG DJZ CMP SEQ SNE DAT SPL DJN ORG)

    attr_reader :commands
    

    def initialize(opts = {})
      @commands = []
    end

    def parse_file(file)
      File.open(file).each_line { |line| parse_line(line) }
      @commands
    end

    def parse_line(command_line)
      build_command(command_line) do |cmd| 
        @commands << cmd
        cmd
      end
    end



    private

    def build_command(command_line)
      m = command_line.match /(?<cmd_name>[a-zA-Z]{3})\s+
                              (?<operand_1>
                                (?<type_1>[#\$\@><])?
                                (?<value_1>[-+]?[0-9]+))
                              (\s*,\s*(?<operand_2>
                                (?<type_2>[\$#\@><])?
                                (?<value_2>[-+]?[0-9]+)))?
                             /xi

      raise MaliciousFile if m[:cmd_name].nil?  ||
                             m[:operand_1].nil? ||
                             !ALLOWED_COMMANDS.include?(m[:cmd_name])
      
      command = {}
      command[:index]    = @commands.length
      command[:name]     = m[:cmd_name]
      command[:operands] = []
      command[:operands] << { type: m[:type_1] || '$' , value: m[:value_1].to_i }
      command[:operands] << { type: m[:type_2] || '$' , value: m[:value_2].to_i } if m[:operand_2]

      yield command

    end

  end  
end