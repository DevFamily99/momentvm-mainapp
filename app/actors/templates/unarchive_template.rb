module Templates
  # Unarhive a single template
  class UnarchiveTemplate < Actor
    input :template, allow_nil: false

    output :template

    def call
      template.update!(archived: false)
      self.template = template
    end
  end
end
