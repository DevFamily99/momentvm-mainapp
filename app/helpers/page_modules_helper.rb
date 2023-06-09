module PageModulesHelper
  def generate_random_strings(number_of_occurances)
    output_strings = []
    number_of_occurances.to_i.times { output_strings << (0...6).map { ('a'..'z').to_a[rand(26)] }.join }
    output_strings.sort
  end

  def update_page_module_ranks(list)
    if list
      ranks = generate_random_strings(list.length)
      list.each_with_index do |page_module_id, index|
        page_module = PageModule.find(page_module_id)
        page_module.rank = ranks[index]
        page_module.save
      end
    end
  end

end
