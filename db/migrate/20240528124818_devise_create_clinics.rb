# frozen_string_literal: true

class DeviseCreateClinics < ActiveRecord::Migration[7.1]
  def change
    create_table :clinics do |t|
      ## Database authenticatable
      t.string :clinic_name,        null: false
      t.string :clinic_tel_no
      t.string :clinic_url
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    # 既存のインデックスを削除
    remove_index :patients, :email if index_exists?(:patients, :email)

    # 新しい部分インデックスを追加
    add_index :patients, :email, unique: true, where: "email <> ''"

    add_index :clinics, :reset_password_token, unique: true
    # add_index :clinics, :confirmation_token,   unique: true
    # add_index :clinics, :unlock_token,         unique: true
  end
end
