class window.InvoiceCalculator
  # Calculate the line total for invoice
  @updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = jQuery(container).find("input.cost").val()
    qty = jQuery(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    discount =  jQuery(container).find(".line_item_discount").val()
    special_discount = elem.parents("tr").find("select.special_discount option:selected").attr('data-line_item_special_discount')
    special_discount = 0 if not special_discount? or special_discount is "" or not jQuery.isNumeric(special_discount)
    discount = 0 if not discount? or discount is "" or not jQuery.isNumeric(discount)
    line_total = ((parseFloat(cost) * parseFloat(qty)))
    special_discount_amount = special_discount * line_total/100
    discount_amount = (line_total - special_discount_amount) * discount/100.0    
    taxable_total = line_total - special_discount_amount - discount_amount
    tax_total = applyTax(taxable_total, container)
    grand_total = taxable_total + tax_total
    jQuery(container).find(".line_net_total").text(grand_total.toFixed(2))
    jQuery(container).find(".line_total").text(line_total.toFixed(2))
    # total_discount_amount = $('#invoice_discount_amount').val
    # total_discount_amount = 0 if not total_discount_amount? or total_discount_amount is "" or not jQuery.isNumeric(total_discount_amount)
    # total_discount_amount = total_discount_amount + special_discount_amount + discount_amount
    jQuery(container).find(".line_total_discount").text((special_discount_amount + discount_amount).toFixed(2))

  # Calculate grand total from line totals
  @updateInvoiceTotal = ->
    total = 0
    net_total = 0
    tax_amount = 0
    discount_amount = 0
    invoice_tax_amount = 0.0
    $('#invoice_grid_fields > tbody  > tr').each ->
      container = $(this)
      line_total = jQuery(container).find(".line_total").text()
      line_net_total = jQuery(container).find(".line_net_total").text()
      line_discount = jQuery(container).find(".line_total_discount").text()
      total += parseFloat(line_total)
      net_total += parseFloat(line_net_total)
      discount_amount += parseFloat(line_discount)
      tax_amount += applyTax((line_total - line_discount), container)

    $('#invoice_sub_total_lbl').text (total - discount_amount)
    $('#invoice_sub_total').val (total - discount_amount)

    $('#invoice_invoice_total').val net_total
    $('#invoice_total_lbl').text net_total
    $('.invoice_total_strong').html net_total

    $('#invoice_discount_amount').val (discount_amount * -1).toFixed(2)
    $('#invoice_discount_amount_lbl').text discount_amount.toFixed(2)

    $('#tax_amount_lbl').text tax_amount.toFixed(2)
    $('#invoice_tax_amount').val tax_amount.toFixed(2)
    total_balance = parseFloat(total - discount_amount)
    
    $("#invoice_invoice_tax_amount").val tax_amount
    total_balance += parseFloat(tax_amount)
    $('#invoice_invoice_total').val net_total.toFixed(2)
    $('#invoice_total_lbl').text net_total.toFixed(2)
    $('.invoice_total_strong').html net_total.toFixed(2)
    $('#invoice_total_tax').val tax_amount.toFixed(2)
    $('#invoice_total_tax').html tax_amount.toFixed(2)
    $("#invoice_sub_total_lbl, #invoice_total_lbl, .tax_amount, #invoice_total_tax").formatCurrency({symbol: window.currency_symbol})
    $('.invoice_total_strong').formatCurrency({symbol: window.currency_symbol})

    conversion_rate = $('#invoice_conversion_rate').val()
    invoice_base_currency_equivalent_total = (total_balance / conversion_rate).toFixed(2)
    $('.invoice_total_base_currency').html invoice_base_currency_equivalent_total
    $('#invoice_base_currency_equivalent_total').val(invoice_base_currency_equivalent_total)
    $('.invoice_total_base_currency').formatCurrency({symbol: $('#invoice_base_currency_id').children('option:selected').attr('symbol')})

    TaxCalculator.applyAllLineItemTaxes()

  getInvoiceTax = (total) ->
    tax_percentage = parseFloat($("#invoice_tax_id option:selected").data('tax_percentage'))
    total * (parseFloat(tax_percentage) / 100.0)

  # Apply Tax on totals
  applyTax = (line_total,container) ->
    tax1 = container.find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = container.find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    # if line total is 0
    tax1=tax2=0 if line_total is 0
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    (line_total) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (container) ->
    cost = jQuery(container).find(".line_total_discount").val()
    
