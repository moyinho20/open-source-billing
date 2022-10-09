#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
class InvoiceLineItem < ApplicationRecord

  include ItemSearch
  # associations
  belongs_to :invoice
  belongs_to :estimate
  belongs_to :item
  belongs_to :tax1, :foreign_key => 'tax_1', :class_name => 'Tax'
  belongs_to :tax2, :foreign_key => 'tax_2', :class_name => 'Tax'
  has_many :line_item_discounts
  # archive and delete
  acts_as_archival
  acts_as_paranoid

  # after_create :handle_discounts

  attr_accessor :tax_one, :tax_two

  after_destroy :recalculate_invoice_total

  attr_accessor :tax_one, :tax_two

  def recalculate_invoice_total
    self.invoice.save if self.invoice.present?
  end

  def unscoped_item
    Item.unscoped.find_by_id self.item_id
  end

  def formatted_invoice_item
    param_values = {
      'item_name' => (self.item_name),
      'item_description' => (self.item_description)
    }
    Settings.invoice_item_format.gsub(/\{\{(.*?)\}\}/) {|m| param_values[$1] }
  end

  def handle_discounts
    unless self.actual_price.to_f == self.rate.to_f || self.line_item_discounts.present?
      if actual_price.to_i == 0
        self.line_item_discounts.create(discount_type: 1, amount: 100)
      else
        self.line_item_discounts.create(discount_type: 0, amount: (100*actual_price/rate.to_f))
      end
    end
  end

  def special_discount_amount
    amount * line_item_discounts.select{|discount| discount.discount_type == "free_item"}.map{|d| d.amount}.sum/100
  end

  def discount_amount
    amount * line_item_discounts.select{|discount| discount.discount_type != "free_item"}.map{|d| d.amount}.sum/100
  end

  def special_discount
    line_item_discounts.select{|discount| discount.discount_type == "free_item"}.map{|d| d.amount}.sum
  end

  def discount
    line_item_discounts.select{|discount| discount.discount_type != "free_item"}.map{|d| d.amount}.sum
  end

  def net_amount
    amount  - special_discount_amount - discount_amount
  end

  def applyDiscount(line_items_total_with_taxes)
    discount_amount
  end

  def amount
    rate.to_f * item_quantity.to_f
  end

  def item_total_discount
    line_item_discounts.sum(&:amount)
  end

  def item_tax_amount
    tax_amount = 0
    return 0 if tax1.blank? and tax2.blank?
    tax_amount +=  (net_amount * tax1.percentage)/100 if tax1.present?
    tax_amount +=  (net_amount * tax2.percentage)/100 if tax2.present?
    tax_amount
  end

  def total_amount
    item_tax_amount + net_amount
  end

end