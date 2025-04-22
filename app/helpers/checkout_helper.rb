module CheckoutHelper
  def tax_rates_for(province)
    case province
    when "Ontario"
      { gst: 0.0, pst: 0.0, hst: 0.13 }
    when "British Columbia"
      { gst: 0.05, pst: 0.07, hst: 0.0 }
    when "Manitoba"
      { gst: 0.05, pst: 0.07, hst: 0.0 }
    when "Alberta"
      { gst: 0.05, pst: 0.0, hst: 0.0 }
    when "Quebec"
      { gst: 0.05, pst: 0.09975, hst: 0.0 }
    when "Nova Scotia"
      { gst: 0.0, pst: 0.0, hst: 0.15 }
    else
      { gst: 0.05, pst: 0.0, hst: 0.0 } # Default fallback
    end
  end
end
