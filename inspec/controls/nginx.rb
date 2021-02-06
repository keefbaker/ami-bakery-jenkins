control "check nginx is installed and running" do
  describe service("nginx") do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe port(80) do
    it { should be_listening }
    its("processes") { should include "nginx" }
  end
end
