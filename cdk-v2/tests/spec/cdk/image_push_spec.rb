require 'spec_helper'

###############################################################################
# Tests verifying pushing an arbitrary image
###############################################################################

describe "Pushing arbitrary docker image" do
  let(:disable_sudo) { false }
  it "should work" do
    # Using Ghost as image to test. Pulled from Docker Hub
    exit = command('docker pull ghost').exit_status
    exit.should be 0

    # We need a project to "host" our image
    exit = command('oc --insecure-skip-tls-verify login 10.1.2.2:8443 -u openshift-dev -p devel').exit_status
    exit.should be 0
    exit = command('oc new-project myproject').exit_status
    exit.should be 0
    token = command('oc whoami -t').stdout

    # 1 - Tag the image against the exposed OpenShift registry using the created project name as target
    # 2 - Log into the Docker registry
    # 3 - Push the image
    exit = command('docker tag ghost hub.cdk.10.1.2.2.xip.io/myproject/ghost').exit_status
    exit.should be 0
    command("docker login -u openshift-dev -p #{token} -e foo@bar.com hub.cdk.10.1.2.2.xip.io")
    exit = command('docker push hub.cdk.10.1.2.2.xip.io/myproject/ghost').exit_status
    exit.should be 0

    # 1 - Create the app from the image stream created by pusing the image
    # 2 - Expose a route to the app
    exit = command('oc new-app --image-stream=ghost --name=ghost').exit_status
    exit.should be 0
    exit = command('oc expose service ghost --hostname=ghost.10.1.2.2.xip.io').exit_status
    exit.should be 0
    # TODO - instead of sleep we should use oc to monitor the state of the pod until running
    sleep 60

    # Verify Ghost is up and running
    uri = URI.parse("http://ghost.10.1.2.2.xip.io")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.code.should match /200/
  end

  # after do
  #   puts "Cleaning up"
  #   out = command('docker rmi hub.cdk.10.1.2.2.xip.io/myproject/ghost').stdout
  #   puts "#{out}"
  #   out = command('oc delete all --all').stdout
  #   puts "#{out}"
  #   out = command('oc delete project myproject').stdout
  #   puts "#{out}"
  # end
end

