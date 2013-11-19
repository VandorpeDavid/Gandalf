class RegistrationMailer < ActionMailer::Base

  helper ApplicationHelper

  default from: "noreply@event.fkgent.be"

  def confirm_registration(registration)
    @registration = registration
    mail to: "#{registration.name} <#{registration.email}>", subject: "Registration for #{registration.event.name}"
  end

  def ticket(registration)
    @registration = registration

    barcode = Barcodes.create('EAN13', data: registration.barcode, bar_width: 40, bar_height: 1200, caption_height: 200, caption_size: 300 )
    attachments.inline['barcode.png'] = Barcodes::Renderer::Image.new(barcode).render

    mail to: "#{registration.name} <#{registration.email}>", subject: "Ticket for #{registration.event.name}"
  end

end
