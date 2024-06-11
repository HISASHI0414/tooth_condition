# == Schema Information
#
# Table name: patients
#
#  id                         :bigint           not null, primary key
#  birth_date                 :date             not null
#  confirmation_token         :string
#  confirmation_token_sent_at :string
#  confirmed_at               :datetime
#  email                      :string           default("")
#  encrypted_password         :string           default("")
#  first_name                 :string           not null
#  first_name_kana            :string           not null
#  gender                     :string           not null
#  last_name                  :string           not null
#  last_name_kana             :string           not null
#  medical_record_no          :integer          not null
#  my_page                    :boolean          default(FALSE)
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  clinic_id                  :bigint           not null
#
# Indexes
#
#  index_patients_on_clinic_id                        (clinic_id)
#  index_patients_on_confirmation_token               (confirmation_token) UNIQUE
#  index_patients_on_email                            (email) UNIQUE WHERE ((email)::text <> ''::text)
#  index_patients_on_medical_record_no_and_clinic_id  (medical_record_no,clinic_id) UNIQUE
#  index_patients_on_reset_password_token             (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (clinic_id => clinics.id)
#
class Patient < ApplicationRecord
  belongs_to :clinic

  before_create :generate_confirmation_token

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :medical_record_no, presence: true, uniqueness: { scope: :clinic_id }
  validates :last_name, :first_name, :last_name_kana, :first_name_kana, :birth_date, :gender, presence: true

  # メールアドレスとパスワードのバリデーションを無効化
  # validates :email, presence: true, if: -> { email.present? }
  # validates :email, uniqueness: true, allow_blank: true
  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  def qr_code
    RQRCode::QRCode.new(Rails.application.routes.url_helpers.new_patient_registration_path(data: self.to_qr_code_data)).as_svg(module_size: 5)
  end

  def to_qr_code_data
    {
      id: id,
      clinic_id: clinic_id,
      medical_record_no: medical_record_no,
      last_name: last_name,
      first_name: first_name,
      last_name_kana: last_name_kana,
      first_name_kana: first_name_kana,
      birth_date: birth_date,
      gender: gender,
      email: email
    }.to_json
  end

  def qr_code_url
    Rails.application.routes.url_helpers.new_patient_registration_path(data: self.to_qr_code_data)
  end

  validate :unique_email_if_present

  private

  def unique_email_if_present
    if email.present?
      errors.add(:email, 'has already been taken') if Patient.where.not(id: id).exists?(email: email)
    end
  end

  def password_required?
    !new_record? || !password.blank?
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(10)
    self.confirmation_token_sent_at = Time.current
  end
end
