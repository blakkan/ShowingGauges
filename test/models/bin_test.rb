require 'test_helper'

class BinTest < ActiveSupport::TestCase
  #Test creation
  test 'create bin' do

    current_count = Bin.count()
    j = Bin.create!(qty: 1, location_id: 1, sku_id: 1)
    assert Bin.count() == current_count + 1
    j.destroy!
    assert Bin.count() == current_count

  end

  test 'find bin fixtures' do

    j = Bin.all().as_json

    assert j[0]['qty'] == 16
    assert j[1]['qty'] == 4

  end

end
