FactoryBot.define do
  factory :project do
    city {'Poznan'}
    client {'Klient'}
    start_date { Date.today }
    end_date { Date.today + 1.week }
    name {'testowy projekt'}
    status {'rozpoczety'}
    street {'Street'}
    zipcode {'66-500'}
  end
end
