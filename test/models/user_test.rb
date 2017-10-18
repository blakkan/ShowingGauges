require 'test_helper'

class UserTest < ActiveSupport::TestCase

  #Test user creation
  test 'create user' do

    current_count = User.count()
    User.create!(name: "Zippy")
    assert User.count() == current_count + 1
    User.find_by!(name: "Zippy").destroy!
    assert User.count() == current_count

  end

  test 'find users fixtures' do

    u = User.find_by(name: "TechA")
    assert u.id == 1
    assert u.name == "TechA"
    assert u.comment == "comment for user 1"
    assert u.encrypted_password.nil?
    refute u.is_retired
    assert u.capabilities == "admin"

    u2 = User.find_by(name: "TechB")
    assert u2.id == 2
    assert u2.name == "TechB"
    assert u2.comment == "comment for user 2"
    refute u2.encrypted_password.nil?
    refute u2.is_retired
    assert u2.capabilities == ""
  end

  test "the scope from the model concerns" do

    assert User.all_active.pluck(:name).sort == ["TechA", "TechB" ]
    User.find_by(name: "TechA").update_attributes!(is_retired: true)
    assert User.all_active.pluck(:name).sort == [ "TechB" ]
    User.find_by(name: "TechA").update_attributes!(is_retired: false)
    assert User.all_active.pluck(:name).sort == ["TechA", "TechB" ]
  end


end
