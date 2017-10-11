# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

locations = Location.create( [{name: 'Shelf 1'},
                              {name: 'Shelf 2'},
                              {name: 'Shelf 3'},
                              {name: 'Overflow'} ])

skus = Sku.create( [{name: '80-000001', bu: "11", category: "A", description: "LAN-0000", cost: 121.32},
                      {name: '80-000002', bu: "23", category: "B", description: "LAN-1111", cost: 11.11},
                      {name: '80-000003', bu: "99", category: "C", description: "LAN-2222",cost: 0.85},
                      {name: '80-000004', bu: "19", category: "D", description: "LAN-3333", cost: 6.67} ])

bins = Bin.create( [
                    {qty: 4,
                      location_id: Location.find_by(name: 'Shelf 1').id,
                      sku_id: Sku.find_by(name: "80-000002").id},
                    {qty: 2,
                       location_id: Location.find_by(name: 'Shelf 2').id,
                       sku_id: Sku.find_by(name: "80-000002").id},
                    {qty: 1,
                      location_id: Location.find_by(name: 'Shelf 3').id,
                      sku_id: Sku.find_by(name: "80-000001").id},
                    {qty: 1,
                      location_id: Location.find_by(name: 'Overflow').id,
                      sku_id: Sku.find_by(name: "80-000003").id},
                    {qty: 8,
                      location_id: Location.find_by(name: 'Overflow').id,
                      sku_id: Sku.find_by(name: "80-000004").id}
                       ])

users = User.create( [{name: "TechA"},
                      {name: "TechB"},
                      {name: "Winky", capabilities: "admin"},
                      {name: "Surin", capabilities: "admin"},
                      {name: "John", capabilities: "admin"} ])
