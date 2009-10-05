# We're monkey-patching ActiveRecord to work around a bug in Rails:
# https://rails.lighthouseapp.com/projects/8994/tickets/3169
#
# I know that this makes me a bad person. Don't you judge me!
module ActiveRecord
  module AttributeMethods
    def define_attribute_methods
      return if generated_methods?
      columns_hash.each do |name, column|
        if self.serialized_attributes[name]
          define_read_method_for_serialized_attribute(name)
        else
          unless instance_method_already_implemented?(name)
            if create_time_zone_conversion_attribute?(name, column)
              define_read_method_for_time_zone_conversion(name)
            else
              define_read_method(name.to_sym, name, column)
            end
          end
        end

        unless instance_method_already_implemented?("#{name}=")
          if create_time_zone_conversion_attribute?(name, column)
            define_write_method_for_time_zone_conversion(name)
          else  
            define_write_method(name.to_sym)
          end
        end

        unless instance_method_already_implemented?("#{name}?")
          define_question_method(name)
        end
      end
    end
  end
end

