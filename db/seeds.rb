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

skus = Sku.create( [{name: '80-000001'},
                      {name: '80-000002'},
                      {name: '80-000003'},
                      {name: '80-000004'} ])

bins = Bin.create( [{qty: 4,
                      location_id: Location.find_by(name: 'Shelf 1').id,
                      sku_id: Sku.find_by(name: "80-000002").id},
                      {qty: 2,
                       location_id: Location.find_by(name: 'Shelf 2').id,
                       sku_id: Sku.find_by(name: "80-000002").id} ])

users = User.create( [{name: "TechA"},
                      {name: "TechB"},
                      {name: "Winky", capabilities: "admin"},
                      {name: "Surin", capabilities: "admin"},
                      {name: "John", capabilities: "admin"} ])
