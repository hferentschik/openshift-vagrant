require 'spec_helper'

# Tests verifying the correct installation of OpenShift
describe port(8443) do
  it { should be_listening }
end

describe command('yes | oc login 10.1.2.2:8443 -u foo -p bar') do
  let(:disable_sudo) { true }
  its(:stdout) { should match /Login successful./ }
end
