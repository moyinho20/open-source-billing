class window.TaxCalculator
  #window.taxByCategory = ->
  # taxes by category
  # @example
  #   GST 9%  1,200
  #   VAT 3%    400
  #   ABC 6     800

  # itrate to line items
  @applyAllLineItemTaxes = ->
    taxes = []
    $('#invoice_grid_fields > tbody  > tr').each ->
      container = $(this)
      lineTotal = jQuery(container).find(".line_total").text()
      discountedLineTotal = jQuery(container).find(".line_total_discount").text()
      taxableTotal = lineTotal - discountedLineTotal
      tax1Select = jQuery(container).find(".tax1 option:selected")
      tax2Select = jQuery(container).find(".tax2 option:selected")

      discountedLineTotal = 0 if lineTotal == 0
      # calculate tax1
      tax1Name = tax1Select.text()
      tax1Pct = parseFloat tax1Select.attr "data-tax_1"
      tax1Amount = taxableTotal * tax1Pct / 100.0

      # calculate tax2
      tax2Name = tax2Select.text()
      tax2Pct = parseFloat tax2Select.attr "data-tax_2"
      tax2Amount = taxableTotal * tax2Pct / 100.0

      taxes.push {name: tax1Name, pct: tax1Pct, amount: tax1Amount} if tax1Select.text() != "" #if tax1Name && tax1Pct && tax1Amount
      taxes.push {name: tax2Name, pct: tax2Pct, amount: tax2Amount} if tax2Select.text() != "" #if tax2Name && tax2Pct && tax2Amount

    tlist = {}

    for t in taxes
      #tlist["#{t['name']} #{t['pct']}%"] = (tlist[t["#{t['name']} #{t['pct']}%"]] || 0) + t["amount"] if !isNaN(t["amount"])
      tax_key = t['name'] + " " + t['pct'] + "%"
      tlist[tax_key] = (tlist[tax_key] || 0) + t["amount"] if !isNaN(t["amount"])
      a = (a || 0) + t["amount"] if !isNaN(t["amount"])

    lis_lab = "" # list items
    lis_tax = "" # list items
    for tax, amount of tlist
      lis_lab += $("<span><li><span>#{tax}</span></li></span>").html()
      tax_val = $("<span>#{amount}</span>").formatCurrency({symbol: window.currency_symbol}).html()
      lis_tax += $("<span><li><span>" + tax_val + "</span></li></span>").html()

    jQuery(".invoice-total-left .new-invoice-footer-row.taxes_total").html("<ul>#{lis_lab}</ul>")
    jQuery(".invoice-total-right .new-invoice-footer-row.taxes_total").html("<ul>#{lis_tax}</ul>")

  exports.applyAllLineItemTaxes = @applyAllLineItemTaxes;

  applySingleLineItemTax = ->
