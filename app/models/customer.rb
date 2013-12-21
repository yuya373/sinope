#姓（family_name）、名（given_name）、姓フリガナ（family_name_kana）、名フリガナ（given_name_kana）が必須入力項目。
#それぞれ40文字以内。
#姓と名で許される文字の種類は、漢字、ひらがな、カタカナ。
#姓フリガナと名フリガナはカタカナのみ。ただし、ひらがなでの入力も受け付けて、カタカナに自動変換する。
#いわゆる半角カナは全角カナに自動変換する。



class Customer < ActiveRecord::Base
  require 'nkf'
  require 'bcrypt'

  attr_accessor :password
  before_validation :exchange_hiragana, :exchange_hankaku
  before_save :nil_blank_password, :password_to_password_digest

  validates :family_name, :given_name, :family_name_kana, :given_name_kana, presence: true, length: {maximum: 40}

  validates :family_name, :given_name, format: { with: /\A[\p{Han}\p{Hiragana}\p{Katakana}\u30fc]+\z/, allow_blank: true }

  validates :family_name_kana, :given_name_kana, format: { with: /\A[\p{Katakana}\u30fc]+\z/, allow_blank: true}



  class << self
    def authenticate(username, password)
      customer = Customer.find_by(username: username)

      if customer && BCrypt::Password.new(customer.password_digest) == password
        customer
      else
        nil
      end
    end
  end

  def exchange_hiragana
    self.family_name_kana = NKF.nkf('-w -h2', family_name_kana)
    self.given_name_kana = NKF.nkf('-w -h2', given_name_kana)
  end

  def exchange_hankaku
    self.family_name_kana = NKF.nkf('-w -X', family_name_kana)
    self.given_name_kana = NKF.nkf('-w -X', given_name_kana)
  end

  def password_to_password_digest
    self.password_digest = BCrypt::Password.create(password) if password.present?
  end

  def nil_blank_password
    self.password = nil if password.blank?
  end

end
