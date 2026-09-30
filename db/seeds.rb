# One user per role for local development. Password: "password".
return unless Rails.env.development?

User.roles.each_key do |role|
  User.find_or_create_by!(email_address: "#{role}@example.com") do |user|
    user.password = "password"
    user.role = role
  end
end
