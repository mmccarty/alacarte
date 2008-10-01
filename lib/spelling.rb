#Wrapper for TinyMCE's spellchecker, using commandline Aspell.
#Will need a rewrite for Windows based deployments, using perhaps
#the Windows port of Aspell?
#
#Thanks Mike for the inspiration:
#  http://www.gusto.com/mike/blog/post202
#

module Spelling
  SPELL_REGEX = Regexp.new(/([a-z]*) \d+.*/i)
  SUGGEST_REGEX = Regexp.new(/[\w\d]*: ([\w, ]*)/i)
  ASPELL_PATH = "aspell"

  def check_spelling(spell_check_text, command, lang)
    xml_response_values = []
    spell_check_response = `echo "#{spell_check_text}" | #{ASPELL_PATH} -a -l #{lang}`
    if (spell_check_response != '')
      spelling_errors = spell_check_response.split("\n")[1..-1]
      if (command == 'spell')
        for error in spelling_errors
          error.strip!
          if (error.match(SPELL_REGEX))
            xml_response_values << $1
          end
        end
      elsif (command == 'suggest')
        for error in spelling_errors
          error.to_s.strip!
          if (match_data = error.match(SUGGEST_REGEX))
            xml_response_values = $1.split(", ") if $1
          end
        end
      end
    end
    return xml_response_values
  end
end
