require "spec_helper"
require "tempfile"

describe Dotremap do
  let!(:config) { Tempfile.new(".remap") }
  let(:xml_dir) { "/tmp" }
  let(:xml_path) { File.join(xml_dir, Dotremap::XML_FILE_NAME) }
  let(:result) { File.read(xml_path) }

  before do
    stub_const("Dotremap::XML_DIR", xml_dir)
    allow_any_instance_of(Dotremap).to receive(:reload_xml)

    # Silence stdout
    allow_any_instance_of(Kernel).to receive(:puts)
  end

  after do
    config.close!
  end

  def prepare_dotremap(dotremap)
    config.write(dotremap)
    config.rewind
  end

  def expect_result(expected_result)
    dotremap = Dotremap.new(config.path)
    dotremap.apply_configuration
    expect(result).to eq(expected_result)
  end

  it "accepts blank config" do
    prepare_dotremap("")

    expect_result(<<-EOS.unindent)
      <?xml version="1.0"?>
      <root>

      </root>
    EOS
  end

  it "accepts cmd combination" do
    prepare_dotremap(<<-EOS)
      item "Command+A to Command+B" do
        remap "Cmd-A", to: "Cmd-B"
      end
    EOS

    expect_result(<<-EOS.unindent)
      <?xml version="1.0"?>
      <root>
        <item>
          <name>Command+A to Command+B</name>
          <identifier>remap.command_a_to_command_b</identifier>
          <autogen>__KeyToKey__ KeyCode::A, VK_COMMAND, KeyCode::B, VK_COMMAND</autogen>
        </item>
      </root>
    EOS
  end
end