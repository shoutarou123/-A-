User.create!(name: "管理者",
             email: "sample@email.com",
             employee_number: 1111,
             uid: 1111,
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "上長A",
             email: "sample-A@email.com",
             employee_number: 2222,
             uid: 2222,
             password: "password",
             password_confirmation: "password",
             role: "superior",
             superior: true)
             
             User.create!(name: "上長B",
             email: "sample-B@email.com",
             employee_number: 3333,
             uid: 3333,
             password: "password",
             password_confirmation: "password",
             role: "superior",
             superior: true)

5.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  employee_number = n+5555
  uid = n+5555
  password = "password"
  User.create!(name: name,
               email: email,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password)
end

# ok