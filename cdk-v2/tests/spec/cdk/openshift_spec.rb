require 'spec_helper'

###############################################################################
# Tests verifying the correct installation of OpenShift
###############################################################################

describe service('openshift') do
  it { should be_enabled }
end

describe service('openshift') do
  it { should be_running }
end

describe port(8443) do
  let(:disable_sudo) { false }
  it { should be_listening }
end

describe command('curl -k https://10.1.2.2:8443/console/') do
  its(:stdout) { should contain /OpenShift Web Console/ }
end

describe command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u openshift-dev -p devel') do
  its(:stdout) { should contain /Login successful./ }
end

describe command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u admin -p admin') do
  its(:stdout) { should contain /Login successful./ }
end

describe "OpenShift registry" do
  it "should be exposed" do
    registry_describe = command('oc --config=/var/lib/origin/openshift.local.config/master/admin.kubeconfig  describe route/docker-registry')
    registry_describe.should contain /hub.cdk.10.1.2.2.xip.io/
  end
end

describe "Admin user" do
  it "should be able to list OpenShift nodes" do
    command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u admin -p admin')
    nodes = command("oc get nodes").stdout
    nodes.should contain /localhost.localdomain/
    command("oc logout")
  end
end

describe "Basic templates" do
  it "should exist" do
    command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u admin -p admin')
    templates = command("oc --insecure-skip-tls-verify get templates -n openshift").stdout
    templates.should contain /eap64-basic-s2i/
    templates.should contain /odejs-example/
    command('oc logout')
  end
end

describe "Basic Node.js app" do
  it "should build" do
    command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u openshift-dev -p devel')
    fail # TODO
    command("oc logout")
  end
end
