require "uri"
require "net/http"
require "json"

module LiveEditorHelper

  # Find rank in between two given strings
  def find_in_between(lower, upper)
    lower = lower.numberize
    upper = upper.numberize
    middle = []
    same_chars_so_far = true
    upper.each_with_index do |char, index|
      if lower[index].nil?
        if same_chars_so_far
          middle << 122 # Append and add "z" if all the characters are the same
        end
        break
      end
      if upper[index] == lower[index]
        middle << char
      else
        same_chars_so_far = false
        puts "#{upper[index]} - #{lower[index]}"
        middle << (upper[index] - lower[index]) / 2 + lower[index]
      end
    end
    return middle.pack('c*')
  end

  def page_title
    true
  end


  # query: Array [key1, key2]
  # partial_hash: Hash, to be modified
  def deep_replace(query, partial_hash, value_to_set)
    if query.first =~ /^[0-9]+$/ && query.first !=~ /[a-zA-Z]+/
      # query is an array index like [foo][0]
      position = query.first.to_i
      #p ">> is int: #{query.first.to_i}::#{partial_hash[position]}"

      query.shift # next level deeper in query
      # Now go one deeper
      puts "go deeper"
      deep_replace(query, partial_hash[position], value_to_set)
      return
    end
    # Deep enough
    if query.class == Array && query.length == 1
      puts "deep enough"
      partial_hash[query.first] = value_to_set
      return
    else
      puts "else"
      key = query.first
      query.shift
      # bugfix
      if partial_hash[key] == ""
        partial_hash[key] = value_to_set
        puts "return 1"
        return
      end
      puts "deep lowest"
      deep_replace(query, partial_hash[key], value_to_set)
    end
  end

  # query: Array [key1, key2]
  def deep_set(query, value_to_set)
    full_hash = {}
    current_item = full_hash
    parent = full_hash
    query.each_with_index do |item, index|
      if query.length >= index + 1
        if query[index + 1] =~ /[0-9]+/ # array
          next_item = {}
          current_item[item] = [next_item]
          foo = {}
          current_item = next_item
          next
        end
      end
      if item.class == String && item =~ /[a-zA-Z]+/
        foo = {}
        parent = current_item[item]
        if index == query.length - 1
          current_item[item] = value_to_set
          return full_hash
        else
          current_item[item] = foo
          current_item = current_item[item]
          next
        end
      end
    end
  end

  
end
