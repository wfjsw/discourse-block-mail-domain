# name: block-mail-domain
# about: Never send email to a generated email address
# version: 0.1.0
# authors: wfjsw
# url: https://github.com/wfjsw/discourse-block-mail-domain

enabled_site_setting :email_domains_delivery_disabled

module PluginBlockMailDomainEmailSenderFilter 
    def email_in_restriction_setting(setting, value)
        domains = setting.gsub('.', '\.')
        regexp = Regexp.new("@(.+\\.)?(#{domains})$", true)
        value =~ regexp
    end
    
    def send
        disabled_domains = SiteSetting.email_domains_delivery_disabled
        return skip(SkippedEmailLog.reason_types[:sender_message_to_invalid]) if email_in_restriction_setting(disabled_domains, to_address)
        super
    end
end

after_initialize do 

    Email::Sender.class_eval do
        prepend PluginBlockMailDomainEmailSenderFilter
    end

end
