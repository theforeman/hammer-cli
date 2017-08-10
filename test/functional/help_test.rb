require File.join(File.dirname(__FILE__), './test_helper')

describe 'help' do
  class CmdWithHelp < HammerCLI::AbstractCommand
    extend_help do |h|
      h.text 'Details about interface settings'

      h.section 'Available keys for --interface' do |h|
        h.list([
          'mac',
          'ip',
          ['type',         'One of interface, bmc, bond'],
          'name',
          'subnet_id',
          'domain_id',
          'identifier',
          ['managed',      'true/false'],
          ['primary',      'true/false, each managed hosts needs to have one primary interface.'],
          ['provision',    'true/false'],
          ['virtual',      'true/false']
        ])
        h.section 'For virtual interfaces' do |h|
          h.list([
            ['tag',          'VLAN tag, this attribute has precedence over the subnet VLAN ID. Only for virtual interfaces.'],
            ['attached_to',  'Identifier of the interface to which this interface belongs, e.g. eth1.']
          ])
        end
        h.section 'For bonds' do |h|
          h.list([
            ['mode',             'One of balance-rr, active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, balance-alb'],
            ['attached_devices', 'Identifiers of slave interfaces, e.g. [eth1,eth2]'],
            'bond_options'
          ])
        end
        h.section 'For BMCs' do |h|
          h.list([
            ['provider',         'always IPMI'],
            'username',
            'password'
          ])
        end
      end
    end
  end

  it 'prints additional help' do
    result = run_cmd(['-h'], {}, CmdWithHelp)
    result.out.must_equal [
      'Usage:',
      '    hammer [OPTIONS]',
      '',
      'Options:',
      ' -h, --help                    Print help',
      '',
      'Details about interface settings',
      '',
      'Available keys for --interface:',
      '  mac',
      '  ip',
      '  type                One of interface, bmc, bond',
      '  name',
      '  subnet_id',
      '  domain_id',
      '  identifier',
      '  managed             true/false',
      '  primary             true/false, each managed hosts needs to have one primary interface.',
      '  provision           true/false',
      '  virtual             true/false',
      '',
      '  For virtual interfaces:',
      '    tag                 VLAN tag, this attribute has precedence over the subnet VLAN ID. Only for virtual interfaces.',
      '    attached_to         Identifier of the interface to which this interface belongs, e.g. eth1.',
      '',
      '  For bonds:',
      '    mode                One of balance-rr, active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, balance-alb',
      '    attached_devices    Identifiers of slave interfaces, e.g. [eth1,eth2]',
      '    bond_options',
      '',
      '  For BMCs:',
      '    provider            always IPMI',
      '    username',
      '    password',
      ''
    ].join("\n")
  end

end
