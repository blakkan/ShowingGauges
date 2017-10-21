require 'test_helper'

class LocationTest < ActiveSupport::TestCase

    #Test user creation
    test 'create Location' do

      current_count = Location.count()
      Location.create!(name: "Zippy")
      assert Location.count() == current_count + 1
      Location.find_by!(name: "Zippy").destroy!
      assert Location.count() == current_count

    end

    test 'find locations fixtures' do

      l = Location.find_by(name: "Shelf 1")
      assert l.id == 1
      assert l.name == "Shelf 1"
      assert l.comment == "Comment for location Shelf 1"
      refute l.is_retired
      assert l.user_id == 1

      l2 = Location.find_by(name: "Shelf 2")
      assert l2.id == 2
      assert l2.name == "Shelf 2"
      assert l2.comment == "Comment for location Shelf 2"
      refute l2.is_retired
      assert l2.user_id == 2
    end

    test "the scope from the model concerns" do

      assert Location.all_active.pluck(:name).sort == ["Shelf 1", "Shelf 2"]
      Location.find_by(name: "Shelf 2").update_attributes!(is_retired: true)
      assert Location.all_active.pluck(:name).sort == [ "Shelf 1" ]
      Location.find_by(name: "Shelf 2").update_attributes!(is_retired: false)
      assert Location.all_active.pluck(:name).sort == ["Shelf 1", "Shelf 2"]
    end


end
