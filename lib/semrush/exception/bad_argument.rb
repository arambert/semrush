module Semrush
  module Exception
    class BadArgument < Base

    end
    class MandatoryParameterDomainNotSetOrEmtpy <  BadArgument; end
    class MandatoryParameterUrlNotSetOrEmtpy <  BadArgument; end
    class MandatoryParameterPhraseNotSetOrEmtpy <  BadArgument; end
  end
end
