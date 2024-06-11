class PatientMailer < ApplicationMailer
  default from: '0414.hisashi.f@example.com'

  def registration_confirmation(patient)
    @patient = patient
    @confirmation_url = confirm_patient_registration_url(token: @patient.confirmation_token)
    mail(to: @patient.email, subject: '本登録の確認')
  end
end
