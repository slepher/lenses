-include_lib("astranaut/include/macro.hrl").
-ifndef(MAKE_LENSES).
-define(MAKE_LENSES, true).
-compile({parse_transform, make_lenses}).
-endif.