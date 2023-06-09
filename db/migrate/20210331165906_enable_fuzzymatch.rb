class EnableFuzzymatch < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    enable_extension 'fuzzystrmatch'
  end
end
