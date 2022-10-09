class LineItemDiscount < ApplicationRecord
  belongs_to :line_item
  enum discount_type: [:percentage, :free_item, :amount]
end
