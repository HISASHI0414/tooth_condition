module Patients
  class DashboardController < ApplicationController
    before_action :authenticate_patient!

    def index
      # ここで必要なデータを取得してビューに渡します
    end
  end
end
