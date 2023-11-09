FactoryBot.define do
  factory :vehicle do
    name {'Koparka'}
    status {'zajety'}
    mileage {109888}
    capacity {2001}
    reg_number {'WWA10922'}
    rev_date { Date.today + 1.year}
  end
end