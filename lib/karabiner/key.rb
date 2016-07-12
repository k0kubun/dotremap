class Karabiner::Key
  KEYCODE_MAP = {
    "0"      => "KEY_0",
    "1"      => "KEY_1",
    "2"      => "KEY_2",
    "3"      => "KEY_3",
    "4"      => "KEY_4",
    "5"      => "KEY_5",
    "6"      => "KEY_6",
    "7"      => "KEY_7",
    "8"      => "KEY_8",
    "9"      => "KEY_9",
    "Up"     => "CURSOR_UP",
    "Down"   => "CURSOR_DOWN",
    "Right"  => "CURSOR_RIGHT",
    "Left"   => "CURSOR_LEFT",
    "]"      => "BRACKET_RIGHT",
    "["      => "BRACKET_LEFT",
    ";"      => "SEMICOLON",
    "-"      => "MINUS",
    ","      => "COMMA",
    "."      => "DOT",
    "\\"     => "BACKSLASH",
    "/"      => "SLASH",
    "="      => "EQUAL",
    "'"      => "QUOTE",
    "`"      => "BACKQUOTE",
    "Ctrl_R" => "CONTROL_R",
    "Ctrl_L" => "CONTROL_L",
    "Alt_R"  => "OPTION_R",
    "Alt_L"  => "OPTION_L",
    "Opt_R"  => "OPTION_R",
    "Opt_L"  => "OPTION_L",
    "Cmd_R"  => "COMMAND_R",
    "Cmd_L"  => "COMMAND_L",
    "Esc"    => "ESCAPE",
  }.freeze
  PREFIX_MAP = {
    "C"     => "VK_CONTROL",
    "Ctrl"  => "VK_CONTROL",
    "Cmd"   => "VK_COMMAND",
    "Shift" => "VK_SHIFT",
    "M"     => "VK_OPTION",
    "Opt"   => "VK_OPTION",
    "Alt"   => "VK_OPTION",
  }.freeze
  PREFIX_EXPRESSION = "(#{PREFIX_MAP.keys.map { |k| k + '-' }.join('|')})"

  def initialize(expression)
    @expression = expression
  end

  def to_s
    key_combination(@expression)
  end

  private

  def key_combination(raw_combination)
    raw_prefixes, raw_key = split_key_combination(raw_combination)
    return key_expression(raw_key) if raw_prefixes.empty?

    prefixes = raw_prefixes.map { |raw_prefix| PREFIX_MAP[raw_prefix] }
    "#{key_expression(raw_key)}, #{prefixes.join(' | ')}"
  end

  def key_expression(raw_key)
    case raw_key
    when /^(#{KEYCODE_MAP.keys.map { |k| Regexp.escape(k) }.join('|')})$/
      "KeyCode::#{KEYCODE_MAP[raw_key]}"
    else
      raw_key = raw_key.upcase unless raw_key.match(/^VK_/)
      "KeyCode::#{raw_key}"
    end
  end

  def split_key_combination(raw_combination)
    prefixes = []
    key = raw_combination.dup

    while key.match(/^#{PREFIX_EXPRESSION}/)
      key.gsub!(/^#{PREFIX_EXPRESSION}/) do
        prefixes << $1.gsub(/-$/, "")
        ""
      end
    end

    [prefixes, key]
  end
end
