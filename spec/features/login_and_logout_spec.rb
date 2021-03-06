require 'spec_helper'

describe 'login' do
  before{ create(:customer, username: 'yuyaminami', password: 'correct_pasword') }

  specify 'success authentication' do
    visit root_path
    within('form.new_session') do
      fill_in 'username', with: 'yuyaminami'
      fill_in 'password', with: 'correct_pasword'
      click_button 'login'
    end
    expect(page).not_to have_css('form.new_session')
  end

  specify 'failed authentication' do
    visit root_path
    within('form.new_session') do
      fill_in 'username', with: 'taro'
      fill_in 'password', with: 'wrong_password'
      click_button 'login'
    end
    expect(page).to have_css('p.alert', text: 'invalid username and password')
    expect(page).to have_css('form.new_session')
  end
end
