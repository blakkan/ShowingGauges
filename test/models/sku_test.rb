require 'test_helper'

class SkuTest < ActiveSupport::TestCase
  #Test user creation
  test 'create sku' do

    current_count = Sku.count()
    Sku.create!(name: "Zippy", user_id: 1)
    assert Sku.count() == current_count + 1
    Sku.find_by!(name: "Zippy").destroy!
    assert Sku.count() == current_count

  end

  test 'find Sku fixtures' do

    s = Sku.find_by(name: "80-000000")
    assert s.id == 1
    assert s.name == "80-000000"
    assert s.comment == "comment for sku 80-000000"
    assert s.minimum_stocking_level == 0
    assert s.user_id == 1
    refute s.is_retired
    assert s.bu == "11"
    assert s.description == "Final Assy"
    assert s.category == "Cat1"
    assert s.cost == 12.34



    s2 = Sku.find_by(name: "53-000001")
    assert s2.id == 2
    assert s2.name == "53-000001"
    assert s2.comment == "comment for sku 53-000001"
    assert s2.minimum_stocking_level == 24
    refute s2.is_retired
    assert s2.user_id == 1
    assert s2.bu == "22"
    assert s2.description == "Sub Assy"
    assert s2.category == "Cat2"
    assert s2.cost == 56.78

  end

  test "the scope from the model concerns" do

    assert Sku.all_active.pluck(:name).sort == ["53-000001", "80-000000" ]
    Sku.find_by(name: "53-000001").update_attributes!(is_retired: true)
    assert Sku.all_active.pluck(:name).sort == [ "80-000000" ]
    Sku.find_by(name: "53-000001").update_attributes!(is_retired: false)
    assert Sku.all_active.pluck(:name).sort == ["53-000001", "80-000000" ]

  end
end
