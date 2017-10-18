require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  #Test creation
  test 'create transaction' do

    current_count = Transaction.count()
    j = Transaction.create!(qty: 1, comment: "Transaction comment", from_id: 1, to_id: 2, sku_id: 1)
    assert Transaction.count() == current_count + 1
    j.destroy!
    assert Transaction.count() == current_count

  end

  test 'find transaction fixtures' do

    j = Transaction.all().as_json

    assert j[0]['comment'] = "Transaction one comment"
    assert j[1]['comment'] = "Transaction twoco mment" 

  end

end
