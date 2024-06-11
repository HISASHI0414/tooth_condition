# frozen_string_literal: true

class DeviseCreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      ## Database authenticatable
      t.references :clinic, null: false, foreign_key: true

      t.integer :medical_record_no, null: false
      t.string :last_name,          null: false
      t.string :first_name,         null: false
      t.string :last_name_kana,     null: false
      t.string :first_name_kana,    null: false
      t.date :birth_date,           null: false
      t.string :gender,             null: false
      t.boolean :my_page,                         default: false
      t.string :email,                            default: ""
      t.string :encrypted_password,                default: ""
      t.string :confirmation_token
      t.string :confirmation_token_sent_at
      t.datetime :confirmed_at

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

    add_index :patients, [:medical_record_no, :clinic_id], unique: true
    add_index :patients, :reset_password_token, unique: true
    add_index :patients, :confirmation_token, unique: true

    # 既存のemailカラムに対するユニークインデックスが存在する場合、それを削除します。
    # これにより、新しい部分インデックスを追加する前に競合を回避できます。
    remove_index :patients, :email if index_exists?(:patients, :email)

    # emailカラムに対して新しいユニークインデックスを追加します。
    # ただし、このインデックスはemailカラムが空でない場合にのみ適用されます。
    # 空のemail値を許容しつつ、非空のemail値に対してユニーク制約を維持します。
    add_index :patients, :email,                unique: true, where: "email <> ''"

    # add_index :patients, :unlock_token,         unique: true
  end
end
