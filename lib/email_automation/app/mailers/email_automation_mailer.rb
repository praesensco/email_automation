require 'mandrill'

class EmailAutomationMailer < ActionMailer::Base
  def automation_email(params)
    from = EmailAutomation.configuration.from_name +
           '<' + EmailAutomation.configuration.from_email + '>',
    reply_to = EmailAutomation.configuration.from_email

    prepare(params)
  end

  private

  def prepare(params = {})
    template = mandrill_template(params[:template], params[:data])
    mail_params = {
      to: params[:to],
      subject: template[:subject],
      body: template[:body],
      content_type: "text/html"
    }
    unless params[:bcc].blank?
      mail_params[:bcc] = params[:bcc]
    end
    mail(mail_params)
  end

  def mandrill_template(template_name, attributes)
    mandrill = Mandrill::API.new(Rails.application.secrets.mail_smtp_password)
    merge_vars = attributes.map do |key, value|
      { name: key, content: value }
    end
    {
      subject: mandrill.templates.info(template_name)["subject"],
      body: mandrill.templates.render(template_name, [], merge_vars)["html"]
    }
  end
end
