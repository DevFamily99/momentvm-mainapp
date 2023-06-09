class Array

  # Returns only PageModules which are valid for a given Date
  def valid_for(date:)
    new_self = []
    return [] unless date.class == Date
    self.each do |element|
      next unless element.class == PageModule
      body = YAML.load(element.body)
      # We only test for the case that everything is a date but doesnt compare
      if body != false
        start_date = body["start_date"]
        unless start_date.nil?
          start_date = start_date.to_date
          unless start_date.nil?
            if date < start_date
              next
            end
          end
        end
        end_date = body["end_date"]
        unless end_date.nil?
          end_date = end_date.to_date
          unless end_date.nil?
            if end_date < date
              next
            end
          end
        end
        puts "falling through as valid. '#{start_date}' '#{end_date}'"
      end
      new_self << element
      puts "element valid. #{start_date} - #{end_date}"
    end
    puts "#{new_self.count} valid elements."
    return new_self
  end
end
