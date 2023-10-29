require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  scenario 'User visits the home page' do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Welcome to My App')
  end
end
