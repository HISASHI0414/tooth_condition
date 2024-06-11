class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Deviseのafter_sign_in_path_forメソッドをオーバーライド
  def after_sign_in_path_for(resource)
    if resource.is_a?(Patient)
      authenticated_patient_root_path
    elsif resource.is_a?(Clinic)
      authenticated_clinic_root_path
    elsif resource.is_a?(Admin)
      authenticated_admin_root_path
    else
      super
    end
  end
end
