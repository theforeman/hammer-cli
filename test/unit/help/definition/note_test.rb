require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::Note do
  describe '#build_string' do
    let(:text) { 'text' }
    let(:note) { HammerCLI::Help::Note.new(text) }

    it 'builds string' do
      note.build_string.must_equal 'NOTE: text'
    end

    it 'ensures that options are used' do
      label = 'DEPRECATION'
      note = HammerCLI::Help::Note.new(text, label: label, richtext: true)
      note.build_string.must_equal "#{HighLine.color("#{label}:", :bold)} #{text}"
    end
  end
end
