class InvoiceDocument < Prawn::Document
  attr_accessor :invoice

  def initialize(invoice, args = {})
    super(args)
    @invoice = invoice
    document
  end

  def document
    header
    add_line_separator
    order_info
    customer_info
    move_down(20)
    order_details
    move_down(20)
    add_dotted_line_separator
    price_details
    move_down(10)
    footer
  end

  def header
    company_logo
    company_info
  end

  def order_info
    bounding_box([25, bounds.height - 120], width: (bounds.width - 150)) do
      text "GST INVOICE", size: 20, style: :bold, color: '09B8E2'
      text "Invoice Date: #{invoice.created_at.strftime('%d-%m-%Y')}", size: 10
      text "Due Date: #{invoice.due_date}", size: 10
      text "INVOICE #: #{invoice.invoice_number}", size: 10
      text "Invoice Type: #{invoice.invoice_type}", size: 10
      text "Billing Month: #{invoice.billing_month}", size: 10
    end
  end

  def customer_info
    bounding_box([350, bounds.height - 130], width: (bounds.width - 150)) do
      text "#{client.organization_name}", size: 10, style: :bold
      text "#{client.full_name}"
      if client.present?
        text "#{client.address_street1}", size: 10
        text "#{[client.address_street2, client.city, "#{client.state} #{client.zipcode}", client.country].reject(&:blank?).join(', ')}", size: 10
        text "Tel: #{[client.mobile_number, client.business_phone].reject(&:blank?).join(', ')}", size: 10
        text "#{client.vat_number.split('|')[0]}", size: 10
        text "#{client.vat_number.split('|')[1]}", size: 10
      end
    end
  end

  def order_details
    table(table_headers + table_content, width: 590) do
      cells.borders = []
      row(0).font_style = :bold
      row(0).background_color = 'F0F0F0'
      row(0).borders = [:bottom]
      column(0..14).style(align: :center, size: 8)
      column(1).style(size: 9)
    end
    table_content
  end

  def table_headers
    [["S No", "Product", "Pack", "Qty", "Batch", "Expiry", "HSN", "MRP", "Rate", "Discount", "CGST %", "SGST %", "Amount", "Net Amount"]]
  end

  def table_content
    rows = []
    invoice.invoice_line_items.each_with_index do |item, index|
      row = [index + 1, item.item_name || item.item.item_name, item.pack,
        item.item.quantity.to_f, item.batch, item.expiry, item.hsn, number_to_currency(item.mrp, unit: invoice.currency.code),
        number_to_currency(item.rate, unit: invoice.currency.code), number_to_currency(item.discount.round(2), unit: invoice.currency.code),
        item_cgst(item), item_sgst(item), number_to_currency(item.amount, unit: invoice.currency.code),
        number_to_currency(item.net_amount, unit: invoice.currency.code)]
      rows<< row
    end
    rows
  end

  def price_details
    data = []
    data.push(["Sub Total: ", "#{number_to_currency(invoice.sub_total.round(2), unit: invoice.currency.code)}"])
    invoice.tax_detail_with_discount.each do |tax, amount|
      data.push(["#{tax}: ", "#{number_to_currency(amount.round(2), unit: invoice.currency.code)}"])
    end
    data.push(["Total: ", "#{number_to_currency(@invoice.invoice_total.round(2), unit: @invoice.currency.code )}"])
    data.push(["Amount Paid: ", "#{number_to_currency(Payment.invoice_paid_amount(@invoice.id).round(2), unit:  @invoice.currency.code )}"])
    data.push(["Balance Due: ", "#{number_to_currency(invoice.invoice_total.round(2) - Payment.invoice_paid_amount(invoice.id).round(2), unit: invoice.currency.code)}"])

    table(data, position: 465) do
      cells.borders = []
      cells.style(padding: 5)
      cells.style(size: 10)
      cells.borders = [:bottom]
      cells.border_colors = 'F0F0F0'
      column(0).style(align: :right)
      column(1).style(align: :right)
    end
  end

  def footer
    terms_and_conditions
    move_down(10)
    signature
  end

  def terms_and_conditions
    text "Terms and conditions:", size: 9
    text "1. Price charged are those prevailing as on date and are subject to revision.", size: 9
    text "2. Payment by cheque is subject to realisation.", size: 9
    text "3. Goods once sold will not be taken back or exchanged.", size: 9
    text "4. Overdue Interest @24% will be charged from the due date.", size: 9
    text "5. All disputes subject to Varanasi jurisdiction only." , size: 9
  end

  def signature
    text "For and on behalf of #{company.company_name} ", size: 10, align: :right
  end

  def add_line_separator
    move_down(5)
    stroke_horizontal_rule
    move_down(5)
  end

  def add_dotted_line_separator
    move_down(5)
    stroke do
      stroke_color '000000'
      dash(4, space: 2, phase: 0)
      line_width 1
      horizontal_line(0, 590)
    end
    undash
    move_down(5)
  end

  def number_to_currency(amount, code)
    # ActionController::Base.helpers.number_to_currency(amount, code)
    amount.round(2).to_s
  end

  def item_cgst(item)
    if invoice.has_tax_one?
      "#{Tax.with_deleted.find(item.tax_1).percentage}%" if item.tax_1.present?
    end
  end

  def item_sgst(item)
    if invoice.has_tax_two?
      "#{Tax.with_deleted.find(item.tax_2).percentage}%" if item.tax_2.present?
    end
  end

  def company_logo
    image "#{Rails.root}/app/assets/images/shri-logo.png", at: [25, bounds.height - 30], width: 250, height: 60
  end

  def company_info
    bounding_box([350, bounds.height - 30], width: (bounds.width - 275)) do
      text "#{company.company_name}", size: 10, style: :bold
      text "#{company.street_address_1}, #{company.street_address_2}", size: 10
      text "#{[ company.city, "#{company.state} #{company.zipcode}", company.country].reject(&:blank?).compact.join(', ')}", size: 10
      text "Tel: #{company.phone_number}", size: 10
      text "#{company.default_note.split('|')[0]}", size: 10
      text "#{company.default_note.split('|')[1]}", size: 10
    end
  end

  def company
    invoice.company
  end

  def client
    invoice.client
  end

end
