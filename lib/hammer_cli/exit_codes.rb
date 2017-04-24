module HammerCLI
  # taken from sysexits.h
  EX_OK           = 0       # successful termination
  EX_USAGE        = 64      # command line usage error
  EX_DATAERR      = 65      # data format error
  EX_NOINPUT      = 66      # cannot open input
  EX_NOUSER       = 67      # addressee unknown
  EX_NOHOST       = 68      # host name unknown
  EX_UNAVAILABLE  = 69      # service unavailable
  EX_SOFTWARE     = 70      # internal software error
  EX_OSERR        = 71      # system error (e.g., can't fork)
  EX_OSFILE       = 72      # critical OS file missing
  EX_CANTCREAT    = 73      # can't create (user) output file
  EX_IOERR        = 74      # input/output error
  EX_TEMPFAIL     = 75      # temp failure; user is invited to retry
  EX_PROTOCOL     = 76      # remote error in protocol
  EX_NOPERM       = 77      # permission denied
  EX_CONFIG       = 78      # configuration error

  # non POSIX codes
  EX_NOT_FOUND    = 128     # resource was not found
  EX_UNAUTHORIZED = 129     # authorization failed
  EX_RETRY        = 666     # retry the command
end
