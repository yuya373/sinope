require 'spec_helper'

describe Customer, 'validation' do
  let(:customer){ FactoryGirl.build(:customer) }

  specify "妥当なオブジェクト" do
    expect(customer).to be_valid
  end

  %w( family_name given_name family_name_kana given_name_kana).each do |column_name|
    specify "#{column_name} must not null" do
      customer[column_name] = ''

      expect(customer).not_to be_valid
      expect(customer.errors[column_name.to_sym]).to be_present
    end

    specify "#{column_name}は40文字以内" do
      customer[column_name] = 'け' * 41

      expect(customer).not_to be_valid
      expect( customer.errors[column_name.to_sym] ).to be_present
    end

  end

  %w( family_name given_name ).each do |column_name|
    specify "#{column_name}の種類は漢字、ひらがな、カタカナを含んでもよい" do
      customer[column_name] = '亜あアーん'

      expect(customer).to be_valid
    end

    specify "#{column_name}の種類は漢字、ひらがな、カタカナ以外の文字を含まない" do
      ['A', '@', '8'].each do |chr|
        customer[column_name] = chr

        expect(customer).not_to be_valid
        expect(customer.errors[column_name.to_sym]).to be_present
      end
    end
  end
  %w( family_name_kana given_name_kana ).each do |column_name|
    specify "#{column_name}はカタカナのみ" do
      ['A', '@', '7'].each do |chr|
        customer[column_name] = chr

        expect(customer).not_to be_valid
        expect(customer.errors[column_name.to_sym]).to be_present
      end
    end

    specify "#exchange_hiragana はひらがなをカタカナに変換する" do
      customer[column_name] = 'かなー'

      expect(customer).to be_valid
      expect(customer[column_name]).to eq('カナー')
    end
    specify "#exchange_hankaku は半角カナを全角カナに変換する" do
      customer[column_name] = 'ｶﾅｰ'

      expect(customer).to be_valid
      expect(customer[column_name]).to eq('カナー')
    end
  end

  specify "#exchange_hankaku は半角カナを全角カナに変換する" do
    customer.family_name_kana = 'ｶﾅ'
    customer.given_name_kana = 'ｶﾅ'
    expect(customer.exchange_hankaku).to eq('カナ')
    expect(customer.exchange_hankaku).to eq('カナ')
  end
end

describe Customer, 'authentication' do
  let(:customer){ create(:customer, username: 'yuya minami', password: 'correct_password') }

  specify 'return Customer object matches username and password' do
    result = Customer.authenticate(customer.username, 'correct_password')
    expect(result).to eq(customer)
  end

  specify 'return nil when invalid password' do
    invalid = Customer.authenticate(customer.username, 'invalid_password')
    expect(invalid).to be_nil
  end

  specify 'return nil when invalid username' do
    invalid = Customer.authenticate('toni blanco', 'correct_password')
    expect(invalid).to be_nil
  end

end


describe Customer, 'password_digest' do
  let(:customer){build(:customer)}
  specify 'password_digest must have 60 chr' do
    customer.password = 'hogehoge'
    customer.save!

    expect(customer.password_digest).not_to be_nil
    expect(customer.password_digest.length).to eq(60)
  end

  specify 'return nil if password is blank' do
    customer.password = ''
    customer.save!

    expect(customer.password_digest).to be_nil
  end

end
