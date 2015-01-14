require 'uri'

describe Calabash::Device do

  before(:each) do
    allow_any_instance_of(Calabash::Application).to receive(:ensure_application_path)
  end

  let(:identifier) {:my_identifier}
  let(:server) {Calabash::Server.new(URI.parse('http://localhost:100'), 200)}

  let(:device) {Calabash::Device.new(identifier, server)}

  it 'should have an instance of RetriableHTTPClient initialized' do
    expect(device.http_client).to be_a(Calabash::HTTP::RetriableClient)
  end

  describe '#install' do
    it 'should invoke the managed impl if running in a managed env' do
      params = {my: :param}
      expected_params = params.merge({device: device})

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(device).not_to receive(:_install)
      expect(Calabash::Managed).to receive(:install).with(expected_params)

      device.install(params)
    end

    it 'should invoke its own impl unless running in a managed env' do
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(device).to receive(:_install).with(params)
      expect(Calabash::Managed).not_to receive(:install)

      device.install(params)
    end
  end

  describe '#uninstall' do
    it 'should invoke the managed impl if running in a managed env' do
      params = {my: :param}
      expected_params = params.merge({device: device})

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(device).not_to receive(:_uninstall)
      expect(Calabash::Managed).to receive(:uninstall).with(expected_params)

      device.uninstall(params)
    end

    it 'should invoke its own impl unless running in a managed env' do
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(device).to receive(:_uninstall).with(params)
      expect(Calabash::Managed).not_to receive(:uninstall)

      device.uninstall(params)
    end
  end

  describe '#clear_app' do
    it 'should invoke the managed impl if running in a managed env' do
      params = {my: :param}
      expected_params = params.merge({device: device})

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(device).not_to receive(:_clear_app)
      expect(Calabash::Managed).to receive(:clear_app).with(expected_params)

      device.clear_app(params)
    end

    it 'should invoke its own impl unless running in a managed env' do
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(device).to receive(:_clear_app).with(params)
      expect(Calabash::Managed).not_to receive(:clear_app)

      device.clear_app(params)
    end
  end

  describe '#_install' do
    it 'should have an abstract implementation' do
      params = {my: :param}

      expect{device.send(:_install, params)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_uninstall' do
    it 'should have an abstract implementation' do
      params = {my: :param}

      expect{device.send(:_uninstall, params)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#ensure_test_server_ready' do
    it 'should raise a runtime error if the test server does not respond' do
      allow(Timeout).to receive(:timeout).with(an_instance_of(Fixnum), Calabash::Device::EnsureTestServerReadyTimeoutError).and_raise(Calabash::Device::EnsureTestServerReadyTimeoutError.new)

      expect{device.ensure_test_server_ready}.to raise_error(RuntimeError)
    end

    it 'should now raise an error if the test server does respond' do
      expect(device).to receive(:test_server_responding?).exactly(5).times.and_return(false, false, false, false, true)

      device.ensure_test_server_ready
    end
  end

  describe '#test_server_responding?' do
    it 'should have an abstract implementation' do
      expect{device.test_server_responding?}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#default' do
    after do
      Calabash::Device.default = nil
    end

    it 'should be able to set its default device' do
      Calabash::Device.default = :my_device
    end

    it 'should be able to get its default device' do
      device = :my_device

      Calabash::Device.default = device

      expect(Calabash::Device.default).to eq(device)
    end
  end

  describe '#parse_app_parameters' do
    it 'raises an error on invalid arguments' do
      expect { device.send(:parse_app_parameters, :foo) }.to raise_error ArgumentError
    end

    it 'returns an Application when passed an Application' do
      app = Calabash::Application.new('path/to/my/app')
      expect(device.send(:parse_app_parameters, app)).to be == app
    end

    it 'returns an Application when passed a String' do
      expected_path = File.expand_path('./path/to/my/app')
      app = device.send(:parse_app_parameters, expected_path)
      expect(app.path).to be == expected_path
    end
  end
end
