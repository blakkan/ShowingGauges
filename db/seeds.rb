# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#when seeding, we need to bypass validations, since we're not logged in
u = User.new(  {name: "Winky", capabilities: "admin"} )
u.save!(validate: false)

u = User.new(  {name: "Surin", capabilities: "admin"} )
u.save!(validate: false)

u = User.new(  {name: "John", capabilities: "admin"})
u.save!(validate: false)
