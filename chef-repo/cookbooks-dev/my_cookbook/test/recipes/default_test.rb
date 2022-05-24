describe file('/tmp/greeting.txt') do
  its('content') { should match 'Ohai, Chefs!' }
end
