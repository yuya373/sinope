FactoryGirl.define do
  factory :customer do
    username 'yuyaminami'
    password 'correct_password'
    family_name '南'
    given_name "優也"
    family_name_kana 'ミナミ'
    given_name_kana 'ユウヤ'
  end
end
