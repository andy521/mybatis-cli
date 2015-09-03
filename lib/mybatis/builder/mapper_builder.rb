require "fileutils"
require_relative "../util/string_ext"

module Mybatis
  module MapperBuilder
    public
    def build_mapper_xml(workspace)
      raise ArgumentError, "No such dicrecoty - #{workspace}" unless File.directory? workspace

      #实体类存放目录
      mapper_path = get_entity_path workspace

      FileUtils.makedirs mapper_path unless File.directory? mapper_path

      #实体类对应文件
      file = File.new "#{mapper_path}#{self.name}Mapper.xml" ,"w"
      file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
      file.puts "<!DOCTYPE mapper PUBLIC \"-//mybatis.org//DTD Mapper 3.0//EN\""
      file.puts "		\"http://mybatis.org/dtd/mybatis-3-mapper.dtd\">"
      file.puts
      file.puts "<mapper namespace=\"#{self.get_class_path}Mapper\">"
      file.puts "   <insert id=\"insert\" parameterType=\"#{self.get_class_path}\">"
      file.puts "     insert into #{self.get_table_name} ("
      file.puts "       #{self.get_all_column}"
      file.puts '     )'
      file.puts '     values('
      self.attributes.each_with_index do |attr,index|
        result = self.get_mapper_column attr.name
        if index != self.attributes.size - 1
          result << ','
        end
        file.puts "       #{result}"
      end
      file.puts '     )'
      file.puts '   </insert>'
      file.puts
      file.puts '   <delete id="delete">'
      file.puts "     delete from #{self.get_table_name} where id = \#{id}"
      file.puts '   </delete>'
      file.puts
      file.puts "   <update id=\"update\" parameterType=\"#{self.get_class_path}\">"
      file.puts "     update #{self.get_table_name}"
      file.puts '     set'
      self.attributes.each_with_index do |attr,index|
        result = self.get_mapper_column attr.name
        if index != self.attributes.size - 1
          result << ','
        end
        file.puts "       #{attr.db_field_name} = #{result}"
      end
      file.puts "     where id = \#{id}"
      file.puts '   </update>'
      file.puts
      file.puts "   <select id=\"select\" resultType=\"#{self.get_class_path}\">"
      file.puts "     select * from #{self.get_table_name} where id = \#{id}"
      file.puts '   </select>'
      file.puts '</mapper>'
      file.close
    end

    # def build_mapper(workspace)
    #   raise ArgumentError, "No such dicrecoty - #{workspace}" unless File.directory? workspace
    #
    #   #实体类存放目录
    #   entity_path = get_entity_path workspace
    #   FileUtils.makedirs entity_path unless File.directory? entity_path
    #   #实体类对应文件
    #   file = File.new "#{entity_path}#{self.name}.java" ,"w"
    #   file.puts "package #{self.package};" if self.package
    #   file.puts
    #   file.puts "/**"
    #   file.puts " * Created by mybatis-cli"
    #   file.puts " */"
    #   file.puts "public class #{self.name} {"
    #
    #   self.attributes.each_with_index do |attr|
    #     file.puts "    private String #{attr.name};"
    #     file.puts
    #   end
    #
    #   self.attributes.each_with_index do |attr|
    #     file.puts "    public String get#{attr.name.upcase_first}() {"
    #     file.puts "        return this.#{attr.name.upcase_first};"
    #     file.puts "    }"
    #     file.puts
    #   end
    #   self.attributes.each_with_index do |attr|
    #     file.puts "    public void set#{attr.name.upcase_first}(String #{attr.name}) {"
    #     file.puts "        this.#{attr.name.upcase_first} = #{attr.name};"
    #     file.puts "    }"
    #     file.puts
    #   end
    #   file.puts "}"
    #   file.close
    # end

    def get_mapper_path(workspace)
      mapper_path = workspace
      mapper_path << '/' unless mapper_path.end_with? '/'
      mapper_path << self.package.gsub(/\./,'/') if self.package
      mapper_path << '/' unless mapper_path.end_with? '/'
    end

    def get_class_path
      return "#{self.package}.#{self.name}" if self.package
      "#{self.name}"
    end

    def get_table_name
      "t_#{self.name.downcase_first.replace_upcase_to_underline}"
    end

    def get_all_column
      result = ''
      self.attributes.each_with_index do |attr|
        result << ',' unless result.end_with? ','
        result << attr.db_field_name
      end
      result[1,result.size]
    end

    def get_mapper_column(field_name)
      result = "\#{"
      result << "#{field_name}"
      result << '}'
    end

    def get_update_values_column
      result = ''
      self.attributes.each_with_index do |attr|
        result << ',\n' if result.end_with? ',\n'
        result << "#{attr.name} = " << '#{' << attr.name + '}'
      end
      result
    end
  end
end