describe passwd.uids(0) do
  its('users') { should cmp 'root' }
  its('entries.length') { should eq 1 }
end