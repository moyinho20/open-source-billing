module OSB
  module CONFIG
    wicked_pdf_path = `which wkhtmltopdf`.gsub(/\n/, "")
    require 'yaml'
    require 'erb'
    APP_CONFIG = HashWithIndifferentAccess.new(YAML.load(ERB.new(File.read(Rails.root.join('config','config.yml'))).result)[Rails.env])
    APP_HOST ||= APP_CONFIG[:app_host]
    TLD_LENGTH ||= APP_CONFIG[:tld_length]
    APP_PROTOCOL ||= APP_CONFIG[:app_protocol]
    ACTIVEMERCHANT_BILLING_MODE ||= APP_CONFIG[:activemerchant_billing_mode]
    PAYPAL ||= APP_CONFIG[:paypal]
    WKHTMTTOPDF_PATH ||= wicked_pdf_path
    SMTP_SETTING ||= APP_CONFIG[:smtp_setting]
    QUICKBOOKS ||= APP_CONFIG[:quickbooks]
    ENCRYPTION_KEY ||= APP_CONFIG[:encryption_key]
    DEMO_MODE ||= APP_CONFIG[:demo_mode]
  end
end
