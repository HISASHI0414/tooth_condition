class Patients::RegistrationsController < ApplicationController
  def new
    if params[:data]
      @patient_data = JSON.parse(params[:data])
      @patient = Patient.new(@patient_data)
    else
      @patient = Patient.new
    end
  end

  def create
    @patient = Patient.find(params[:patient][:id])
    if @patient.my_page
      redirect_to already_registered_path, notice: '既に登録済みの患者です。'
    else
      @patient.assign_attributes(patient_params)
      @patient.confirmation_token = SecureRandom.hex(10)
      @patient.confirmation_token_sent_at = Time.current

      if @patient.save
        PatientMailer.registration_confirmation(@patient).deliver_now
        redirect_to confirmation_sent_path, notice: '本登録用のメールが発信されましたので、そちらに記載のURLをクリックして本登録を完了して下さい。'
      else
        render :new
      end
    end
  end

  def confirmation_sent
  end

  def already_registered
  end

  def confirm
    patient = Patient.find_by(confirmation_token: params[:token])

    if patient
      Rails.logger.info "Patient found: #{patient.id}"
    else
      Rails.logger.info "Patient not found with token: #{params[:token]}"
    end

    if patient && token_still_valid?(patient.confirmation_token_sent_at)
      if patient.update_columns(my_page: true, confirmed_at: Time.current, confirmation_token: nil, confirmation_token_sent_at: nil)
        Rails.logger.info "Patient confirmed: #{patient.id}"
        redirect_to registration_success_path, notice: '本登録が完了しました。ログインしてください。'
      else
        Rails.logger.info "Patient update failed for patient: #{patient.id}. Errors: #{patient.errors.full_messages.join(', ')}"
        redirect_to unauthenticated_patient_root_path, alert: '登録の更新に失敗しました。'
      end
    else
      Rails.logger.info "Invalid or expired token for patient: #{patient&.id}"
      redirect_to unauthenticated_patient_root_path, alert: '無効なまたは期限切れのトークンです。'
    end
  end

  def registration_success
    # ここで必要なロジックを追加
  end

  private

  def patient_params
    params.require(:patient).permit(:id, :email, :password, :password_confirmation)
  end

  def token_still_valid?(confirmation_token_sent_at)
    confirmation_token_sent_at > 30.minutes.ago
  end
end
