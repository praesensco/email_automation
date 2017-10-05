require 'mandrill'

class EmailAutomationMailer < ActionMailer::Base
  def automation_email(params)
    prepare(params)
  end

  private

  def prepare(params = {})
    template = mandrill_template(params[:template], params[:data])
    mail_params = {
      body: template[:body],
      content_type: "text/html",
      from: EmailAutomation.configuration.from_name +
            '<' + EmailAutomation.configuration.from_email + '>',
      reply_to: EmailAutomation.configuration.from_email,
      subject: template[:subject],
      to: params[:to]
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

    subject = mandrill.templates.info(template_name)["subject"]
    attributes.each do |key, value|
      subject.gsub! "*|#{key}|*", value
    end

    {
      subject: subject,
      body: mandrill.templates.render(template_name, [], merge_vars)["html"]
    }
  end
end
